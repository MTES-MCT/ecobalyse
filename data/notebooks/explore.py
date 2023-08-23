"""
This file is `explore` Jupyter Notebook
"""
from IPython.core.display import display, Markdown
from bw2data.project import projects
from bw2data.utils import get_activity
import bw2calc
import bw2data
import ipywidgets
import os
import pandas

DOMAINS = ["", "Food", "Textile"]
os.chdir("/home/jovyan/ecobalyse/data")

databases = [""]
# widgets
w_project = ipywidgets.Dropdown(value="", options=DOMAINS, description="DOMAIN")
w_database = ipywidgets.Dropdown(
    value=databases[0], options=databases, description="DATABASE"
)
w_search = ipywidgets.Text(value="", placeholder="Search string", description="SEARCH")
w_method = ipywidgets.Dropdown(options=[], description="METHOD")
w_limit = ipywidgets.BoundedIntText(value=10, min=0, step=1, description="LIMIT")
w_activity = ipywidgets.Dropdown(options=[], description="ACTIVITY")
w_results = ipywidgets.Output(value="Résultat")
w_details = ipywidgets.Output(value="Détails")

display(Markdown("# Search in the database :"))


def switch_domain(change):
    w_details.clear_output()
    domain = change.new
    projects.create_project(domain, activate=True, exist_ok=True)
    w_database.options = []  # list(bw2data.databases)
    w_method.options = []  # sorted({m[0] for m in bw2data.methods})


@w_results.capture()
def search_activity(change):
    w_details.clear_output()
    database = change.new if change.owner is w_database else w_database.value
    search = change.new if change.owner is w_search else w_search.value
    limit = change.new if change.owner is w_limit else w_limit.value
    w_activity.value = None
    db = bw2data.Database(database)
    if not db:
        return
    results = list(db.search(search, limit=limit))
    if len(results) == 0:
        w_results.clear_output()
        display(Markdown("(No results)"))
        return
    w_activity.options = [("", "")] + [
        (str(i) + " " + a.get("name", ""), a) for i, a in enumerate(results)
    ]
    w_results.clear_output()
    display(Markdown("## Results"))
    with pandas.option_context("display.max_colwidth", None):
        display(pandas.DataFrame(results, columns=["name", "code", "location"]))
    display(Markdown("---"))


@w_details.capture()
def show_activity(change):
    activity = change.new if change.owner is w_activity else w_activity.value
    method = change.new if change.owner is w_method else w_method.value
    w_details.clear_output()

    # IMPACTS
    if not activity or not method:
        return
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    display(Markdown(f"# IMPACTS for {activity}"))
    scores = []
    for method in [m for m in bw2data.methods if m[0] == method]:
        lca.switch_method(method)
        lca.lcia()
        scores.append(
            {
                "Indicateur": method[1],
                "Score": str(lca.score),
                "Unité": bw2data.methods[method].get("unit", "(no unit)"),
            }
        )
    display(pandas.DataFrame(scores))
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

    # BIOSPHERE
    exchanges = activity.biosphere()
    display(Markdown(f"# There are {len(exchanges)} exchanges with the biosphere:"))
    for exchange in exchanges:
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        display(Markdown(f"{amount} {unit} of {name}"))
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


w_project.observe(switch_domain, names="value")
w_database.observe(search_activity, names="value")
w_search.observe(search_activity, names="value")
w_limit.observe(search_activity, names="value")
w_activity.observe(show_activity, names="value")
w_method.observe(show_activity, names="value")
display(w_project)
display(w_database, w_search, w_limit)
display(w_results)
display(w_activity)
display(w_method)
display(w_details)

# _ = interact(show_activity, method=w_method, activity=w_activity)
