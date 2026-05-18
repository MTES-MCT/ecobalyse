import os

# FIXME: in theory, we should be able to select the `testing` dynaconf
# environment with a fixture like:
#
#   @pytest.fixture(scope="session", autouse=True)
#   def set_test_settings():
#       settings.configure(FORCE_ENV_FOR_DYNACONF="testing")
#
# (see https://www.dynaconf.com/advanced/#pytest)
# Unfortunately, although this does apparently correctly select the testing
# environment as expected, for some reason some tests fail, probably because of
# some global state.
# So for now, let’s just force it in os.environ
#
os.environ["FORCE_ENV_FOR_DYNACONF"] = "testing"


import bw2data
import orjson
import pytest
from bw2data import config as bwconfig
from bw2data import projects

from common import brightway_patch as brightway_patch
from config import PROJECT_ROOT_DIR, TESTS_FIXTURE_DIR, settings
from ecobalyse_data.tests import restore_archived_project

TESTS_SNAPSHOTS_DIR = PROJECT_ROOT_DIR / "tests" / "snapshots"


@pytest.fixture
def forwast(temp_bw_dir):
    restore_archived_project(
        TESTS_FIXTURE_DIR / "bw-project-forwast-with-patched-ef31.tar.gz"
    )

    bw2data.projects.set_current(settings.bw.project)


@pytest.fixture
def temp_bw_dir(tmp_path):
    bwconfig.dont_warn = True
    bwconfig.is_test = True

    os.environ["BRIGHTWAY2_DIR"] = str(tmp_path)
    projects.change_base_directories(
        base_dir=tmp_path,
        base_logs_dir=tmp_path,
        project_name=settings.bw.project,
        update=False,
    )
    projects._is_temp_dir = True


@pytest.fixture
def forwast_json_icv():
    with open(TESTS_FIXTURE_DIR / "forwast.json", "rb") as f:
        return orjson.loads(f.read())


@pytest.fixture
def processes_impacts_json():
    with open(TESTS_SNAPSHOTS_DIR / "processes_impacts.json", "rb") as f:
        return orjson.loads(f.read())


@pytest.fixture
def ingredients_food_json():
    with open(TESTS_SNAPSHOTS_DIR / "food" / "ingredients.json", "rb") as f:
        return orjson.loads(f.read())


@pytest.fixture
def materials_textile_json():
    with open(TESTS_SNAPSHOTS_DIR / "textile" / "materials.json", "rb") as f:
        return orjson.loads(f.read())


@pytest.fixture
def processes_impacts_full_json():
    with open(TESTS_SNAPSHOTS_DIR / "processes_impacts_full.json", "rb") as f:
        return orjson.loads(f.read())


@pytest.fixture
def processes_generic_impacts_json():
    with open(
        TESTS_SNAPSHOTS_DIR / "processes_generic_impacts.json",
        "rb",
    ) as f:
        return orjson.loads(f.read())


@pytest.fixture
def es_factors_csv_file():
    return TESTS_FIXTURE_DIR / "food" / "ecosystemic_factors.csv"


@pytest.fixture
def es_factors_json():
    with open(
        TESTS_SNAPSHOTS_DIR / "food" / "es_factors.json",
        "rb",
    ) as f:
        return orjson.loads(f.read())
