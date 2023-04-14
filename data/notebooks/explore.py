"""
This file is used in the `explore` Jupyter Notebook
"""
from IPython.display import display, Markdown
from bw2data.utils import get_activity
from ipywidgets import interact
import bw2calc
import bw2data
import bw2io
import ipywidgets
import os

bw2data.projects.set_current("Ecobalyse")
bw2io.bw2setup()
os.chdir("/home/jovyan/ecobalyse/data")
from imports import import_agribalyse, import_ecoinvent, AGRIBALYSE_MIGRATIONS

if "Agribalyse" not in bw2data.databases:
    import_agribalyse(
        "/home/jovyan/ecobalyse/data/AGB3.1.1.20230306.CSV.zip",
        "Agribalyse",
        AGRIBALYSE_MIGRATIONS,
    )
else:
    print("Agribalyse already imported")

database = ipywidgets.Dropdown(
    value="Agribalyse 3.0", options=[d for d in bw2data.databases.keys()]
)
methods = sorted({method[0] for method in bw2data.methods})
method = ipywidgets.Dropdown(value=methods[11], options=methods)
limit = ipywidgets.BoundedIntText(value=10, min=0, step=1, description="RESULTS")
activity = ipywidgets.Dropdown(
    options=[""]
    + list(bw2data.Database(database.value).search(search.value, limit=limit.value)),
    description="ACTIVITY",
)

display(Markdown("# Search in the database :"))


def search_activity(DATABASE=database, SEARCH="", LIMIT=limit):
    database = bw2data.Database(DATABASE)
    activities = list(database.search(SEARCH, limit=LIMIT))
    if len(activities) == 0:
        display(Markdown(("No result")))
        return
    results = [""] + list(bw2data.Database(DATABASE).search(SEARCH, limit=LIMIT))
    act = activity
    act.options = results
    display(Markdown("# Results"))
    for act in results:
        print(f"{act}")
    display(Markdown("---"))


interact(search_activity, DATABASE=database, SEARCH="", LIMIT=limit)

activity.observe(search_activity, "activity")


def show_activity(METHOD=method, ACTIVITY=activity):
    # IMPACTS
    if not ACTIVITY:
        return
    lca = bw2calc.LCA({ACTIVITY: 1})
    lca.lci()
    display(Markdown(f"# IMPACTS for {ACTIVITY}"))
    for method in [method for method in bw2data.methods if method[0] == METHOD]:
        lca.switch_method(method)
        lca.lcia()
        print(
            f"{method[1].ljust(45,' ')} = {str(lca.score).ljust(25, ' ')} {bw2data.methods[method]['unit']}"
        )
    display(Markdown("---"))

    # ACTIVITY DATA
    display(Markdown(f"# {ACTIVITY}"))
    for title, content in ACTIVITY.items():
        display(Markdown(f"## {title}"))
        if type(content) is dict:
            for subtitle, subcontent in content.items():
                display(Markdown(f"**{subtitle}**: {subcontent}"))
        elif type(content) is list:
            for item in content:
                if type(item) is tuple and len(item) == 2:
                    display(Markdown(f"**{item[0]}**: {item[1]}"))
                else:
                    print(str(item))
        else:
            print(content)
    display(Markdown("---"))

    # PRODUCTION
    exchanges = ACTIVITY.production()
    display(Markdown(f"# There are {len(exchanges)} production exchanges:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"## {amount} {unit} of {name}"))
        flow = exchange.get("input")
        act = get_activity(flow)
        comment = act.get("comment", "N/A")
        display(Markdown(f"{comment}"))
    display(Markdown("---"))

    # BIOSPHERE
    exchanges = ACTIVITY.biosphere()
    display(Markdown(f"# There are {len(exchanges)} exchanges with the biosphere:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"{amount} {unit} of {name}"))
    display(Markdown("---"))

    # TECHNOSPHERE
    exchanges = ACTIVITY.technosphere()
    display(Markdown(f"# There are {len(exchanges)} exchanges with the technosphere:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"## {amount} {unit} of {name}"))
        flow = exchange.get("input")
        act = get_activity(flow)
        comment = act.get("comment", "N/A")
        display(Markdown(f"{comment}"))
    display(Markdown("---"))

    # SUBSTITUTIONS
    exchanges = ACTIVITY.substitution()
    display(Markdown(f"# There are {len(exchanges)} substitution exchanges:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"## {amount} {unit} of {name}"))
        flow = exchange.get("input")
        act = get_activity(flow)
        comment = act.get("comment", "N/A")
        display(Markdown(f"{comment}"))
    display(Markdown("---"))


_ = interact(show_activity, METHOD=method, ACTIVITY=activity)
