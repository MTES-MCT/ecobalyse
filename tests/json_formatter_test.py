from pathlib import Path

from bin.json_formatter import is_excluded, load_ignore_spec


def test_ignore_spec():
    ignore_spec = load_ignore_spec(["test", "/test2"])
    rel_dir = Path("/project")

    assert is_excluded("/project/test", ignore_spec, rel_dir)
    assert is_excluded("/project/test/", ignore_spec, rel_dir)
    assert is_excluded("/project/test/", ignore_spec, rel_dir)
    assert not is_excluded("/test2", ignore_spec, rel_dir)
    assert is_excluded("/project/test2", ignore_spec, rel_dir)
