"""Compare the impacts we publish with the ones VoLCA computes from the same source files.

One cloud per impact category: a point is one activity, x the impact published in
processes_impacts.json, y what VoLCA computes on the same SimaPro export with the same
method. The command stands on its own: it installs the engine, generates its configuration,
starts a server on a free port, loads the seven databases, resolves every published activity
that has a source file behind it, scores each database in one batch, draws, and says what
each phase cost.

It needs an engine that carries its own reference data, so VoLCA v0.12.0 or later.
VOLCA_BINARY points it at a local build instead of the release pyvolca installs.
"""

import csv
import io
import json
import os
import statistics
import sys
import tempfile
import time
from collections.abc import Callable, Iterator, Sequence
from contextlib import contextmanager, redirect_stderr
from math import copysign, log
from pathlib import Path
from typing import NamedTuple, TypedDict

import matplotlib.pyplot as plt
import volca
from volca import Client, Server, VoLCAError

from common import (
    calculate_aggregate,
    correct_process_impacts,
    get_normalization_weighting_factors,
)
from common.export import IMPACTS_JSON
from common.impacts import impacts
from config import DATA_ROOT_DIR, settings
from ecobalyse_data import s3
from ecobalyse_data.bw.migration import (
    GINKO_MIGRATIONS,
    PASTOECO_MIGRATIONS,
    WOOLMARK_MIGRATIONS,
)
from ecobalyse_data.bw.strategy import use_unit_processes


def db_name(file: str) -> str:
    """The engine's name for one source file, ours alone so it never shares a cache."""
    return f"eb-{file.lower()}"


class Source(NamedTuple):
    file: str  # settings.dbfiles key
    dep: str | None = None  # the file its inputs link to, as in Ecobalyse's import
    migrations: Sequence[dict] = ()  # Ecobalyse's renames, handed to VoLCA as aliases
    unit_processes: bool = False  # also rename what strategy.use_unit_processes renames

    @property
    def db(self) -> str:
        return db_name(self.file)


SOURCES = {  # "source" in processes_impacts.json -> where VoLCA reads it
    "Agribalyse 3.2": Source("AGRIBALYSE"),
    "Ecoinvent 3.9.1": Source("EI391"),
    "Ecoinvent 3.11": Source("EI311"),
    "WFLDB": Source("WFLDB"),
    "Ginko 2025": Source("GINKO", "AGRIBALYSE", GINKO_MIGRATIONS),
    "PastoEco": Source("PASTOECO", "AGRIBALYSE", PASTOECO_MIGRATIONS),
    "Woolmark": Source("WOOL", "EI391", WOOLMARK_MIGRATIONS, True),
}


class Process(TypedDict):
    """One process of processes_impacts.json, as far as this comparison reads it."""

    source: str  # the database it was imported from, a key of SOURCES
    activityName: str  # the product name, which is what VoLCA calls the product
    location: str
    unit: str  # the unit its impacts are given for
    impacts: dict[str, float]  # trigram -> impact, ecs included


# what a whole database looks like once listed: product name, lowercased, -> its activities
Catalogue = dict[str, list[volca.Activity]]
# what the engine's units.csv says: unit name, lowercased -> (dimension, factor)
UnitTable = dict[str, tuple[str, float]]
# what a phase says of itself, before it starts and once it is over
Phase = Callable[[str], None]
UNITS = {"t⋅km": "tkm"}  # Ecobalyse unit -> the unit VoLCA reads in the file
TRIGRAMS = {category: trigram for trigram, (_, category) in impacts.items()}
CORRECTIONS = {k: v["correction"] for k, v in IMPACTS_JSON.items() if "correction" in v}
FACTORS = get_normalization_weighting_factors(IMPACTS_JSON)
PROCESSES = (
    DATA_ROOT_DIR / settings.frontend_data_dir / settings.processes_merged_impacts_file
)
LABELS_PER_CLOUD = 3  # how many worst deviations each cloud names
TABLE_ROWS = 30  # how many lines the deviation table holds
OUTPUT = Path("output")


