import logging
import tempfile

from ecobalyse import logging_config as logging_config
from ecobalyse.patch_files import (
    patch_storage_key,
    patch_version_string,
    write_patched_data,
)

ELM_VERSION_CONTENT = """loadVersion : (WebData VersionData -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event versionDataDecoder"""

JS_INDEX_CONTENT = """// The localStorage key to use to store serialized session data
const storeKey = "store";

const app = Elm.Main.init({"""


def test_version_content_should_be_patched():
    (patched_content, nb) = patch_version_string(ELM_VERSION_CONTENT)
    assert '"version.json' in patched_content
    assert nb == 1


def test_index_js_content_should_be_patched():
    (patched_content, nb) = patch_storage_key(JS_INDEX_CONTENT, "testversion")
    assert "storetestversion" in patched_content
    assert nb == 1


def test_write_patched_data(caplog):
    with caplog.at_level(logging.INFO):
        dest_file = tempfile.TemporaryFile()
        written = write_patched_data(1, ELM_VERSION_CONTENT, dest_file.name)

        assert written
        assert "successfully" in caplog.text

        (patched_content, nb) = patch_version_string(ELM_VERSION_CONTENT)

        # Try to write already patched content
        written = write_patched_data(0, patched_content, dest_file.name)
        assert not written
        assert "doing nothing" in caplog.text

        # Try to write unknown content
        written = write_patched_data(0, "random content", dest_file.name)
        assert not written
        assert "doing nothing" in caplog.text
