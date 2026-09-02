#!/usr/bin/env python3
import csv
import functools
import tempfile
from collections import defaultdict
from pathlib import Path
from zipfile import ZipFile

import bw2data
import bw2io
from bw2io.strategies import (
    # drop_unlinked_cfs,
    drop_unspecified_subcategories,
    link_iterable_by_fields,
    match_subcategories,
    normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_biosphere_type,
)
from frozendict import frozendict

from common import brightway_patch as brightway_patch  # noqa: PLC0414
from common.impacts import impacts
from common.import_ import setup_project
from config import settings
from ecobalyse_data import s3
from ecobalyse_data.bw.strategy import noLT, uraniumFRU
from ecobalyse_data.logging import logger

# Agribalyse 3.2, Ginko, WFLDB and Ecoinvent 3.9.1 carry the legacy SimaPro flow
# names. EF 3.1 1.03 renamed a number of substances (keeping the same CAS) to newer
# names, so the new method stopped characterizing the legacy-named biosphere flows: their
# impact (ozone depletion, freshwater ecotoxicity) would be silently undercounted on
# those databases. We re-characterize each legacy flow with its modern synonym's
# factor, so the substance is counted whatever naming vintage a source database uses.
#
# Mapping is modern name -> legacy name (as it appears in biosphere3).
# Every entry must be a clean rename, i.e. the legacy name must
# be absent from the 1.03 method; add_legacy_flow_synonyms only fills that gap and never
# overrides a factor the method already defines (which would double-count).
METHOD_FLOW_SYNONYMS = {
    # Ozone depletion (emissions to air)
    "Bromomethane": "Methane, bromo-, Halon 1001",
    "Bromotrifluoromethane": "Methane, bromotrifluoro-, Halon 1301",
    "Bromochlorodifluoromethane": "Methane, bromochlorodifluoro-, Halon 1211",
    "1,1,1-Trichloroethane": "Ethane, 1,1,1-trichloro-, HCFC-140",
    # Freshwater ecotoxicity (pesticides, emissions to soil/water/air)
    "Quizalofop-ethyl": "Quizalofop ethyl ester",
    "Pyrethrins": "Pyrethrum",
    "Pyrethrin II": "Pyrethrin",
    "Flupyrsulfuron-methyl sodium": "Flupyrsulfuron-methyl",
    "Flurochloridone": "Fluorochloridone",
    # Human toxicity, non-cancer: Mecoprop-P keeps its ecotoxicity factor in 1.03 but
    # lost its human-toxicity one, so the gap-filling guard re-adds it only there.
    "Mecoprop": "Mecoprop-P",
}


def add_legacy_flow_synonyms(db):
    """Re-characterize each legacy-named biosphere flow with its modern synonym's
    factor (see METHOD_FLOW_SYNONYMS). Only fills gaps: a legacy name the 1.03 method
    already characterizes is left untouched, so no factor is ever double-counted."""
    for method in db:
        present = {(cf["name"], cf.get("categories")) for cf in method["exchanges"]}
        method["exchanges"].extend(
            {**cf, "name": METHOD_FLOW_SYNONYMS[cf["name"]]}
            for cf in list(method["exchanges"])
            if cf.get("name") in METHOD_FLOW_SYNONYMS
            and (METHOD_FLOW_SYNONYMS[cf["name"]], cf.get("categories")) not in present
        )
    return db


# EF 3.1 depletes minerals per element (ADP, ultimate reserve), but Ecoinvent/WFLDB emit
# ore-grade-specific resource flows ("Gold, Au 9.7E-4%, in mixed ore, in ground", …). The
# 1.03 method lists only a subset of those name variants, so most Copper/Gold/Silver grades
# lost their factor and mru is silently undercounted on those databases. Every grade of an
# element carries the same per-element factor, so we broadcast it to all of them.
MRU_CATEGORY = impacts["mru"][1]
# A few flows use the element symbol; their full-name twin carries the surviving factor.
MINERAL_ELEMENT_ALIASES = {
    "Cu": "Copper",
    "Ni": "Nickel",
    "Pd": "Palladium",
    "Pt": "Platinum",
}