def config_toml(files: dict[str, Path]) -> str:
    """Build the engine configuration: the seven databases, the method and its uranium patch.

    Takes each source file's local path, by settings.dbfiles key. Returns the TOML text.
    """
    databases = "\n".join(
        f"[[databases]]\nname = {json.dumps(source.db)}\n"
        f"path = {json.dumps(str(files[source.file]))}\n"
        for source in SOURCES.values()
    )
    return f"""[server]
port = 0

{databases}
[[methods]]
name = {json.dumps(settings.bw.method)}
path = {json.dumps(str(files["METHOD"]))}

[[methods.patches]]
description = "uraniumFRU: lower the fossil resource use of uranium by 40%, as strategy.py does at import"
match = {{ category = "Resource use, fossils", flow-name-prefix = "Uranium" }}
scale = 0.6
"""


def unit_factors(table: str) -> UnitTable:
    """Read the engine's unit table: units.csv text in, unit name -> (dimension, factor) out."""
    return {
        row["name"].lower(): (row["dimension"], float(row["factor"]))
        for row in csv.DictReader(io.StringIO(table))
        if row["name"] and not row["name"].startswith("#")
    }


def alias_csv(source: Source, missing: list[str], dep: Catalogue) -> str:
    """Hand VoLCA Ecobalyse's renames, so this database's inputs link where its own import links them.

    Only the renames on the name alone are handed over, the ones VoLCA's aliases can express.
    Takes the source, the names the engine reports missing and the dependency's catalogue.
    Returns the alias CSV relink reads, targets spelled as the dependency spells them.
    """
    renames = [
        (old[0], new["name"])
        for migration in source.migrations
        if tuple(migration["data"]["fields"]) == ("name",)
        for old, new in migration["data"]["data"]
    ]
    if source.unit_processes:
        # the strategy works on datasets: hand it the missing names as one, and swallow the
        # progress bar it draws over that single dataset
        with redirect_stderr(io.StringIO()):
            renamed = use_unit_processes(
                [{"exchanges": [{"name": name} for name in missing]}]
            )[0]["exchanges"]
        renames += [
            (name, exc["name"])
            for name, exc in zip(missing, renamed)
            if name != exc["name"]
        ]

    def spelled(target: str) -> str:
        # Brightway links names case-insensitively, VoLCA's aliases are exact: spell the
        # target as the file does. An ambiguous name keeps the migration's own spelling,
        # and the input it renames stays in the unresolved count the run prints.
        hits = dep.get(target.lower(), [])
        return hits[0].product_name if len(hits) == 1 else target

    out = io.StringIO()
    csv.writer(out).writerows(
        [("source", "target"), *((name, spelled(t)) for name, t in renames)]
    )
    return out.getvalue()


def catalogue(client: Client) -> Catalogue:
    """List a whole database in one call, so every lookup afterwards is local.

    Takes a client on the loaded database. Returns product name, lowercased -> its activities.
    """
    index: Catalogue = {}
    # the engine's default page is small: 25 000 activities cost 60s page by page, 1s in pages of 5 000
    for a in client.search_activities(page=1, page_size=5000):
        index.setdefault(a.product_name.lower(), []).append(a)
    return index


def resolve(
    index: Catalogue, processes: list[Process]
) -> tuple[list[tuple[Process, volca.Activity]], list[str]]:
    """Find the VoLCA activity behind each published process, joining on the product name.

    Takes the database's catalogue and the processes published from it. Returns the
    (process, activity) pairs found, and one line per name it could not match.
    """
    found, unresolved = [], []
    for p in processes:
        hits = index.get(p["activityName"].lower(), [])
        if len(hits) > 1 and p["location"]:
            hits = [a for a in hits if a.location == p["location"]]
        if len(hits) == 1:
            found.append((p, hits[0]))
        else:
            unresolved.append(
                f"{p['activityName']} [{p['location']}]: {len(hits)} match(es)"
            )
    return found, unresolved


def scale(p: Process, a: volca.Activity, units: UnitTable) -> float | None:
    """What multiplies VoLCA's score to put it on Ecobalyse's functional unit.

    VoLCA scores 1 reference unit of the product's dimension (kg, m3, kgm, mj...), Ecobalyse
    1 declared unit (kg, L, t⋅km, kWh...). Takes the published process, its VoLCA activity
    and the unit table. Returns the factor, or None when the units measure different things.
    """
    # packaging is scored for the amount the process produces, as computation.py does
    if p["unit"] == "item":
        return a.product_amount
    dim, factor = units[UNITS.get(p["unit"], p["unit"]).lower()]
    product_dim, product_factor = units[a.product_unit.lower()]
    if dim != product_dim:
        return None
    return copysign(factor / product_factor, a.product_amount)


