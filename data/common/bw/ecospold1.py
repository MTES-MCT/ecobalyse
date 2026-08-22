"""Reading BAFU's native EcoSpold 1, which openLCA wrote and the EcoSpold01 XSD rejects.

`bw2io` parses EcoSpold 1 through `pyecospold`, which binds the official XSD to the
parser. BAFU's package does not validate against it: of 200 datasets taken in order, 168
were refused, for seven different reasons. None of those reasons concerns a flow or an
amount, they are all shape and metadata, so the answer is to stop validating and repair
the four things that still break the parse.

Dropping the schema is not free in principle: lxml also applies the XSD's default
attribute values while parsing, so a document could read differently without it. Measured
on the 32 datasets of that sample that do validate, both ways extract identical results,
so the schema was contributing nothing to this data.
"""

import re

from bw2io.migrations import Migration
from bw2io.units import DEFAULT_UNITS_CONVERSION
from lxml import objectify
from pyecospold import core
from pyecospold.lxmlh import parsers

NAMESPACE = "http://www.EcoInvent.org/EcoSpold01"

_ROOT = "<ecoSpold>"
_DATE = re.compile(r"<(startDate|endDate)>([^<]*)</\1>")
_EMPTY_PERIOD = re.compile(r"<timePeriod([^>]*)/>")
_TIMESTAMP = re.compile(r'timestamp="(\d{4}-\d{2}-\d{2})')
_NOT_A_NUMBER = re.compile(r'\s+(year|volumeNo)="(?!\d+")[^"]*"')


def _full_date(match: re.Match) -> str:
    """openLCA writes `2000`, `2000-01` and `2023-05-31+02:00` where a date is expected,
    and `pyecospold` hands the text straight to dateutil, which rejects the last two."""
    parts = match[2].split("+")[0].split("-")[:3]
    return f"<{match[1]}>{'-'.join(parts + ['01'] * (3 - len(parts)))}</{match[1]}>"


def repair(text: str) -> str:
    """Make one openLCA-written EcoSpold 1 dataset readable, without touching its data.

    Four defects, in the order they show up:

    - no default namespace. Even unvalidated, `pyecospold` builds a missing `startDate`
      with `nsmap[None]` and raises `KeyError: None` without one.
    - partial or offset-carrying dates, which dateutil refuses.
    - an empty `<timePeriod/>`, which leaves dateutil an empty string. Filled with the
      dataset's own `timestamp`, so the value comes from the file rather than from us.
    - `year=""` and `volumeNo="nan"` on bibliographic sources, which are declared as
      integers. The attribute is removed: absent says "not stated", which is what an
      empty string meant, where the empty string makes `pyecospold` call `int('')`.
    """
    day = _TIMESTAMP.search(text)
    dates = f"<startDate>{day[1]}</startDate><endDate>{day[1]}</endDate>" if day else ""
    text = text.replace(_ROOT, f'<ecoSpold xmlns="{NAMESPACE}">', 1)
    text = _DATE.sub(_full_date, text)
    text = _EMPTY_PERIOD.sub(lambda m: f"<timePeriod{m[1]}>{dates}</timePeriod>", text)
    return _NOT_A_NUMBER.sub("", text)


def _parse_without_schema(file, schema_path, lookup):
    parser = objectify.makeparser()
    parser.set_element_class_lookup(lookup)
    return objectify.parse(file, parser).getroot()


def stop_validating_ecospold1() -> None:
    """Let `pyecospold` parse a document that does not match the EcoSpold01 XSD.

    Called for its effect on the two modules that build the parser. Import order matters:
    `bw2io.extractors.ecospold1` reads `pyecospold.parse_file_v1`, which resolves
    `parse_file` at call time, so patching the module attribute is enough.
    """
    parsers.parse_file = _parse_without_schema
    core.parse_file = _parse_without_schema


def capitalize_compartments(data: list[dict]) -> list[dict]:
    """Bring BAFU's compartment names into the vocabulary bw2io already knows.

    The package writes `emissions to air/high. pop.` and `resources/in ground`. That is
    the ecoinvent 2 vocabulary `normalize_simapro_biosphere_categories` was written for,
    only lowercased: its table is keyed on `Emissions to air` and `Resources`. Capitalizing
    the compartment hands the whole job over to that strategy, subcategories included
    (`high. pop.` becomes `urban air close to ground`, `river` becomes `surface water`).

    The package uses six compartments, and the table covers all six: emissions to air,
    to water, to soil, resources, non material emissions and economic issues. Left alone,
    every biosphere flow of the database is fabricated for want of a matching compartment.
    """
    for dataset in data:
        for exchange in dataset.get("exchanges", []):
            if exchange.get("type") == "biosphere" and exchange.get("categories"):
                compartment, *rest = exchange["categories"]
                exchange["categories"] = (compartment.capitalize(), *rest)
    return data