def broadcast_mineral_grades(db):
    """Characterize every ore-grade mineral resource flow with its element's factor (taken
    from the grades the method still lists), so mru is counted whatever grade names a source
    database uses. Only fills gaps; an already-characterized flow is left untouched."""
    biosphere = bw2data.Database(settings.bw.BIOSPHERE)
    for method in db:
        if method["name"][1] != MRU_CATEGORY:
            continue
        factor_for = {}
        for cf in method["exchanges"]:
            factor_for.setdefault(cf["name"].split(",")[0].strip(), cf)
        present = {
            (cf["name"], tuple(cf.get("categories") or ()))
            for cf in method["exchanges"]
        }
        for flow in biosphere:  # ty: ignore[not-iterable]
            categories = tuple(flow.get("categories") or ())
            if (
                flow.get("type") != "emission"
                or not categories
                or categories[0] != "natural resource"
            ):
                continue
            key = (flow["name"], categories)
            if key in present:
                continue
            element = flow["name"].split(",")[0].strip()
            base = factor_for.get(element) or factor_for.get(
                MINERAL_ELEMENT_ALIASES.get(element, "")
            )
            if base is None:
                continue
            method["exchanges"].append(
                {
                    **base,
                    "name": flow["name"],
                    "categories": categories,
                }
            )
            present.add(key)
    return db


