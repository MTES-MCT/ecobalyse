import bw2data

from config import settings
from import_method import report_dropped_cfs


class FakeMethodImporter:
    def __init__(self, data):
        self.data = data


def an_existing_flow(biosphere_name):
    for flow in bw2data.Database(biosphere_name):  # ty:ignore[not-iterable]
        if flow.get("type") == "emission" and flow.get("categories"):
            return flow
    raise AssertionError(f"no emission flow in {biosphere_name}")


def a_factor(name, linked, categories=("air",)):
    factor = {"name": name, "categories": categories, "unit": "kg", "amount": 3.02}
    return factor | {"input": ("biosphere3", "code")} if linked else factor


def method_with(*exchanges):
    return FakeMethodImporter(
        [{"name": ("Some method", "Acidification"), "exchanges": list(exchanges)}]
    )


def test_misplaced_factor_is_reported(forwast, tmp_path, monkeypatch):
    """The biosphere has the substance, but every factor for it sits on a compartment
    that reaches none of its flows, so it stops being counted with nothing to say so."""
    monkeypatch.chdir(tmp_path)
    existing = an_existing_flow(settings.bw.BIOSPHERE)

    report_dropped_cfs(method_with(a_factor(existing["name"], linked=False)))

    (report,) = (tmp_path / "output").glob("dropped-cfs-*.csv")
    assert existing["name"] in report.read_text()


def test_substance_absent_from_the_biosphere_is_not_reported(
    forwast, tmp_path, monkeypatch
):
    """A method characterizes far more substances than any database emits. Reporting
    those would bury the ones that are actually lost: on Agribalyse and BAFU they
    outnumber them 350 to 1."""
    monkeypatch.chdir(tmp_path)

    report_dropped_cfs(method_with(a_factor("Unobtainium", linked=False)))

    assert not (tmp_path / "output").exists()


def test_subcategory_fan_out_is_not_reported(forwast, tmp_path, monkeypatch):
    """`match_subcategories` copies each factor onto every subcategory of its
    compartment. The copies that reach no flow are meant to go, and saying so on every
    import would make the report unreadable."""
    monkeypatch.chdir(tmp_path)
    existing = an_existing_flow(settings.bw.BIOSPHERE)

    report_dropped_cfs(
        method_with(
            a_factor(existing["name"], linked=True),
            a_factor(existing["name"], linked=False, categories=("air", "urban air")),
        )
    )

    assert not (tmp_path / "output").exists()
