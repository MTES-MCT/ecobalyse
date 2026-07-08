import logging
import os
from pathlib import Path

from dynaconf import Dynaconf, Validator
from platformdirs import user_cache_path

DATA_ROOT_DIR = Path.resolve(Path(__file__).parent)
TESTS_FIXTURE_DIR = DATA_ROOT_DIR / "tests" / "fixtures"
IS_CI = os.environ.get("CI") == "true"

settings = Dynaconf(
    root_path=DATA_ROOT_DIR,
    envvar_prefix="EB",
    settings_files=["settings.toml"],
    environments=True,
    load_dotenv=True,
    dotenv_verbose=True,
    default_env="default",  # env where the default values will be taken from
    env="default",
    validators=[
        Validator(
            "LOG_LEVEL",
            is_in=(logging.getLevelNamesMapping().keys()),
        ),
        # The S3 related variables are read from the environment
        Validator("S3_ENDPOINT", must_exist=not IS_CI),
        Validator("S3_REGION", must_exist=not IS_CI),
        Validator("S3_ACCESS_KEY_ID", must_exist=not IS_CI),
        Validator("S3_SECRET_ACCESS_KEY", must_exist=not IS_CI),
        Validator("S3_BUCKET", must_exist=not IS_CI),
        Validator("S3_DB_PREFIX", must_exist=not IS_CI),
        Validator(
            "DB_CACHE_DIR",
            default=user_cache_path("ecobalyse") / "db-cache",
            apply_default_on_none=True,
        ),
    ],
)


ecosystemic_services_list = ["hedges", "plotSize", "cropDiversity"]
