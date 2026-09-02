"""Two characterization factors on one flow are summed by `bw2calc`, so the substance is
counted several times in every score. Renaming several SimaPro names onto one ecoinvent
name is what creates them: `Ethane, 1,1,2-trifluoro-, HFC-143` and `Ethane,
1,1,1-trifluoro-, HFC-143a` are two gases (GWP 364 and 5810) that one rename turns into
a single flow characterized at 6174.
"""

from types import SimpleNamespace

from import_method import colliding_cfs


def method(*factors):
    return SimpleNamespace(
        data=[
            {
                "name": ("EF 3.1", "Climate change"),
                "exchanges": [
                    {
                        "name": name,
                        "categories": ("air",),
                        "amount": amount,
                        "simapro name": simapro,
                    }
                    for name, amount, simapro in factors
                ],
            }
        ]
    )


HFC = "Ethane, 1,1,1-trifluoro-, HFC-143a"


def test_two_factors_on_one_flow_are_reported_with_the_names_that_merged():
    importer = method(
        (HFC, 5810.0, HFC), (HFC, 364.0, "Ethane, 1,1,2-trifluoro-, HFC-143")
    )

    collisions = colliding_cfs(importer)

    assert collisions == {
        (("EF 3.1", "Climate change"), HFC, ("air",)): {
            5810.0: [HFC],
            364.0: ["Ethane, 1,1,2-trifluoro-, HFC-143"],
        }
    }


def test_merging_names_that_agree_is_not_a_collision():
    """`Sulfur dioxide, DE` carrying the same factor as `Sulfur dioxide` is exactly what
    the rename table is for."""
    importer = method(
        ("Sulfur dioxide", 1.31, "Sulfur dioxide"),
        ("Sulfur dioxide", 1.31, "Sulfur dioxide, DE"),
    )

    assert colliding_cfs(importer) == {}


def test_the_compartment_separates_two_flows():
    """The same substance emitted to air and to water is two flows, each with its own
    factor."""
    importer = SimpleNamespace(
        data=[
            {
                "name": ("EF 3.1", "Climate change"),
                "exchanges": [
                    {
                        "name": "Methane",
                        "categories": ("air",),
                        "amount": 29.8,
                        "simapro name": "Methane",
                    },
                    {
                        "name": "Methane",
                        "categories": ("water",),
                        "amount": 1.0,
                        "simapro name": "Methane",
                    },
                ],
            }
        ]
    )

    assert colliding_cfs(importer) == {}
