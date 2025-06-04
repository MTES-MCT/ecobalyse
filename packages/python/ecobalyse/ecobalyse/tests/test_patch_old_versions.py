import json
import logging
import os
import tempfile

from ecobalyse import logging_config as logging_config
from ecobalyse.patch_files import (
    patch_cross_origin,
    patch_storage_key,
    patch_version_json,
    patch_version_selector,
    patch_version_string,
    write_patched_data,
)

ELM_VERSION_CONTENT = """loadVersion : (WebData VersionData -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event versionDataDecoder"""

JS_INDEX_CONTENT = """// The localStorage key to use to store serialized session data
const storeKey = "store";

const app = Elm.Main.init({"""

INDEX_HTML_CONTENT = """<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8"><title>Ecobalyse</title><link rel="canonical" href="https://ecobalyse.beta.gouv.fr/"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content="Accélerer la mise en place de l'affichage environnemental"><meta name="theme-color" content="#333333"><link rel="icon" type="image/svg" href="logo.42bf0895.svg"><link rel="preload" href="Marianne-Regular.e7aa0a9a.woff2" as="font" type="font/woff2" crossorigin><link rel="preload" href="Marianne-Bold.93333c67.woff2" as="font" type="font/woff2" crossorigin><link rel="stylesheet" href="index.cc2b0572.css"><link rel="stylesheet" href="index.0fa174c7.css"><script type="module" src="index.9ea8d260.js"></script></head><body> <noscript> <img src="https://stats.beta.gouv.fr/matomo.php?idsite=57&amp;rec=1" style="border:0" alt> </noscript> <script>window.addEventListener("DOMContentLoaded",async()=>{if(!document.querySelector(".VersionSelector"))try{let e=await fetch("https://api.github.com/repos/MTES-MCT/ecobalyse/releases"),t=(await e.json()).map(({tag_name:e})=>e),o=document.createElement("select");for(let e of(o.classList.add("VersionSelector","d-none","d-sm-block","form-select","form-select-sm","w-auto"),o.setAttribute("style","background-color:transparent;box-shadow:none;"),t)){let t=document.createElement("option");t.textContent=e,location.pathname.includes("/versions/")&&(t.selected=e===location.pathname.split("/").filter(e=>!!e).pop()),o.append(t)}o.addEventListener("input",e=>location.href=`/versions/${e.target.value}/`),document.querySelector(".HeaderBrand").after(o),document.querySelector(".HeaderAuthLink").classList.remove("d-none","d-sm-block"),document.querySelector(".HeaderAuthLink").classList.add("text-end","flex-fill")}catch(e){console.error("Unable to build version selector menu",e)}});</script> </body></html>"""


def test_version_content_should_be_patched():
    (patched_content, nb) = patch_version_string(ELM_VERSION_CONTENT)
    assert '"version.json' in patched_content
    assert nb == 1


def test_index_js_content_should_be_patched():
    (patched_content, nb) = patch_storage_key(JS_INDEX_CONTENT, "testversion")
    assert "storetestversion" in patched_content
    assert nb == 1


def test_version_json_patch():
    json_content = {"hash": "somecommitsha"}
    (patched_content, nb) = patch_version_json(json_content, "tag", "sometag")
    json_content = json.loads(patched_content)

    assert nb == 1
    assert json_content == {"hash": "somecommitsha", "tag": "sometag"}

    (patched_content, nb) = patch_version_json(json_content, "tag", "somenewtag")

    # We should not replace an existing tag
    assert nb == 0
    assert json.loads(patched_content) == json_content

    json_content = {"hash": "somecommitsha", "tag": None}
    (patched_content, nb) = patch_version_json(json_content, "tag", "sometag")

    # But we should overwrite a null value
    assert nb == 1
    assert json_content == {"hash": "somecommitsha", "tag": "sometag"}


def test_patch_cross_origin():
    (patched_content, nb) = patch_cross_origin(INDEX_HTML_CONTENT)
    assert 'content="origin-when-cross-origin"' in patched_content
    assert nb == 1

    # We should not patch an already patched file
    (patched_content, nb) = patch_cross_origin(patched_content)
    assert nb == 0
    assert 'content="origin-when-cross-origin"' in patched_content


def test_patch_version_selector_should_patch_non_patched_file(mocker):
    mock_run = mocker.patch("subprocess.run")

    patch_file = tempfile.TemporaryFile()
    git_dir = tempfile.TemporaryDirectory()

    os.makedirs(os.path.join(git_dir.name, "src/Views"))

    with open(os.path.join(git_dir.name, "src/Views/Page.elm"), "w") as page_file:
        page_file.write("")

    with open(os.path.join(git_dir.name, "index.html"), "w") as index_file:
        index_file.write("")

    patch_version_selector(patch_file.name, git_dir.name)

    mock_run.assert_called_once_with(
        ["git", "apply", patch_file.name], check=True, cwd=git_dir.name
    )

    with open(os.path.join(git_dir.name, "index.html"), "w") as index_file:
        index_file.write('selector.classList.add("VersionSelector"')

    patch_version_selector(patch_file.name, git_dir.name)

    mock_run.assert_called_once_with(
        ["git", "apply", patch_file.name], check=True, cwd=git_dir.name
    )


def test_patch_version_selector_should_not_patch_already_patched_file(mocker):
    mock_run = mocker.patch("subprocess.run")

    patch_file = tempfile.TemporaryFile()
    git_dir = tempfile.TemporaryDirectory()

    with open(os.path.join(git_dir.name, "index.html"), "w") as index_file:
        index_file.write('selector.classList.add("VersionSelector"')

    os.makedirs(os.path.join(git_dir.name, "src/Views"))

    with open(os.path.join(git_dir.name, "src/Views/Page.elm"), "w") as page_file:
        page_file.write("")

    patch_version_selector(patch_file.name, git_dir.name)

    assert not mock_run.called

    with open(os.path.join(git_dir.name, "index.html"), "w") as index_file:
        index_file.write("")

    with open(os.path.join(git_dir.name, "src/Views/Page.elm"), "w") as page_file:
        page_file.write("VersionSelector")

    patch_version_selector(patch_file.name, git_dir.name)

    assert not mock_run.called


def test_write_patched_data(caplog):
    with caplog.at_level(logging.INFO):
        with tempfile.NamedTemporaryFile(delete_on_close=False) as dest_file:
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
