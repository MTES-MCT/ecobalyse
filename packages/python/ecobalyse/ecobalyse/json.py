# Please only pure functions here
import json
from typing import Any
from uuid import UUID

from .logging import logger

# See this gist for inspiration
# https://gist.github.com/jannismain/e96666ca4f059c3e5bc28abb711b5c92


class CompactJSONEncoder(json.JSONEncoder):
    """A JSON Encoder that puts small containers on single lines and formats
    numbers with a reduced precision."""

    CONTAINER_TYPES = (list, tuple, dict)
    """Container datatypes include primitives or other containers."""

    MAX_WIDTH = 80
    """Maximum width of a container that might be put on a single line."""

    MAX_ITEMS = 10
    """Maximum number of items in container that might be put on single line."""

    NUMBER_PRECISION = None
    """Number of significant digits to keep for floats (and ints). None disables formatting."""

    def __init__(self, *args, number_precision=None, **kwargs):
        # using this class without indentation is pointless
        if kwargs.get("indent") is None:
            kwargs["indent"] = 4
        super().__init__(*args, **kwargs)
        self.indentation_level = 0
        if number_precision is not None:
            self.NUMBER_PRECISION = number_precision

    def encode(self, o):
        """Encode JSON object *o* with respect to single line lists and number formatting."""
        o = self._format_value(o)
        if isinstance(o, (list, tuple)):
            return self._encode_list(o)
        if isinstance(o, dict):
            return self._encode_object(o)
        return json.dumps(
            o,
            skipkeys=self.skipkeys,
            ensure_ascii=self.ensure_ascii,
            check_circular=self.check_circular,
            allow_nan=self.allow_nan,
            sort_keys=self.sort_keys,
            indent=self.indent,
            separators=(self.item_separator, self.key_separator),
            default=self.default if hasattr(self, "default") else None,
        )

    def _format_value(self, o):
        """Recursively apply number precision formatting and simple type coercions"""
        # in python, bools are a subclass of int, so we should check explicitly
        # if obj is not a bool, otherwise it will be converted to a float...
        if isinstance(o, (int, float)) and not isinstance(o, bool):
            if self.NUMBER_PRECISION is None:
                return o
            if o == 0:
                return 0
            return float(f"{o:.{self.NUMBER_PRECISION}g}")
        elif isinstance(o, dict):
            return {k: self._format_value(v) for k, v in o.items()}
        elif isinstance(o, (list, tuple)):
            return [self._format_value(v) for v in o]
        elif isinstance(o, UUID):
            return str(o)
        else:
            return o

    def _encode_list(self, o):
        if self._put_on_single_line(o):
            return "[" + ", ".join(self.encode(el) for el in o) + "]"
        self.indentation_level += 1
        output = [self.indent_str + self.encode(el) for el in o]
        self.indentation_level -= 1
        return "[\n" + ",\n".join(output) + "\n" + self.indent_str + "]"

    def _encode_object(self, o):
        if not o:
            return "{}"

        # ensure keys are converted to strings
        o = {str(k) if k is not None else "null": v for k, v in o.items()}

        if self.sort_keys:
            o = dict(sorted(o.items(), key=lambda x: x[0]))

        if self._put_on_single_line(o):
            return (
                "{ "
                + ", ".join(
                    f"{self.encode(k)}: {self.encode(el)}" for k, el in o.items()
                )
                + " }"
            )

        self.indentation_level += 1
        output = [
            f"{self.indent_str}{self.encode(k)}: {self.encode(v)}" for k, v in o.items()
        ]
        self.indentation_level -= 1

        return "{\n" + ",\n".join(output) + "\n" + self.indent_str + "}"

    def iterencode(self, o, _one_shot: bool = False):
        """Required to also work with `json.dump`."""
        yield self.encode(o)

    def _put_on_single_line(self, o):
        return (
            self._primitives_only(o)
            and len(o) <= self.MAX_ITEMS
            and len(str(o)) - 2 <= self.MAX_WIDTH
        )

    def _primitives_only(self, o: list | tuple | dict):
        return not any(isinstance(el, self.CONTAINER_TYPES) for el in o)

    @property
    def indent_str(self) -> str:
        if isinstance(self.indent, int):
            return " " * (self.indentation_level * self.indent)
        elif isinstance(self.indent, str):
            return self.indentation_level * self.indent
        else:
            raise TypeError(
                f"indent must either be of type int or str (is: {type(self.indent)})"
            )


def activities_processes_sort_key(entry: dict[str, Any]) -> tuple:
    return (
        entry.get("source", ""),
        entry.get("activityName", ""),
        entry.get("location"),
        entry.get("alias") or "",
        entry.get("displayName", ""),
    )


def dict_to_json_string(
    json_data: dict[str, Any] | list[dict[str, Any]],
    sort_fn=None,
    number_precision=None,
) -> str:
    if sort_fn is not None and isinstance(json_data, list):
        json_data.sort(key=sort_fn)

    return json.dumps(
        json_data,
        indent=2,
        ensure_ascii=False,
        cls=CompactJSONEncoder,
        sort_keys=True,
        number_precision=number_precision,
    )


def export_json(
    json_data: dict[str, Any] | list[dict[str, Any]],
    filename,
    sort_fn=None,
    number_precision=None,
):
    logger.info(f"Exporting {filename}")
    json_string = dict_to_json_string(json_data, sort_fn, number_precision)

    with open(filename, "w", encoding="utf-8") as file:
        file.write(json_string)
        file.write("\n")  # Add a newline at the end of the file

    logger.info(f"Exported {len(json_data)} elements to {filename}")