UNIT_MIGRATION = "bafu-ecospold1-units"

# bw2io's `default-units` migration converts an amount into the unit the rest of the
# chain expects. Its time entries cannot be used on this package.
#
# `a` does not label a year here, it labels an hour. The 87 flows written in `a` are all
# machine operation or device use (power sawing, forwarding, skidding, cable yarding,
# helicopter transport, computer use), and two of them, `Transport, freight helicopter,
# single-engine {CH}` and `Use, computer, desktop with LCD monitor, active mode {RER}`,
# are written `a` in some datasets and `hr` in others. The numbers settle it: `Use,
# computer, laptop, active mode {CH}` draws 0.019 kilowatt hour and wears out 2.85e-05
# laptop per unit of output, which is a 19 watt laptop lasting 35000 hours if the unit is
# an hour, and a 2 microwatt laptop if it is a year. SimaPro's export of this same
# database writes every one of them in hours, unchanged. So `year` is relabelled here,
# not converted.
#
# The three other time entries are shipped upside down: bw2io multiplies a `day` by 1/24
# to make hours, a `second` by 3600, a `minute` by 60. This package never writes them, so
# rather than correct numbers nothing here relies on, they are left out.
YEAR_IS_AN_HOUR = ("year", "hour", 1.0)

UNUSED_TIME_CONVERSIONS = frozenset({"s", "day", "min", "year"})

# `Nm3` and `m3` name one unit in this package, and the export cannot decide which.
#
# The flow `Gas, natural, in ground` is written `m3` on 137 exchanges and `Nm3` on 115
# of them, and the technosphere product `Natural gas, at production {DZ}` is produced
# in `Nm3` while five of the datasets consuming it ask for `m3`. Kept apart, half the gas
# of the database lands on a biosphere flow the method does not characterize, and the
# technosphere edges that miss their producer get an empty activity built for them by
# `add_unlinked_activities`. Both losses are silent: fossil resource use of a gas
# pipeline comes out at 0.8% of its real value with nothing reporting anything.
#
# The two units carry the same numbers here. SimaPro's export of this same database
# writes every one of those 252 exchanges in `m3`, with amounts identical to the native
# package (`0.027781` on the Brazilian pipeline edge, on both sides), so aligning them
# costs no conversion. Nothing but natural gas uses `Nm3` in the package: 127 biosphere
# exchanges, 2145 technosphere exchanges and 669 reference products, all of them gas.
GAS_UNIT = ("normal cubic meter", "cubic meter", 1.0)


def unit_conversions() -> list[tuple[str, str, float]]:
    """bw2io's table, minus its time entries, plus the two conversions this package needs."""
    return [
        conversion
        for conversion in DEFAULT_UNITS_CONVERSION
        if conversion[0] not in UNUSED_TIME_CONVERSIONS
    ] + [YEAR_IS_AN_HOUR, GAS_UNIT]


def register_unit_migration() -> None:
    """Write the migration the EcoSpold 1 import applies in place of `default-units`."""
    Migration(UNIT_MIGRATION).write(
        {
            "fields": ["unit"],
            "data": [
                ((source,), {"unit": target, "multiplier": multiplier})
                for source, target, multiplier in unit_conversions()
            ],
        },
        "bw2io's unit conversions, minus its time entries, plus year and Nm3",
    )


# The package declares one dataset in a unit that contradicts its own content, and no
# rule can tell which side is wrong without looking at the numbers. The `{FI}` plant
# burns 14.07 megajoules of natural gas per unit of electricity it delivers: read as
# megajoules that is a 7% efficient power plant, read as kilowatt hours a 26% efficient
# one. SimaPro's export of this same dataset says kilowatt hour, and the single edge
# asking for it (`Electricity, from natural gas {FI}`, 0.0157) is in kilowatt hours too.
#
# Left alone the edge finds no provider, `add_unlinked_activities` builds an empty
# activity for it and that share of the Finnish gas electricity contributes nothing.
MISLABELLED_REFERENCE_UNITS = {
    ("Electricity, natural gas, at power plant {FI}", "megajoule"): "kilowatt hour",
}


def fix_reference_units(data: list[dict]) -> list[dict]:
    """Give the datasets of `MISLABELLED_REFERENCE_UNITS` the unit their content implies.

    The amounts are left alone: what is corrected is the label, not the quantity.
    """
    for dataset in data:
        corrected = MISLABELLED_REFERENCE_UNITS.get(
            (dataset.get("name"), dataset.get("unit"))
        )
        if corrected is None:
            continue
        dataset["unit"] = corrected
        for exchange in dataset.get("exchanges", []):
            if exchange.get("type") == "production":
                exchange["unit"] = corrected
    return data
