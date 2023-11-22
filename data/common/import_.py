import bw2data


def add_missing_substances(project, biosphere):
    """Two additional substances provided by ecoinvent and that seem to be in 3.9.2 but not in 3.9.1"""
    substances = {
        "a35f0a31-fe92-56db-b0ca-cc878d270fde": {
            "name": "Hydrogen cyanide",
            "synonyms": ["Hydrocyanic acid", "Formic anammonide", "Formonitrile"],
            "categories": ("air",),
            "unit": "kilogram",
            "CAS Number": "000074-90-8",
            "formula": "HCN",
        },
        "ea53a165-9f19-54f2-90a3-3e5c7a05051f": {
            "name": "N,N-Dimethylformamide",
            "synonyms": ["Formamide, N,N-dimethyl-", "Dimethyl formamide"],
            "categories": ("air",),
            "unit": "kilogram",
            "CAS Number": "000068-12-2",
            "formula": "C3H7NO",
        },
    }
    bw2data.projects.set_current(project)
    bio = bw2data.Database(biosphere)
    for code, activity in substances.items():
        if not [flow for flow in bio if flow["code"] == code]:
            bio.new_activity(code, **activity)