def report_dropped_cfs(importer) -> None:
    in_biosphere = {flow["name"] for flow in bw2data.Database(settings.bw.BIOSPHERE)}  # ty: ignore[not-iterable]
    linked = {
        (method["name"], cf["name"])
        for method in importer.data
        for cf in method["exchanges"]
        if cf.get("input")
    }
    misplaced = [
        (method["name"], cf)
        for method in importer.data
        for cf in method["exchanges"]
        if not cf.get("input")
        and (method["name"], cf["name"]) not in linked
        and cf["name"] in in_biosphere
    ]
    if not misplaced:
        logger.info("🟢 Every substance the method and the biosphere share is counted")
        return

    report = Path("output") / f"dropped-cfs-{settings.bw.METHOD}.csv"
    report.parent.mkdir(parents=True, exist_ok=True)
    with report.open("w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["method", "category", "name", "categories", "unit", "amount"])
        for name, cf in sorted(misplaced, key=lambda item: (item[0], item[1]["name"])):
            writer.writerow(
                [
                    name[0],
                    name[1] if len(name) > 1 else "",
                    cf.get("name"),
                    "/".join(cf.get("categories") or ()),
                    cf.get("unit"),
                    cf.get("amount"),
                ]
            )
    logger.warning(
        f"⚠️ {len(misplaced)} characterization factors name a substance the biosphere has, "
        f"on a compartment that reaches none of its flows. Those substances will not be "
        f"counted. See {report}"
    )


def remember_simapro_name(db):
    """Keep the name a factor arrived with, so a collision can name the rename that
    caused it instead of only the flow it landed on."""
    for method in db:
        for cf in method["exchanges"]:
            cf.setdefault("simapro name", cf["name"])
    return db


def colliding_cfs(importer) -> dict:
    grouped = defaultdict(lambda: defaultdict(list))
    for method in importer.data:
        for cf in method["exchanges"]:
            key = (method["name"], cf["name"], tuple(cf.get("categories") or ()))
            grouped[key][cf["amount"]].append(cf.get("simapro name", cf["name"]))
    return {key: dict(values) for key, values in grouped.items() if len(values) > 1}


def report_colliding_cfs(importer) -> None:
    """Refuse to write a method whose factors would silently multiply a substance."""
    collisions = colliding_cfs(importer)
    if not collisions:
        logger.info("🟢 No flow carries two disagreeing characterization factors")
        return

    # The same merge shows up once per subcategory, so report it by the names that
    # collide rather than by flow: that is the list of renames to fix.
    by_merge: dict[tuple[str, tuple[str, ...]], dict[float, list[str]]] = {}
    for (_method_name, name, _categories), values in collisions.items():
        sources = tuple(
            sorted({source for names in values.values() for source in names})
        )
        by_merge.setdefault((name, sources), values)
    for (name, sources), values in sorted(by_merge.items()):
        logger.error(
            f"    {list(sources)} all become {name!r}, factors {sorted(values)}"
        )
    raise ValueError(
        f"{len(collisions)} flows would carry several disagreeing characterization "
        f"factors, and every score of those substances would be multiplied. Fix the "
        f"renames in data/simapro-biosphere.json that merge them, then import again."
    )


def import_method():
    """
    Import file at path `datapath` linked to biosphere named `dbname`
    """

    logger.debug(
        f"{settings.bw.BIOSPHERE} size: {len(bw2data.Database(settings.bw.BIOSPHERE))}"  # ty: ignore[invalid-argument-type]
    )
    logger.info(f"🟢 Importing {settings.dbfiles.METHOD}")
    datapath = s3.get_file(settings.dbfiles.METHOD, settings.dbfiles.METHOD_MD5)
    # unzip
    with tempfile.TemporaryDirectory() as tempdir:
        logger.debug(f"-> Extracting the zip file {datapath}")
        with ZipFile(datapath) as zf:
            extracted_fn = zf.extract(zf.namelist()[0], tempdir)
            logger.debug(f"-> Extracted the zip file as {extracted_fn}")

            ef = bw2io.importers.SimaProLCIACSVImporter(
                extracted_fn, biosphere=settings.bw.BIOSPHERE
            )

            ef.statistics()

            ef.strategies = [  # ty: ignore[invalid-assignment]
                normalize_units,
                set_biosphere_type,
                drop_unspecified_subcategories,
                functools.partial(normalize_biosphere_categories, lcia=True),
                functools.partial(normalize_biosphere_names, lcia=True),
                normalize_simapro_biosphere_categories,
                remember_simapro_name,
                normalize_simapro_biosphere_names,
                add_legacy_flow_synonyms,
                broadcast_mineral_grades,
                functools.partial(
                    link_iterable_by_fields,
                    other=(
                        obj
                        for obj in bw2data.Database(ef.biosphere_name)  # ty: ignore[not-iterable]
                        if obj.get("type") in ("emission", "natural resource")
                    ),
                    kind="biosphere",
                ),
                functools.partial(
                    match_subcategories, biosphere_db_name=ef.biosphere_name
                ),
            ]
            ef.strategies.append(noLT)
            ef.strategies.append(uraniumFRU)
            ef.apply_strategies()
            logger.debug(f"biosphere3 size: {len(bw2data.Database('biosphere3'))}")  # ty: ignore[invalid-argument-type]
            ef.statistics()

            # ef.write_excel(METHODNAME)
            # drop CFs which are not linked to a biosphere substance
            # But report them rather than drop them quietly.
            report_dropped_cfs(ef)
            ef.drop_unlinked()
            # Report before the deduplication below drops the name each factor arrived with.
            report_colliding_cfs(ef)
            # Remove duplicates in exchanges, ignoring that name: several names merged
            # onto one flow by one factor must collapse back to a single factor, or
            # bw2calc sums them and multiplies the substance.
            for m in ef.data:
                m["exchanges"] = [
                    dict(f)
                    for f in {
                        frozendict({k: v for k, v in d.items() if k != "simapro name"})
                        for d in m["exchanges"]
                    }
                ]

            ef.write_methods(overwrite=True)
    logger.info(f"🟢 Finished importing {settings.bw.METHOD}")


if __name__ == "__main__":
    setup_project()

    # Always reimport. Importing a database adds elementary flows to the biosphere, and
    # a method written before them characterizes none of them. Skipping the reimport
    # because the method happens to exist is how a stale method silently stops counting
    # the substances a freshly imported database emits.
    import_method()
