from config import settings


def test_dynaconf_is_in_testing_env():
    assert settings.ENV_NAME == "testing"
