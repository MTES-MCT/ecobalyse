"""
This file is `explore` Jupyter Notebook
"""
from IPython.core.display import display, Markdown
from bw2data.project import projects
from bw2data.utils import get_activity
import bw2analyzer
import bw2calc
import bw2data
import ipywidgets
import os
import pandas
import pandas.io.formats.style

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
w_panel = ipywidgets.HTML(value=STATSTYLE)
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
w_focus = ipywidgets.Dropdown(
    options=[],
    description="FOCUS",
)

display(Markdown("# Search in the database :"))


def go_back(button):
    """We clicked on the Back button"""
    linkto(button, stack=False)


back = ipywidgets.Button(description="←back")
back.layout.display = "none"
back.search = ""
back.on_click(go_back)


def switch_project(change):
    """We changed the project in the PROJECT dropdown"""
    w_details.clear_output()
    project = change.new
    projects.activate_project(project)
    databases = list(bw2data.databases)
    w_database.options = databases
    methods = sorted({m[0] for m in bw2data.methods})
    w_method.options = methods
    w_focus.options = [""] + sorted([m[1] for m in bw2data.methods if m[0] == METHOD])
    # default values
    if project == "Food" and METHOD in methods:
        w_method.value = METHOD
    elif project == "Textile" and METHOD in methods:
        w_method.value = METHOD
    if project == "Food" and FOODDB in databases:
        w_database.value = FOODDB
    elif project == "Textile" and TEXTILEDB in databases:
        w_database.value = TEXTILEDB
    biosphere_name = bw2data.preferences.get("biosphere_database", "")
    biosphere = bw2data.Database(biosphere_name) if biosphere_name else ()
    w_panel.value = STATSTYLE + (
        f"<div><b>database size</b>: {len(bw2data.Database(w_database.value))}</div>"
        f"<div><b>biosphere name</b>: {biosphere_name}</div>"
        f"<div><b>biosphere size</b>: {len(biosphere)}</div>"
    )
    back.layout.display = "none" if len(VISITED) == 0 else "block"


@w_results.capture()
def display_results(results):
    """display the list of search results in the w_results widget"""
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
    """We changed the database, search term, or limit of results"""
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
    """We clicked on an activity button to visit"""
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


def lookup_cf(loaded_method, element):
    """Find a Characterization Factor by name in the list of already loaded CFs"""
    cfs = [cf for cf in loaded_method if cf[0] == element]
    if len(cfs) == 0:
        return ""
    elif len(cfs) == 1:
        return str(cfs[0][1])
    else:
        return "Multiple CFs : " + " | ".join([str(cf[1]) for cf in cfs])


def dict2html(d):
    """Display a dict in HTML"""
    return (
        "<ul>"
        + "".join(
            [
                f"<li><b>{k}</b>: {dict2html(v) if type(v) is dict else list2html(v) if type(v) in (list, tuple) else str(v)}</li>"
                for k, v in d.items()
            ]
        )
        + "</ul>"
    )


def list2html(l):
    """Display a list in HTML"""
    return (
        "<ul>"
        + "".join(
            [
                f"<li><b>{list2html(i) if type(i) in (list,tuple) else dict2html(i) if type(i) is dict else str(i)}</b></li>"
                for i in l
            ]
        )
        + "</ul>"
    )