def volca_impacts(scored: volca.ScoredActivity, factor: float) -> dict[str, float]:
    """Turn VoLCA's raw category scores into what processes_impacts.json holds, as computation.py does.

    Takes one scored activity and its unit factor. Returns trigram -> impact, ecs included.
    """
    scores = {
        TRIGRAMS[r.category]: r.score
        for r in scored.impacts.results
        if r.category in TRIGRAMS
    }
    correct_process_impacts(scores, CORRECTIONS)
    scores["ecs"] = calculate_aggregate("ecs", scores, FACTORS)
    return {trigram: value * factor for trigram, value in scores.items()}


def comparable(rows: list[dict], trigram: str) -> list[tuple[float, float, dict]]:
    """Keep the activities the two engines can be compared on for one impact.

    Both values have to be positive: a ratio against zero says nothing, and a log scale draws
    neither. Takes the rows and a trigram. Returns (Brightway, VoLCA, row) triples.
    """
    return [
        (r["brightway"][trigram], r["volca"][trigram], r)
        for r in rows
        if r["brightway"][trigram] > 0 and r["volca"][trigram] > 0
    ]


def deviation(ratio: float) -> float:
    """How far one ratio is from agreement: a factor 25 up scores like a factor 25 down."""
    return abs(log(ratio))


def outliers(
    points: list[tuple[float, float, dict]], count: int
) -> list[tuple[float, dict]]:
    """Pick out the activities the two engines disagree on most.

    Takes one impact's comparable points and how many to keep. Returns (ratio, row) pairs,
    furthest from 1 first.
    """
    ratios = [(volca / brightway, r) for brightway, volca, r in points]
    return sorted(ratios, key=lambda pair: deviation(pair[0]), reverse=True)[:count]


def draw(rows: list[dict], path: Path) -> None:
    """Draw one cloud per impact category, the worst deviations named: rows in, figure out."""
    sources = sorted({r["source"] for r in rows})
    colour = {source: f"C{rank}" for rank, source in enumerate(sources)}
    fig, axes = plt.subplots(4, 5, figsize=(25, 20))
    for ax, trigram in zip(axes.flat, rows[0]["brightway"], strict=True):
        points = comparable(rows, trigram)
        published, computed, drawn = zip(*points)
        ax.scatter(
            published,
            computed,
            c=[colour[r["source"]] for r in drawn],
            s=8,
            alpha=0.6,
        )
        middle = statistics.median(published)
        for rank, (ratio, r) in enumerate(outliers(points, LABELS_PER_CLOUD)):
            x, y = r["brightway"][trigram], r["volca"][trigram]
            right = x > middle  # names near the right edge grow leftwards
            ax.scatter([x], [y], s=30, facecolor="none", edgecolor="black", zorder=3)
            ax.annotate(
                f"{r['activityName'][:34]} {ratio - 1:+.0%}",
                (x, y),
                xytext=(-6 if right else 6, 3 + 10 * rank),  # stack them, they crowd
                textcoords="offset points",
                ha="right" if right else "left",
                fontsize=6,
            )
        lo, hi = min(*published, *computed), max(*published, *computed)
        ax.fill_between(
            [lo, hi],
            [lo * 0.99, hi * 0.99],
            [lo * 1.01, hi * 1.01],
            color="grey",
            alpha=0.3,
            lw=0,
        )
        ax.plot([lo, hi], [lo, hi], color="black", lw=0.5)
        left_out = len(rows) - len(points)
        ax.set(
            xscale="log",
            yscale="log",
            title=trigram
            + (f"  ({left_out} points ≤ 0 not drawn)" if left_out else ""),
        )
    axes[-1, 0].set(xlabel="Brightway", ylabel="VoLCA")
    fig.legend(
        handles=[
            plt.Line2D([], [], marker="o", ls="", color=colour[s], label=s)
            for s in sources
        ],
        loc="lower center",
        ncol=len(sources),
    )
    fig.savefig(path, bbox_inches="tight")


@contextmanager
def engine(binary: str) -> Iterator[Server]:
    """Start an engine of this tool's own, on a free port, on the files the import reads.

    Takes the engine binary's path. Yields the running server, and stops it on the way out.
    """
    with tempfile.TemporaryDirectory() as tmp:
        toml = Path(tmp) / "volca.toml"
        keys = [*(source.file for source in SOURCES.values()), "METHOD"]
        files = {
            key: s3.get_file(settings.dbfiles[key], settings.dbfiles[f"{key}_MD5"])
            for key in keys
        }
        toml.write_text(config_toml(files))
        with Server(str(toml), port="auto", binary=binary) as server:
            yield server


