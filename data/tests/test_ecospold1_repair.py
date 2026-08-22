import pytest
from bw2io.extractors.ecospold1 import Ecospold1DataExtractor

from common.bw.ecospold1 import repair, stop_validating_ecospold1

# One dataset carrying the four defects openLCA writes into BAFU's EcoSpold 1 package:
# no namespace, a partial `startDate`, an empty `<timePeriod/>` and `year=""`.
BROKEN = """<?xml version="1.0" encoding="UTF-8"?>
<ecoSpold>
  <dataset generator="openLCA" number="1" timestamp="2023-08-28T15:03:42.257+02:00">
    <metaInformation>
      <processInformation>
        <referenceFunction amount="1.0" category="chemicals" subCategory="inorganics"
          datasetRelatesToProduct="true" name="Sulphur, at plant" localName="Sulphur"
          unit="kg" infrastructureProcess="false" includedProcesses="Everything."
          generalComment="A comment."/>
        <geography location="CH"/>
        <technology/>
        <timePeriod dataValidForEntirePeriod="true"/>
        <dataSetInformation type="1" impactAssessmentResult="false"
          timestamp="2023-08-28T15:03:42" version="1.0" internalVersion="1.0"
          energyValues="0" languageCode="en" localLanguageCode="de"/>
      </processInformation>
      <modellingAndValidation>
        <representativeness/>
        <source year="" sourceType="0" firstAuthor="Someone" title="A report"/>
      </modellingAndValidation>
      <administrativeInformation>
        <dataEntryBy person="1" qualityNetwork="1"/>
        <dataGeneratorAndPublication person="1" dataPublishedIn="0"/>
        <person number="1" name="Someone" address="Somewhere" telephone="0"
          email="someone@example.org" companyCode="AAA" countryCode="CH"/>
      </administrativeInformation>
    </metaInformation>
    <flowData>
      <exchange number="1" category="chemicals" subCategory="inorganics"
        name="Sulphur, at plant" location="CH" unit="kg" meanValue="1.0"
        uncertaintyType="0">
        <outputGroup>0</outputGroup>
      </exchange>
      <exchange number="2" category="air" subCategory="low population density"
        name="Carbon dioxide, fossil" unit="kg" meanValue="0.5" uncertaintyType="0">
        <outputGroup>4</outputGroup>
      </exchange>
    </flowData>
  </dataset>
</ecoSpold>
"""


def extract(path):
    stop_validating_ecospold1()
    return Ecospold1DataExtractor.process_file(str(path), "BAFU")


def test_the_package_as_shipped_cannot_be_read(tmp_path):
    """Without the repair the dataset is lost, and lost quietly if the caller catches
    per file: the package holds 11747 of them and 132 fail on metadata alone."""
    broken = tmp_path / "broken.xml"
    broken.write_text(BROKEN)

    with pytest.raises(Exception):  # noqa: B017 - lxml and dateutil each raise their own
        extract(broken)


def test_repaired_dataset_keeps_its_flows(tmp_path):
    repaired = tmp_path / "repaired.xml"
    repaired.write_text(repair(BROKEN))

    (dataset,) = extract(repaired)

    assert dataset["name"] == "Sulphur, at plant"
    assert dataset["location"] == "CH"
    assert dataset["unit"] == "kg"
    amounts = {
        exchange["name"]: exchange["amount"] for exchange in dataset["exchanges"]
    }
    assert amounts == {"Sulphur, at plant": 1.0, "Carbon dioxide, fossil": 0.5}


def test_repair_leaves_the_flow_data_alone():
    """The repair may only touch the envelope. Anything it changed inside `flowData`
    would change an inventory, which is the one thing it must not do."""
    before = BROKEN.split("<flowData>")[1]
    after = repair(BROKEN).split("<flowData>")[1]

    assert before == after


def test_dates_come_from_the_dataset_itself(tmp_path):
    """The empty `<timePeriod/>` is filled from the dataset's own timestamp, so no date
    is invented."""
    repaired = tmp_path / "repaired.xml"
    repaired.write_text(repair(BROKEN))

    (dataset,) = extract(repaired)

    tags = dict(dataset["tags"])
    assert tags["ecoSpold01startDate"] == "2023-08-28"
    assert tags["ecoSpold01endDate"] == "2023-08-28"


def test_the_year_of_this_package_is_an_hour():
    """A 19 watt laptop, not a 2 microwatt one: `a` labels an hour and is relabelled."""
    from common.bw.ecospold1 import unit_conversions

    factors = {
        (source, target): multiplier
        for source, target, multiplier in unit_conversions()
    }
    assert factors[("year", "hour")] == pytest.approx(1.0)
    # The other time entries are inverted upstream and unused here, so they are absent.
    assert ("day", "hour") not in factors
    assert ("min", "hour") not in factors
    assert ("s", "hour") not in factors
    # Everything bw2io got right is left alone.
    assert factors[("Becquerel", "kilo Becquerel")] == pytest.approx(1e-3)
    assert factors[("PJ", "megajoule")] == pytest.approx(1e9)


def test_gas_unit_migration_puts_the_two_cubic_meters_together():
    """`Nm3` and `m3` name one unit in this package, and half the gas rides on each."""
    from bw2io.strategies import migrate_exchanges

    from common.bw.ecospold1 import UNIT_MIGRATION, register_unit_migration

    register_unit_migration()
    data = migrate_exchanges(
        [
            {
                "exchanges": [
                    {
                        "name": "Gas, natural, in ground",
                        "unit": "normal cubic meter",
                        "amount": 2.0,
                    },
                    {
                        "name": "Gas, natural, in ground",
                        "unit": "cubic meter",
                        "amount": 3.0,
                    },
                ]
            }
        ],
        migration=UNIT_MIGRATION,
    )
    units = {exchange["unit"] for exchange in data[0]["exchanges"]}
    assert units == {"cubic meter"}
    # A label, not a quantity: the amounts must come through untouched.
    assert [exchange["amount"] for exchange in data[0]["exchanges"]] == [2.0, 3.0]


def test_the_finnish_power_plant_is_read_in_kilowatt_hours():
    """Its content says kilowatt hour; left in megajoules its consumer finds no provider."""
    from common.bw.ecospold1 import fix_reference_units

    data = fix_reference_units(
        [
            {
                "name": "Electricity, natural gas, at power plant {FI}",
                "unit": "megajoule",
                "exchanges": [
                    {"type": "production", "unit": "megajoule", "amount": 1.0},
                    {"type": "technosphere", "unit": "megajoule", "amount": 14.07},
                ],
            },
            {"name": "Something else", "unit": "megajoule", "exchanges": []},
        ]
    )
    assert data[0]["unit"] == "kilowatt hour"
    assert data[0]["exchanges"][0]["unit"] == "kilowatt hour"
    # Only the reference product is relabelled: the gas it burns is still megajoules.
    assert data[0]["exchanges"][1]["unit"] == "megajoule"
    assert data[1]["unit"] == "megajoule"