@w_details.capture()
def select_activity(change):
    """We selected an activity in the ACTIVITY dropdown"""
    activity = change.new if change.owner is w_activity else w_activity.value
    method = change.new if change.owner is w_method else w_method.value
    w_results.clear_output()
    w_details.clear_output()

    # IMPACTS
    if not activity or not method:
        return
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    display(Markdown(f"# (Computing...)"))
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
    impacts = pandas.io.formats.style.Styler(
        pandas.DataFrame(scores), caption="Impacts"
    )
    impacts.set_properties(**{"background-color": "#EEE"})

    # PRODUCTION
    production = "".join(
        [
            f"<div style=\"font-size: 1.5em;\">Production: <b>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')}</b> of <b>{exchange.get('name', 'N/A')}</b></div>"
            for exchange in activity.production()
        ]
    )

    # ACTIVITY DATA
    activity_fields = f"{production}" + dict2html(activity)

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
        # link button
        link = ipywidgets.Button(description="→ visit")
        link.search = f"code:{code}"
        link.on_click(linkto)
        technosphere_widgets.append(
            ipywidgets.VBox(
                [
                    ipywidgets.HTML(
                        value=(
                            f'<details style="cursor: pointer; background-color: #EEE;"><summary style="font-size: 1.5em"><b>{amount} {unit}</b> of <b>{name} {{{location}}}</b></summary>{dict2html(exchange)}</details>'
                            f"<ul>"
                            f"<h4>This exchange was linked to this activity of <b>{db}</b>:</h4>"
                            f"<li><b>Name</b>: {upstream.get('name')}</li>"
                            f"<li><b>Location</b>: {upstream.get('location', 'N/A')}</li>"
                            f"<li><b>Code</b>: {code}</li>"
                            f"</ul>"
                        )
                    ),
                    link,
                ],
            )
        )

    # BIOSPHERE
    biosphere = []
    for exchange in activity.biosphere():
        amount = exchange.get("amount", "N/A")
        unit = exchange.get("unit", "N/A")
        name = exchange.get("name", "N/A")
        (dbname, code) = element = exchange.get("input", "N/A")
        input_ = bw2data.Database(dbname).get(code).as_dict()
        comment = exchange.get("comment", "N/A")
        allcfs = {
            method: bw2data.Method(method).load()
            for method in [m for m in bw2data.methods if m[0] == METHOD]
        }
        cfs = pandas.io.formats.style.Styler(
            pandas.DataFrame(
                [
                    (
                        method[1],
                        lookup_cf(allcfs[method], element),
                        bw2data.methods.get(method)["unit"],
                    )
                    for method in [
                        m
                        for m in bw2data.methods
                        if m[0] == METHOD
                        and (not w_focus.value or w_focus.value == m[1])
                    ]
                ],
                columns=["Indicator", "Score", "Unit"],
            )
        )
        cfs.set_properties(**{"background-color": "#EEE"})

        biosphere.append(
            f'<details style="cursor: pointer; background-color: #EEE;"><summary style="font-size: 1.5em"><b>{amount} {unit}</b> of <b>{name}</b></summary>{dict2html(exchange)}</details>'
            "<ul>"
            f"<h4>This exchange was linked to this element of <b>{dbname}</b>:</h4>"
            f"<li><b>Name</b>: {input_.get('name', 'N/A')}</li>"
            f"<li><b>Code</b>: {input_.get('code', 'N/A')}</li>"
            f"<li><b>Type</b>: {input_.get('type', 'N/A')}</li>"
            f"<li><b>Categories</b>: {', '.join(input_.get('categories', 'N/A'))}</li>"
            f"<li><b>CAS number</b>: <a href=\"https://pubchem.ncbi.nlm.nih.gov/#query={str(input_.get('CAS number')).lstrip('0')}\">{str(input_.get('CAS number'))}</a></li>"
            f"<li><b>Unit</b>: {input_.get('unit', 'N/A')}</li>"
            f"<li><b>Id</b>: {input_.get('id', 'N/A')}</li>"
            f"<li><b>Comment</b>: {comment}</li>"
            f'<li><details style="cursor: pointer; background-color: #EEE;"><summary style="font-size: 1.5em"><b>Characterization factors</b></summary>{cfs.to_html()}</details></li>'
            "</ul>"
        )

    # SUBSTITUTIONS
    substitution = [
        f"<span style=\"font-size: 1.5em;\"><b>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')}</b> of <b>{exchange.get('name', 'N/A')}</b></span>{get_activity(exchange.get('input')).get('comment', '')}"
        for exchange in activity.substitution()
    ]

    # ANALYSIS
    if w_focus.value:
        lca.switch_method((METHOD, w_focus.value))
        lca.lcia()
        top_emissions = pandas.io.formats.style.Styler(
            pandas.DataFrame(
                bw2analyzer.ContributionAnalysis().annotated_top_emissions(lca),
                columns=["Score", "Supply amount", "Activity"],
            )
        )
        top_emissions.set_properties(**{"background-color": "#EEE"})
        top_processes = pandas.io.formats.style.Styler(
            pandas.DataFrame(
                bw2analyzer.ContributionAnalysis().annotated_top_processes(lca),
                columns=["Score", "inventory amount", "Activity"],
            )
        )
        top_processes.set_properties(**{"background-color": "#EEE"})
        analysis = (
            f"<h2>{lca.method[1]}</h2>"
            f"<h3>Top Processes</h3>{top_processes.to_html()}"
            f"<h3>Top Emissions</h3>{top_emissions.to_html()}"
        )
    else:
        analysis = "💡 Please select a FOCUS"

    w_details.clear_output()
    display(Markdown(f"# {activity}"))
    display(
        ipywidgets.Tab(
            titles=[
                "Data",
                "Illustration",
                f"Technosphere ({int(len(technosphere))})",
                f"Biosphere ({len(biosphere)})",
                f"Substitution ({len(substitution)})",
                "Impacts",
                "Analysis",
            ],
            children=[
                ipywidgets.HTML(value=activity_fields),
                ipywidgets.HTML(
                    value=(
                        "In this illustration, the studied activity in the center has four exchanges (in grey). "
                        "Two technosphere exchanges are linked to upstream activities (in purple), "
                        "and two biosphere activities are linked to emission or consumption of substances in the environment (in green). "
                        'The notion of "linking" in Brightway consists in setting the "input" field '
                        "of the exchanges by finding the right Activity."
                    )
                    + Illustration
                ),
                ipywidgets.VBox(technosphere_widgets),
                ipywidgets.HTML(value="".join(biosphere)),
                ipywidgets.HTML(value="".join(substitution)),
                ipywidgets.HTML(impacts.to_html()),
                ipywidgets.HTML(analysis),
            ],
        )
    )


w_project.observe(switch_project, names="value")
w_database.observe(search_activity, names="value")
w_search.observe(search_activity, names="value")
w_limit.observe(search_activity, names="value")
w_activity.observe(select_activity, names="value")
w_method.observe(select_activity, names="value")
w_focus.observe(select_activity, names="value")

details = ipywidgets.VBox(
    [w_panel],
)
details.add_class("details")
display(
    ipywidgets.HBox(
        [
            ipywidgets.VBox(
                [
                    w_project,
                    w_database,
                    w_search,
                    w_limit,
                    w_method,
                    w_focus,
                    w_activity,
                    back,
                ],
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