def to_compare(processes: list[Process]) -> dict[str, list[Process]]:
    """Keep the published processes a source file can answer for, one per activity.

    Takes everything processes_impacts.json holds. Returns source name -> its distinct
    activities. Two processes on the same activity are the same measurement published
    twice, so keep one, and refuse to choose if they disagree.
    """
    wanted: dict[str, dict[tuple[str, str], Process]] = {}
    for p in processes:
        if p["source"] in SOURCES:
            key = (p["activityName"], p["location"])
            kept = wanted.setdefault(p["source"], {}).setdefault(key, p)
            if kept["impacts"] != p["impacts"]:
                raise ValueError(f"{key} is published twice with different impacts")
    return {name: list(byname.values()) for name, byname in wanted.items()}


def link(client: Client, source: Source, dep: str, products: Catalogue) -> int:
    """Link one database to the database its inputs come from.

    Takes a client on the database, its source, the settings.dbfiles key of the file its
    inputs link to and what that file sells. Returns how many inputs are still unresolved.
    """
    # the engine reports its top missing suppliers only, so alias what it shows and go
    # again with every name seen so far: a name left out of the map would unlink again
    names: list[str] = []
    while True:
        linked = client.relink(db_name(dep), alias_csv(source, names, products))
        gaps = client.get_setup()["missingSuppliers"]
        new = [m["productName"] for m in gaps if m["productName"] not in names]
        if linked["unresolvedAfter"] == 0 or not new:
            return linked["unresolvedAfter"]
        names += new


def score(client: Client, found: list[tuple[Process, volca.Activity]]) -> dict:
    """Ask the engine for every activity of one database at once.

    Takes a client on the database and the (process, activity) pairs to score. Returns
    process id -> its scores. Stops the run if the engine leaves any of them unanswered.
    """
    scores = client.score_activities(
        [a.process_id for _, a in found], top_flows=0, exclude_long_term=True
    )
    by_pid = {s.process_id: s for s in scores.results}
    unscored = (
        scores.not_found
        + scores.invalid
        + scores.unscorable
        + [a.process_id for _, a in found if a.process_id not in by_pid]
    )
    if unscored:
        sys.exit(f"the engine did not score {unscored}")
    return by_pid


def gap_report(client: Client, refusal: VoLCAError) -> str:
    """Name the inputs the engine refuses to score over, which Ecobalyse's import empties.

    Takes a client on the refused database and the engine's answer. Returns what to print.
    """
    gaps = client.get_setup()["missingSuppliers"]
    return f"{refusal}\n" + "\n".join(
        f"      {m['count']} × {m['productName']}" for m in gaps
    )


def compare(
    name: str,
    found: list[tuple[Process, volca.Activity]],
    by_pid: dict,
    units: UnitTable,
) -> tuple[list[dict], list[str]]:
    """Put both engines' impacts side by side, on the same functional unit.

    Takes the source name, its (process, activity) pairs, their scores by process id and the
    unit table. Returns one row per activity, and one line per activity in another unit.
    """
    rows, skipped = [], []
    for p, a in found:
        factor = scale(p, a, units)
        if factor is None:
            skipped.append(f"{p['activityName']}: {p['unit']} vs {a.product_unit}")
            continue
        rows.append(
            {
                "source": name,
                "activityName": p["activityName"],
                "location": p["location"],
                "unit": p["unit"],
                "brightway": p["impacts"],
                "volca": volca_impacts(by_pid[a.process_id], factor),
            }
        )
    return rows, skipped


