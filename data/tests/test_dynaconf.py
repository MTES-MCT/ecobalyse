from config import settings


def test_dynaconf_is_in_testing_env():
    assert settings.ENV_NAME == "testing"


def test_dynaconf_local_export_off():
    assert settings.LOCAL_EXPORT is False
