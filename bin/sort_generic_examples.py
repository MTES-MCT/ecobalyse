#!/usr/bin/env python3
"""Sort generic examples.json files by ascending id.

Usage:
    $ uv run python bin/sort_generic_examples.py
"""

import json
from pathlib import Path

from app.lib.json import format_json

SCOPES = ("food2", "object", "veli")


def sort_examples_file(path):
    examples = json.loads(path.read_text(encoding="utf-8"))
    sorted_examples = sorted(examples, key=lambda example: example["id"])
    path.write_text(format_json(sorted_examples), encoding="utf-8")
    print(f"sorted {len(sorted_examples)} examples in {path}")


for scope in SCOPES:
    sort_examples_file(Path("public/data") / scope / "examples.json")