def report(
    rows: list[dict], unresolved: list[str], skipped: list[str], refused: dict[str, str]
) -> None:
    """Say what was compared, what was not, and where the two engines disagree.

    Takes the compared rows and what fell aside on the way. Prints the counts, a median per
    impact category and the widest deviations.
    """
    print(
        f"\n{len(rows)} activities compared, {len(unresolved)} names unmatched, "
        f"{len(skipped)} with another unit"
    )
    for line in unresolved + skipped:
        print("  ", line)
    for name, why in refused.items():
        print(f"REFUSED {name}: {why}")
    for trigram in rows[0]["brightway"]:
        ratios = [
            volca / brightway for brightway, volca, _ in comparable(rows, trigram)
        ]
        within = sum(abs(ratio - 1) <= 0.01 for ratio in ratios)
        print(
            f"{trigram:6} median VoLCA/Brightway {statistics.median(ratios):.4f}, "
            f"within 1%: {within}/{len(ratios)}"
        )
    print(f"\nThe {TABLE_ROWS} widest deviations, all categories together:")
    worst = sorted(
        (
            (trigram, ratio, r)
            for trigram in rows[0]["brightway"]
            for ratio, r in outliers(comparable(rows, trigram), TABLE_ROWS)
        ),
        key=lambda row: deviation(row[1]),
        reverse=True,
    )[:TABLE_ROWS]
    for trigram, ratio, r in worst:
        print(
            f"  {trigram:6} {ratio - 1:+8.0%}  {r['activityName']} "
            f"[{r['location']}] ({r['source']})"
        )


def stopwatch() -> tuple[Phase, Phase, dict[str, float]]:
    """Report each phase on a line of its own: what it is doing, then what it did and cost.

    Returns the function that announces a phase, the function that overwrites that
    announcement once the phase is over, and the dictionary of seconds it fills.
    """
    spent: dict[str, float] = {}
    last = time.monotonic()
    width = 0

    def doing(phase: str) -> None:
        nonlocal width
        width = len(phase) + 3
        print(f"{phase}...", end="\r", flush=True)

    def done(phase: str) -> None:
        nonlocal last
        now = time.monotonic()
        spent[phase] = now - last
        last = now
        # pad over what the announcement wrote, in case this line is the shorter one
        print(f"{phase} in {spent[phase]:.1f}s".ljust(width), flush=True)

    return doing, done, spent


def write(rows: list[dict], version: str, spent: dict[str, float]) -> None:
    """Keep the comparison: every row as data, every category as a cloud.

    Takes the compared rows, the engine version that produced them and what each phase cost.
    Writes the two files in output/.
    """
    OUTPUT.mkdir(exist_ok=True)
    data, figure = OUTPUT / "compare_volca.json", OUTPUT / "compare_volca.svg"
    data.write_text(
        json.dumps(
            {"volca": version, "seconds": spent, "rows": rows},
            ensure_ascii=False,
            indent=1,
        )
    )
    draw(rows, figure)
    print(f"written {data} and {figure}")


def main() -> None:
    """Run the whole comparison: install the engine, load, link, score, report, draw."""
    doing, done, spent = stopwatch()
    installed = volca.download()
    units = unit_factors((installed.data_dir / "units.csv").read_text())
    processes: list[Process] = json.loads(PROCESSES.read_text())
    wanted = to_compare(processes)
    aside = sum(p["source"] not in SOURCES for p in processes)
    print(
        f"{len(processes)} processes: {aside} without a source file set aside, "
        f"{sum(len(v) for v in wanted.values())} distinct activities to compare"
    )

    rows, unresolved, skipped, refused = [], [], [], {}
    listed: dict[str, Catalogue] = {}
    with engine(os.environ.get("VOLCA_BINARY", str(installed.binary))) as server:
        version = Client(server.base_url).get_version()
        print(f"VoLCA {version.version} ({version.git_hash}) on {server.base_url}")
        for name, source in SOURCES.items():
            client = Client(server.base_url, db=source.db)
            doing(f"{source.file}: loading")
            client.load_database(source.db)
            index = listed[source.file] = catalogue(client)
            done(f"{source.file}: {len(index)} products listed")
            if source.dep:
                doing(f"{source.file}: linking to {source.dep}")
                left = link(client, source, source.dep, listed[source.dep])
                done(f"{source.file}: linked, {left} inputs unresolved")
            found, missed = resolve(index, wanted[name])
            unresolved += missed
            if not found:
                sys.exit(f"{source.file}: none of its names matched a VoLCA activity")
            doing(f"{source.file}: scoring {len(found)} activities")
            try:
                by_pid = score(client, found)
            except VoLCAError as refusal:
                done(f"{source.file}: refused, nothing scored")
                refused[name] = gap_report(client, refusal)
                continue
            scored, unscalable = compare(name, found, by_pid, units)
            rows += scored
            skipped += unscalable
            done(f"{source.file}: {len(found)} activities scored")

    report(rows, unresolved, skipped, refused)
    write(rows, version.version, spent)
    print(f"{sum(spent.values()):.0f}s in total")


if __name__ == "__main__":
    main()
