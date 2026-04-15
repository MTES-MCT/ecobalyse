from __future__ import annotations

import json
from typing import Any


def format_json(json_value: Any) -> str:
    # FIXME: this is extracted from the ecobalyse-data repository, we should eventually use
    #        a single source of truth for JSON formatting
    return json.dumps(json_value, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
