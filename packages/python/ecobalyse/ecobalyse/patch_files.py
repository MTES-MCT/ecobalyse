import json
import logging
import os
import pathlib
import subprocess
from typing import Tuple

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config

logger = logging.getLogger(__name__)


def patch_storage_key(index_js_string: str, version: str) -> Tuple[str, int]:
    nb_patched = index_js_string.count('storeKey = "store"')
    data = index_js_string
    if nb_patched >= 0:
        data = index_js_string.replace(
            'storeKey = "store"', f'storeKey = "store{version}"'
        )

    return (data, nb_patched)


def patch_version_string(elm_version_string: str) -> Tuple[str, int]:
    nb_patched = elm_version_string.count('"/version.json')
    data = elm_version_string
    if nb_patched >= 0:
        data = elm_version_string.replace('"/version.json', '"version.json')

    return (data, nb_patched)


def write_patched_data(nb_patched: int, data: str, dest_file: pathlib.Path) -> bool:
    if nb_patched == 1 and data is not None:
        with open(dest_file, "w") as f:
            f.write(data)
            logger.info(f"Content patched successfully in `{dest_file}`.")
            return True
    else:
        logger.info(f"No content to patch in `{dest_file}`, doing nothing.")

    return False


def patch_elm_version_file(elm_version_file: pathlib.Path):
    (data, nb_patched) = (None, 0)

    with open(elm_version_file, "r") as file:
        data = file.read()
        (data, nb_patched) = patch_version_string(data)

    write_patched_data(nb_patched, data, elm_version_file)


def patch_index_js_file(index_js_file: pathlib.Path, version: str):
    (data, nb_patched) = (None, 0)

    with open(index_js_file, "r") as file:
        data = file.read()
        (data, nb_patched) = patch_storage_key(data, version)

    write_patched_data(nb_patched, data, index_js_file)


def patch_double_slash(
    index_js_file: pathlib.Path, patch_file: pathlib.Path, git_dir: pathlib.Path
):
    with (
        open(index_js_file, "r") as index_file,
    ):
        data = index_file.read()
        if data.count("replace") > 0:
            logger.info(
                f"Patch content already present in `{index_js_file}`, skipping."
            )
        else:
            logger.info(
                f"Applying patch file `{patch_file}` to `{git_dir}` using `git apply`."
            )
            subprocess.run(["git", "apply", patch_file], check=True, cwd=git_dir)


def patch_version_json(json_content: dict, key: str, value: str):
    (data, nb_patched) = (json_content, 0)

    if data.get(key) is None:
        data[key] = value
        nb_patched = 1
        logger.info(f"Adding key '{key}' with value '{value}' to `version.json`.")
    else:
        logger.info(f"Key '{key}' already present in `version.json`, skipping.")

    return (json.dumps(data), nb_patched)


def add_entry_to_version_file(version_file: pathlib.Path, key: str, value: str):
    (data, nb_patched) = (None, 0)

    with open(version_file, "r") as file:
        json_content = json.load(file)
        (data, nb_patched) = patch_version_json(json_content, key, value)

    write_patched_data(nb_patched, data, version_file)


def patch_cross_origin(index_html_string: str):
    meta_charset = '<meta charset="utf-8">'
    meta_content = '<meta name="referrer" content="origin-when-cross-origin" />'
    (data, nb_patched) = (index_html_string, 0)
    if (
        index_html_string.count(meta_charset) >= 0
        and index_html_string.count('content="origin-when-cross-origin"') == 0
    ):
        data = index_html_string.replace(meta_charset, meta_charset + meta_content)
        nb_patched = 1

    return (data, nb_patched)


def patch_cross_origin_index_html_file(index_html_file: pathlib.Path):
    (data, nb_patched) = (None, 0)

    with open(index_html_file, "r") as file:
        data = file.read()
        (data, nb_patched) = patch_cross_origin(data)

    write_patched_data(nb_patched, data, index_html_file)


def patch_version_selector(patch_file: pathlib.Path, git_dir: pathlib.Path):
    with (
        open(os.path.join(git_dir, "index.html"), "r") as index_file,
        open(os.path.join(git_dir, "src/Views/Page.elm")) as page_file,
    ):
        data = index_file.read()
        page_data = page_file.read()
        if (
            data.count('selector.classList.add("VersionSelector"') > 0
            or page_data.count("VersionSelector") > 0
        ):
            logger.info("Patch content already present in `index.html`, skipping.")
        else:
            logger.info(
                f"Applying patch file `{patch_file}` to `{git_dir}` using `git apply`."
            )
            subprocess.run(["git", "apply", patch_file], check=True, cwd=git_dir)


def patch_prerelease(git_dir: pathlib.Path):
    github_file_path = "src/Data/Github.elm"
    with open(os.path.join(git_dir, github_file_path)) as github_file:
        github_data = github_file.read()
        if github_data.count("prerelease") > 0:
            logger.info(
                f"Patch content already present in `{github_file_path}`, skipping."
            )
            return
        # Old version
        elif github_data.count("unreleased") == 0:
            logger.info(
                f"Patch does not apply to this version of `{github_file_path}`, skipping."
            )
            return

    logger.info(
        f"Overwriting `{os.path.join(git_dir, github_file_path)}` with new content."
    )
    github_elm_new_content = """module Data.Github exposing
    ( Commit
    , Release
    , decodeCommit
    , decodeReleaseList
    , unreleased
    )

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Time exposing (Posix)


type alias Commit =
    { sha : String
    , message : String
    , date : Posix
    , authorName : String
    , authorLogin : String
    , authorAvatar : Maybe String
    }


type alias Release =
    { draft : Bool
    , hash : String
    , markdown : String
    , name : String
    , prerelease : Bool
    , tag : String
    , url : String
    }


decodeCommit : Decoder Commit
decodeCommit =
    Decode.succeed Commit
        |> Pipe.requiredAt [ "sha" ] Decode.string
        |> Pipe.requiredAt [ "commit", "message" ] Decode.string
        |> Pipe.requiredAt [ "commit", "author", "date" ] Iso8601.decoder
        |> Pipe.requiredAt [ "commit", "author", "name" ] Decode.string
        |> Pipe.optionalAt [ "author", "login" ] Decode.string "Ecobalyse"
        |> Pipe.optionalAt [ "author", "avatar_url" ] (Decode.maybe Decode.string) Nothing
        |> Decode.andThen
            (\({ authorAvatar, authorName } as commit) ->
                Decode.succeed
                    (if authorAvatar == Nothing && authorName == "Ingredient editor" then
                        { commit | authorAvatar = Just "img/ingredient-editor.png" }

                     else
                        commit
                    )
            )


decodeRelease : Decoder Release
decodeRelease =
    Decode.succeed Release
        |> Pipe.required "draft" Decode.bool
        |> Pipe.required "target_commitish" Decode.string
        |> Pipe.required "body" Decode.string
        |> Pipe.required "name" Decode.string
        |> Pipe.required "prerelease" Decode.bool
        |> Pipe.required "tag_name" Decode.string
        |> Pipe.required "html_url" Decode.string


decodeReleaseList : Decoder (List Release)
decodeReleaseList =
    Decode.list decodeRelease
        -- Exclude draft and pre-releases
        |> Decode.map (List.filter (\{ draft, prerelease } -> not draft && not prerelease))

unreleased : Release
unreleased =
    { draft = True
    , hash = ""
    , markdown = ""
    , name = "Unreleased"
    , prerelease = True
    , tag = "Unreleased"
    , url = ""
    }"""

    with open(os.path.join(git_dir, github_file_path), "w") as filetowrite:
        filetowrite.write(github_elm_new_content)
