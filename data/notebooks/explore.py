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
METHOD = "Environmental Footprint 3.1 (adapted) patch wtu"
TEXTILEDB = "Ecoinvent 3.9.1"
FOODDB = "Agribalyse 3.1.1"
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
    databases = list(bw2data.databases)
    w_database.options = databases
    methods = sorted({m[0] for m in bw2data.methods})
    w_method.options = methods
    # default values
    if domain == "Food" and METHOD in methods:
        w_method.value = METHOD
    elif domain == "Textile" and METHOD in methods:
        w_method.value = METHOD
    if domain == "Food" and FOODDB in databases:
        w_database.value = FOODDB
    elif domain == "Textile" and TEXTILEDB in databases:
        w_database.value = TEXTILEDB


@w_results.capture()
def display_results(results):
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


def search_activity(change):
    w_details.clear_output()
    database = change.new if change.owner is w_database else w_database.value
    search = change.new if change.owner is w_search else w_search.value
    limit = change.new if change.owner is w_limit else w_limit.value
    w_activity.value = None
    results = list(bw2data.Database(w_database.value).search(search, limit=limit))
    if not database:
        return
    display_results(results)


def linkto(button):
    results = list(
        bw2data.Database(w_database.value).search(button.search, limit=w_limit.value)
    )
    display_results(results)
    w_activity.value = results[0] if len(results) > 0 else None


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
    display(Markdown(f"# {activity}"))
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

    # PRODUCTION
    production = [
        f"<h3>Production: {exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')} of {exchange.get('name', 'N/A')}</h3>{get_activity(exchange.get('input')).get('comment', '')}"
        for exchange in activity.production()
    ]

    # ACTIVITY DATA
    activity_fields = "".join(
        ["".join(production)]
        + sum(
            [
                (
                    (
                        (
                            [f"<div><ul<b>>dict{title}</b>"]
                            + [
                                f"<div><b>{subtitle}</b>: {subcontent}</div>"
                                for (subtitle, subcontent) in content.items()
                            ]
                            + ["</ul></div>"]
                        )
                        if type(content) is dict
                        else (
                            [f"<div><ul><b>list{title}</b>"]
                            + [
                                f"<li><b>{item[0]}</b>: {item[1]}</li>"
                                if type(item) is tuple and len(item) == 2
                                else f"<li>{item}</li>"
                                for item in content
                            ]
                            + ["</ul></div>"]
                        )
                        if type(content) is list
                        else [f"<div><b>str{title}</b>: {content}</div>"]
                    )
                )
                for title, content in activity.items()
            ],
            [],
        ),
    )

    # TECHNOSPHERE
    technosphere_widgets = []
    technosphere = activity.technosphere()
    for exchange in technosphere:
        # activity title
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        title = ipywidgets.HTML(value=f"<h3>{amount} {unit} of {name}</h3>")
        # activity button
        link = ipywidgets.Button(description="visit")
        setattr(link, "search", name)
        link.on_click(linkto)
        # activity comments
        flow = exchange.get("input")
        act = get_activity(flow)
        comment = ipywidgets.HTML(value=f"{act.get('comment', '')}")
        technosphere_widgets.append(
            ipywidgets.VBox(
                [
                    ipywidgets.HBox(
                        [link, title],
                        layout=ipywidgets.Layout(
                            display="flex",
                            flex_flow="row",
                            align_items="center",
                            width="50%",
                        ),
                    ),
                    comment,
                ],
            )
        )

    # BIOSPHERE
    biosphere = [
        f"<h3>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')} of {exchange.get('name', 'N/A')}</h3>"
        for exchange in activity.biosphere()
    ]

    # SUBSTITUTIONS
    substitution = [
        f"<h3>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')} of {exchange.get('name', 'N/A')}</h3>{get_activity(exchange.get('input')).get('comment', '')}"
        for exchange in activity.substitution()
    ]

    display(
        ipywidgets.Tab(
            titles=[
                "Data",
                f"Technosphere ({int(len(technosphere)/3)})",
                f"Biosphere ({len(biosphere)})",
                f"Substitution ({len(substitution)})",
                "Impacts",
            ],
            children=[
                ipywidgets.HTML(value=activity_fields),
                # ipywidgets.HTML(value="".join(production)),
                ipywidgets.VBox(technosphere_widgets),
                ipywidgets.HTML(value="".join(biosphere)),
                ipywidgets.HTML(value="".join(substitution)),
                ipywidgets.HTML(pandas.DataFrame(scores).to_html()),
            ],
        )
    )


w_project.observe(switch_domain, names="value")
w_database.observe(search_activity, names="value")
w_search.observe(search_activity, names="value")
w_limit.observe(search_activity, names="value")
w_activity.observe(show_activity, names="value")
w_method.observe(show_activity, names="value")
display(w_project)
display(w_database, w_search, w_limit)
display(w_method)
display(w_activity)
display(w_results)
display(w_details)

# _ = interact(show_activity, method=w_method, activity=w_activity)
