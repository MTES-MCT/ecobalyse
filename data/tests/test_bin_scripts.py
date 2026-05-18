import tempfile

import bw2data
import orjson
from pytest import approx

from bin import export_bw_db, export_lcia, lcia_info
from config import settings
from ecobalyse_data.bw import simapro_export
from models.process import ComputedBy, Impacts


# Basic test to see if the script compiles
def test_export_icv(mocker):
    mocker.patch("bw2data.databases", return_value=[])

    with tempfile.NamedTemporaryFile(delete=False) as fp:
        # Just check that the main function runs as expected
        export_lcia.main(output_file=fp, cpu_count=1, max=1)
        fp.close()

        # And that it creates an empty file
        with open(fp.name, "rb") as f:
            json_data = orjson.loads(f.read())
            assert json_data == {}


# Basic test to see if the script compiles
def test_export_icv_forwast(forwast, forwast_json_icv):
    with tempfile.NamedTemporaryFile(delete=False) as fp:
        # Just check that the main function runs as expected
        export_lcia.main(
            project=settings.bw.project,
            output_file=fp,
            activity_name="_22 Vegetable and animal oils and fats, EU27",
            location="GLO",
            db=["forwast"],
            # Doesn't work as expected in MAC OS X
            # See https://github.com/MTES-MCT/ecobalyse-data/pull/55#pullrequestreview-2656329669
            multiprocessing=False,
        )
        fp.close()

        # And that it computes the expected data
        with open(fp.name, "rb") as f:
            json_data = orjson.loads(f.read())
            assert len(json_data["forwast"]) == len(forwast_json_icv["forwast"]) == 1
            val_expected = forwast_json_icv["forwast"][0]
            val_computed = json_data["forwast"][0]
            # Check approximate equality of the impacts
            assert val_computed["impacts"] == approx(val_expected["impacts"])
            # Check full equality of the rest
            val_computed.pop("impacts")
            val_expected.pop("impacts")
            assert val_computed == val_expected


def test_export_bw_db(mocker):
    # Just check that the imports are ok

    mocker.patch("ecobalyse_data.bw.simapro_export.export_db_to_simapro")
    with tempfile.NamedTemporaryFile(delete=False) as fp:
        export_bw_db.main(fp, "")
        simapro_export.export_db_to_simapro.assert_called_once()


def test_forwast_restore(forwast):
    assert list(bw2data.databases) == ["ecoinvent-3.9.1-biosphere", "forwast"]


def test_lcia_info(forwast, forwast_json_icv):
    impacts = lcia_info.lcia_impacts(
        activity_name="_22 Vegetable and animal oils and fats, EU27",
        database_name="forwast",
        simapro=False,
    )

    forwast_impacts = forwast_json_icv["forwast"][0]["impacts"]
    assert impacts[0] == ComputedBy.brightway
    assert impacts[1].model_dump() == approx(Impacts(**forwast_impacts).model_dump())
