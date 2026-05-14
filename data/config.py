import logging
import os
from pathlib import Path

from dynaconf import Dynaconf, Validator
from platformdirs import user_cache_path

PROJECT_ROOT_DIR = Path.resolve(Path(__file__).parent)
TESTS_FIXTURE_DIR = PROJECT_ROOT_DIR / "tests" / "fixtures"
IS_CI = os.environ.get("CI") == "true"

settings = Dynaconf(
    root_path=PROJECT_ROOT_DIR,
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
        # Check that the output dir was set
        Validator(
            "OUTPUT_DIR",
            must_exist=True,
            messages={
                "must_exist_true": "🚨 For the export to work properly, you need to specify "
                "the EB_{name} env variable.\nIt needs to point to the 'public/data/' directory "
                "of the https://github.com/MTES-MCT/ecobalyse/ repository. \nPlease, edit your .env file "
                "accordingly."
            },
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
