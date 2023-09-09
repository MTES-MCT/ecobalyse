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

Illustration = open("/home/jovyan/ecobalyse/data/notebooks/bw2.svg").read()
BIOSPHERE = "biosphere3"
STATSTYLE = "<style>.details {background-color: #EEE; padding: 2em;}</style>"
PROJECTS = ["", "Food", "Textile"]
METHOD = "Environmental Footprint 3.1 (adapted) patch wtu"
TEXTILEDB = "Ecoinvent 3.9.1"
FOODDB = "Agribalyse 3.1.1"
os.chdir("/home/jovyan/ecobalyse/data")
VISITED = []  # visited activities since the last search

databases = [""]
# widgets
w_statistics = ipywidgets.HTML(value=STATSTYLE)
w_project = ipywidgets.Dropdown(value="", options=PROJECTS, description="PROJECT")
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


def go_back(button):
    linkto(button, stack=False)


back = ipywidgets.Button(description="←back")
back.layout.display = "none"
back.search = ""
back.on_click(go_back)


def switch_domain(change):
    w_details.clear_output()
    domain = change.new
    projects.activate_project(domain)
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
    if "biosphere_database" in bw2data.config.p:
        biosphere_name = bw2data.config.p["biosphere_database"]
        biosphere = bw2data.Database(biosphere_name)
        w_statistics.value = STATSTYLE + (
            f"<div><b>database size</b>: {len(bw2data.Database(w_database.value))}</div>"
            f"<div><b>biosphere name</b>: {biosphere_name}</div>"
            f"<div><b>biosphere size</b>: {len(biosphere)}</div>"
        )
    back.layout.display = "none" if len(VISITED) == 0 else "block"


@w_results.capture()
def display_results(results):
    if len(results) == 0:
        w_results.clear_output()
        if w_search.value:
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
    global VISITED  # 🤮
    VISITED = [search] if search else []
    if VISITED:
        back.search = VISITED[-1]
        limit = change.new if change.owner is w_limit else w_limit.value
        w_activity.value = None
        results = list(bw2data.Database(w_database.value).search(search, limit=limit))
        if not database:
            return
        display_results(results)


def linkto(button, stack=True):
    if stack:
        VISITED.append(button.search)
    elif len(VISITED) > 0:
        VISITED.pop()
    back.search = VISITED[-1] if len(VISITED) > 0 else ""
    results = list(
        bw2data.Database(w_database.value).search(button.search, limit=w_limit.value)
    )
    display_results(results)
    w_activity.value = results[0] if len(results) > 0 else None
    back.layout.display = "none" if len(VISITED) == 0 else "block"


@w_details.capture()
def select_activity(change):
    activity = change.new if change.owner is w_activity else w_activity.value
    method = change.new if change.owner is w_method else w_method.value
    w_results.clear_output()
    w_details.clear_output()

    # IMPACTS
    if not activity or not method:
        return
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    display(Markdown(f"# {activity}"))
    scores = []
    for m in [m for m in bw2data.methods if m[0] == method]:
        lca.switch_method(m)
        lca.lcia()
        scores.append(
            {
                "Indicateur": m[1],
                "Score": str(lca.score),
                "Unité": bw2data.methods[m].get("unit", "(no unit)"),
            }
        )

    # PRODUCTION
    production = [
        f"<h3>Production: {exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')} of {exchange.get('name', 'N/A')}</h3>"
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
                            [f"<div><ul<b>>{title}</b>"]
                            + [
                                f"<div><b>{subtitle}</b>: {subcontent}</div>"
                                for (subtitle, subcontent) in content.items()
                            ]
                            + ["</ul></div>"]
                        )
                        if type(content) is dict
                        else (
                            [f"<div><ul><b>{title}</b>"]
                            + [
                                f"<li><b>{item[0]}</b>: {item[1]}</li>"
                                if type(item) is tuple and len(item) == 2
                                else f"<li>{item}</li>"
                                for item in content
                            ]
                            + ["</ul></div>"]
                        )
                        if type(content) is list
                        else [f"<div><b>{title}</b>: {content}</div>"]
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
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        (db, code) = exchange.get("input")
        upstream = get_activity((db, code))
        location = upstream.get("location", "N/A")
        comment = upstream.get("comment", "N/A")
        title = f"<h3>{amount} {unit} of {name} {{{location}}}</h3>"
        # link button
        link = ipywidgets.Button(description="visit")
        link.search = f"code:{code}"
        link.on_click(linkto)
        technosphere_widgets.append(
            ipywidgets.VBox(
                [
                    ipywidgets.HBox(
                        [link, ipywidgets.HTML(value=title)],
                        layout=ipywidgets.Layout(
                            display="flex",
                            flex_flow="row",
                            align_items="center",
                            width="50%",
                        ),
                    ),
                    ipywidgets.HTML(
                        value=(
                            f"<h4>This exchange was linked to this activity of <b>{db}</b>:</h4>"
                            f"<ul>"
                            f"<li><b>Code</b>: {code}</li>"
                            f"<li><b>Name</b>: {upstream.get('name')}</li>"
                            f"<li><b>Location</b>: {upstream.get('location', 'N/A')}</li>"
                            f"</ul>"
                        )
                    ),
                ],
            )
        )

    # BIOSPHERE
    biosphere = []
    for exchange in activity.biosphere():
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        flow = exchange.get("flow", "N/A")
        (bio, element) = exchange.get("input", "N/A")
        elem = bw2data.Database(bio).get(element).as_dict()
        comment = exchange.get("comment", "N/A")
        biosphere.append(
            f"<h3>{amount} {unit} of {name} ({flow})</h3>"
            f"<h4>This exchange was linked to this element of <b>{bio}</b>:</h4>"
            "<ul>"
            f"<li><b>Code</b>: {elem.get('code', 'N/A')}</li>"
            f"<li><b>Name</b>: {elem.get('name', 'N/A')}</li>"
            f"<li><b>Type</b>: {elem.get('type', 'N/A')}</li>"
            f"<li><b>Categories</b>: {', '.join(elem.get('categories', 'N/A'))}</li>"
            f"<li><b>CAS number</b>: <a href=\"https://pubchem.ncbi.nlm.nih.gov/#query={str(elem.get('CAS number')).lstrip('0')}\">{str(elem.get('CAS number'))}</a></li>"
            "</ul>"
            f"{comment}"
        )

    # SUBSTITUTIONS
    substitution = [
        f"<h3>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')} of {exchange.get('name', 'N/A')}</h3>{get_activity(exchange.get('input')).get('comment', '')}"
        for exchange in activity.substitution()
    ]

    display(
        ipywidgets.Tab(
            titles=[
                "Data",
                "Illustration",
                f"Technosphere ({int(len(technosphere))})",
                f"Biosphere ({len(biosphere)})",
                f"Substitution ({len(substitution)})",
                "Impacts",
            ],
            children=[
                ipywidgets.HTML(value=activity_fields),
                ipywidgets.HTML(value=Illustration),
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
w_activity.observe(select_activity, names="value")
w_method.observe(select_activity, names="value")

details = ipywidgets.VBox(
    [w_statistics],
)
details.add_class("details")
display(
    ipywidgets.HBox(
        [
            ipywidgets.VBox(
                [w_project, w_database, w_search, w_limit, w_method, w_activity, back],
                layout=ipywidgets.Layout(margin="2em"),
            ),
            details,
        ],
        layout=ipywidgets.Layout(
            display="flex",
            flex_flow="row",
            padding="2em",
            justify_content="flex-start",
        ),
    )
)
display(w_results)
display(w_details)
