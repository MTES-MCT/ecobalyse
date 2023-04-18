"""
This file is used in the `explore` Jupyter Notebook
"""
from IPython.core.display import display, Markdown
from bw2data.utils import get_activity
import bw2calc
import bw2data
import bw2io
import ipywidgets
import os
import pandas

bw2data.projects.set_current("Ecobalyse")
bw2io.bw2setup()
os.chdir("/home/jovyan/ecobalyse/data")
from food.import_agb.importing_databases import import_agribalyse

if "Agribalyse" not in bw2data.databases:
    import_agribalyse()
else:
    print("Agribalyse already imported")

databases = list(bw2data.databases.keys())
# widgets
f_database = ipywidgets.Dropdown(
    value=databases[0], options=databases, description="DATABASE"
)
f_search = ipywidgets.Text(value="", placeholder="Search string", description="SEARCH")
METHODS = sorted({m[0] for m in bw2data.methods})
f_method = ipywidgets.Dropdown(value=METHODS[11], options=METHODS, description="METHOD")
f_limit = ipywidgets.BoundedIntText(value=10, min=0, step=1, description="LIMIT")
f_activity = ipywidgets.Dropdown(
    options=[""]
    + list(
        bw2data.Database(f_database.value).search(f_search.value, limit=f_limit.value)
    ),
    description="ACTIVITY",
)
f_results = ipywidgets.Output(value="Résultat")
f_details = ipywidgets.Output(value="Détails")

display(Markdown("# Search in the database :"))


@f_results.capture()
def search_activity(change):
    f_details.clear_output()
    database = change.new if change.owner is f_database else f_database.value
    search = change.new if change.owner is f_search else f_search.value
    limit = change.new if change.owner is f_limit else f_limit.value
    f_activity.value = None
    db = bw2data.Database(database)
    results = list(db.search(search, limit=limit))
    if len(results) == 0:
        f_results.clear_output()
        display(Markdown("(No results)"))
        return
    f_activity.options = [""] + results
    f_results.clear_output()
    display(Markdown("## Results"))
    with pandas.option_context("display.max_colwidth", None):
        display(pandas.DataFrame(results, columns=["name", "code", "location"]))
    display(Markdown("---"))


@f_details.capture()
def show_activity(change):
    activity = change.new if change.owner is f_activity else f_activity.value
    method = change.new if change.owner is f_method else f_method.value
    f_details.clear_output()

    # IMPACTS
    if not activity or not method:
        return
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    display(Markdown(f"# IMPACTS for {activity}"))
    for method in [m for m in bw2data.methods if m[0] == method]:
        lca.switch_method(method)
        lca.lcia()
        print(
            f"{method[1].ljust(45,' ')} = {str(lca.score).ljust(25, ' ')} {bw2data.methods[method].get('unit', '(no unit)')}"
        )
    display(Markdown("---"))

    # ACTIVITY DATA
    display(Markdown(f"# {activity}"))
    for title, content in activity.items():
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
    exchanges = activity.production()
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
    exchanges = activity.biosphere()
    display(Markdown(f"# There are {len(exchanges)} exchanges with the biosphere:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"{amount} {unit} of {name}"))
    display(Markdown("---"))

    # TECHNOSPHERE
    exchanges = activity.technosphere()
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
    exchanges = activity.substitution()
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


f_database.observe(search_activity, names="value")
f_search.observe(search_activity, names="value")
f_limit.observe(search_activity, names="value")
f_activity.observe(show_activity, names="value")
f_method.observe(show_activity, names="value")
display(f_database, f_search, f_limit)
display(f_results)
display(f_activity)
display(f_method)
display(f_details)

# _ = interact(show_activity, method=f_method, activity=f_activity)
