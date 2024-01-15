"""
This file is `explore` Jupyter Notebook
"""
print("Please wait")
from IPython.core.display import display, Markdown
import sys
import os

sys.stdout = open(os.devnull, "w")
from bw2data.project import projects

sys.stdout = sys.__stdout__
from bw2data.utils import get_activity
import base64
import bw2analyzer
import bw2calc
import bw2data
import csv
import io
import ipywidgets
import json
import os
import pandas
import pandas.io.formats.style

Illustration = open("/home/jovyan/ecobalyse/data/notebooks/bw2.svg").read()
BIOSPHERE = "biosphere3"
STATSTYLE = "<style>.details {background-color: #EEE; padding: 2em;}</style>"
PROJECTS = [p.name for p in bw2data.projects]
EF31 = "Environmental Footprint 3.1 (adapted) patch wtu"
FOODMETHOD = TEXTILEMETHOD = EF31
TEXTILEDB = "Ecoinvent 3.9.1"
FOODDB = "Agribalyse 3.1.1"
os.chdir("/home/jovyan/ecobalyse/data")
VISITED = []  # visited activities since the last search
LIMIT = 100
IMPACTS = {}
with open("/home/jovyan/ecobalyse/public/data/impacts.json") as f:
    IMPACTS = json.load(f)

# widgets
w_panel = ipywidgets.HTML(value=STATSTYLE)
w_project = ipywidgets.Dropdown(
    value=PROJECTS[0] if len(PROJECTS) > 0 else "",
    options=PROJECTS,
    description="PROJECT",
)
w_database = ipywidgets.Dropdown(options=[], description="DATABASE")
w_search = ipywidgets.Text(value="", placeholder="Search string", description="SEARCH")
w_method = ipywidgets.Dropdown(options=[], description="METHOD")
w_limit = ipywidgets.IntText(value=LIMIT, step=1, description="LIMIT")
w_activity = ipywidgets.Dropdown(options=[], description="ACTIVITY")
w_results = ipywidgets.Output(value="Résultat")
w_details = ipywidgets.Output(value="Détails")
w_impact_category = ipywidgets.Dropdown(
    options=[],
    description="IMPACT CATEG",
)

display(Markdown("# Brightway explorer :"))


def go_back(button):
    """We clicked on the Back button"""
    linkto(button, append_to_stack=False)


w_back_button = ipywidgets.Button(description="←back")
w_back_button.layout.display = "none"
setattr(w_back_button, "search", "")
w_back_button.on_click(go_back)


def w_csv_button(database, search, limit):
    csvfile = io.StringIO()
    writer = csv.DictWriter(csvfile, fieldnames=["name"])
    writer.writeheader()
    for name in list(bw2data.Database(database).search(search, limit=limit)):
        writer.writerow({"name": name["name"]})
    csvfile.seek(0)
    contents = csvfile.read()
    return ipywidgets.HTML(
        """
        <a download="{filename}" href="data:text/csv;base64,{payload}" download>
        <button class="p-Widget jupyter-widgets jupyter-button widget-button mod-warning">Download as CSV</button>
        </a>
    """.format(
            payload=base64.b64encode(contents.encode()).decode(), filename="export.csv"
        )
    )


@w_results.capture()
def display_results(database, search, limit):
    """display the list of search results in the w_results widget"""
    results = list(bw2data.Database(database).search(search, limit=limit))
    w_results.clear_output()
    w_details.clear_output()
    w_activity.options = [("", "")] + [
        (str(i) + " " + a.get("name", ""), a) for i, a in enumerate(results)
    ]
    if len(results) == 0:
        display(Markdown("(No results)"))
    else:
        display(
            Markdown(f"## {('+' if len(results)==LIMIT else '')}{len(results)} results")
        )
        html = pandas.io.formats.style.Styler(
            pandas.DataFrame(results, columns=["name", "code", "location"])
        )
        html.set_properties(**{"background-color": "#EEE"})
        display(w_csv_button(database, search, limit))
        display(ipywidgets.HTML(html.to_html()))


@w_results.capture()
def display_characterization_factors(method, impact_category):
    w_details.clear_output()
    w_results.clear_output()
    # METHOD CFs
    grouped = {}
    for line in bw2data.Method((method,) + impact_category).load() if method else []:
        substance = tuple(line[0])
        grouped[substance] = grouped.get(substance, ()) + (str(line[1]),)
    cfs = pandas.io.formats.style.Styler(
        pandas.DataFrame(
            [
                (
                    g[0][1],
                    bw2data.Database(g[0][0]).get(g[0][1]),
                    ("Multiple values: " if len(g[1]) > 1 else "") + " | ".join(g[1]),
                    bw2data.methods[(method,) + impact_category]["unit"],
                )
                for g in grouped.items()
            ],
            columns=["id", "substance found in biosphere", "amount", "unit"],
        )
    )

    cfs.set_properties(**{"background-color": "#EEE"})

    display(
        Markdown(
            f"# {len(cfs.data)} Characterization factors for <b>{', '.join(impact_category)}</b> in {method}"
        )
    )
    if len(cfs.data):
        display(ipywidgets.HTML(cfs.to_html()))


def linkto(button, append_to_stack=True):
    """We clicked on an activity button to visit"""

    if append_to_stack:
        VISITED.append(button.search)
    else:
        if len(VISITED) > 1:
            VISITED.pop()
        elif len(VISITED) == 1:
            w_search.value = VISITED.pop()
    setattr(w_back_button, "search", VISITED[-1] if len(VISITED) > 0 else "")
    results = list(
        bw2data.Database(w_database.value).search(button.search, limit=w_limit.value)
    )
    if len(VISITED) == 0:
        w_search.value = ""
    w_activity.value = None
    w_activity.options = [
        (str(i) + " " + a.get("name", ""), a) for i, a in enumerate(results)
    ]
    w_activity.value = results[0] if len(results) > 0 else None


def lookup_cf(loaded_method, element):
    """Find a Characterization Factor by name in the list of already loaded CFs"""
    cfs = [cf for cf in loaded_method if cf[0] == element]
    if len(cfs) == 0:
        return "Ø"
    elif len(cfs) == 1:
        return "{:.4g}".format(cfs[0][1])
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


def changed_project(_):
    project = w_project.value
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value

    projects.set_current(project)
    # projects.activate_project(project)
    databases = list(bw2data.databases)
    methods = sorted({m[0] for m in bw2data.methods})
    impact_categories = [
        (", ".join(m[1:]), m[1:]) for m in bw2data.methods if m[0] == method
    ]

    # default database
    w_database.value = None
    w_database.options = databases
    if project == "food" and FOODDB in databases and FOODMETHOD in methods:
        database = w_database.value = database if database in databases else FOODDB
        w_method.value = None
        w_method.options = methods
        method = w_method.value = method if method in methods else FOODMETHOD
    elif project == "textile" and TEXTILEDB in databases and TEXTILEMETHOD in methods:
        database = w_database.value = database if database in databases else TEXTILEDB
        w_method.value = None
        w_method.options = methods
        method = w_method.value = method if method in methods else TEXTILEMETHOD
    else:
        w_method.value = None
        w_impact_category.value = None
        w_method.options = methods
        method = w_method.value = method if method in methods else None
    w_impact_category.options = [("", "")] + sorted(
        [(", ".join(m[1:]), m[1:]) for m in bw2data.methods if m[0] == method]
    )
    impact_category = w_impact_category.value = (
        impact_category if impact_category in impact_categories else None
    )
    activity = w_activity.value = None
    display_all(database, search, limit, method, impact_category, activity)


def changed_database(_):
    w_activity.value = None
    display_all(
        w_database.value,
        w_search.value,
        w_limit.value,
        w_method.value,
        w_impact_category.value,
        w_activity.value,
    )


def changed_search(_):
    global VISITED  # 🤮
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value

    if search:
        if len(VISITED) <= 1:
            VISITED = [search]
            activity = w_activity.value = None
        else:
            VISITED = []
    display_all(database, search, limit, method, impact_category, activity)


def changed_limit(_):
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value
    display_all(database, search, limit, method, impact_category, activity)


def changed_method(_):
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value
    impact_categories = [m[1:] for m in bw2data.methods if m[0] == method]
    w_impact_category.value = None
    w_impact_category.options = [("", None)] + [
        (", ".join(i), i) for i in impact_categories
    ]
    impact_category = w_impact_category.value = (
        impact_category if impact_category in impact_categories else None
    )
    display_all(database, search, limit, method, impact_category, activity)


def changed_impact_category(_):
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value
    display_all(database, search, limit, method, impact_category, activity)


def changed_activity(_):
    database = w_database.value
    search = w_search.value
    limit = w_limit.value
    method = w_method.value
    impact_category = w_impact_category.value
    activity = w_activity.value
    display_all(database, search, limit, method, impact_category, activity)


def display_all(database, search, limit, method, impact_category, activity):
    if method and impact_category and not search and not activity:
        return display_characterization_factors(method, impact_category)
    elif database and method and activity:
        display_right_panel(database)
        return display_main_data(method, impact_category, activity)
    elif database and search and limit:
        return display_results(database, search, limit)
    else:
        w_details.clear_output()
        w_results.clear_output()


def display_right_panel(database):
    # right panel
    biosphere_name = bw2data.preferences.get("biosphere_database", "")
    biosphere = bw2data.Database(biosphere_name) if biosphere_name else ()
    breadcrumb = [
        f"<li>{bw2data.Database(database).search(a)[0] if bw2data.Database(database).search(a) and str(a).startswith('code:') else a}</li>"
        for a in VISITED
    ]
    w_panel.value = STATSTYLE + (
        f"<div><b>database size</b>: {len(bw2data.Database(database))}</div>"
        f"<div><b>biosphere name</b>: {biosphere_name}</div>"
        f"<div><b>biosphere size</b>: {len(biosphere)}</div>"
        f"{('<ul>⛏️  Breadcrumb: ' + ''.join(breadcrumb)) if len(breadcrumb)>1 else ''}"
    )
    w_back_button.layout.display = "none" if len(VISITED) <= 1 else "block"


@w_details.capture()
def display_main_data(method, impact_category, activity):
    w_details.clear_output()
    w_results.clear_output()
    display(Markdown(f"## (Computing impacts...)"))

    # Impacts
    scores = []
    try:
        lca = bw2calc.LCA({activity: 1})
        impacts_error = ""
        lca.lci()
        for m in [m for m in bw2data.methods if m[0] == method]:
            lca.switch_method(m)
            lca.lcia()
            scores.append(
                {
                    "Indicateur": ", ".join(m[1:]),
                    "Score": lca.score,
                    "Unité": bw2data.methods[m].get("unit", "(no unit)"),
                }
            )
    except Exception as e:
        impacts_error = (
            "Could not compute impact. Maybe you selected the biosphere?<br/>" + str(e)
        )
    impacts = pandas.io.formats.style.Styler(pandas.DataFrame(scores))
    impacts.set_properties(**{"background-color": "#EEE"})
    impacts.format(formatter={"Score": "{:.4g}".format})

    # PEF
    if scores and method == EF31:
        scores = {s["Indicateur"]: s["Score"] for s in scores}
        pef = (
            scores["Acidification"]
            / IMPACTS["acd"]["pef"]["normalization"]
            * IMPACTS["acd"]["pef"]["weighting"]
            + scores["Climate change"]
            / IMPACTS["cch"]["pef"]["normalization"]
            * IMPACTS["cch"]["pef"]["weighting"]
            + (
                scores["Ecotoxicity, freshwater - part 1"]
                + scores["Ecotoxicity, freshwater - part 2"]
            )
            / IMPACTS["etf"]["pef"]["normalization"]
            * IMPACTS["etf"]["pef"]["weighting"]
            + scores["Particulate matter"]
            / IMPACTS["pma"]["pef"]["normalization"]
            * IMPACTS["pma"]["pef"]["weighting"]
            + scores["Eutrophication, marine"]
            / IMPACTS["swe"]["pef"]["normalization"]
            * IMPACTS["swe"]["pef"]["weighting"]
            + scores["Eutrophication, freshwater"]
            / IMPACTS["fwe"]["pef"]["normalization"]
            * IMPACTS["fwe"]["pef"]["weighting"]
            + scores["Eutrophication, terrestrial"]
            / IMPACTS["tre"]["pef"]["normalization"]
            * IMPACTS["tre"]["pef"]["weighting"]
            + scores["Human toxicity, cancer"]
            / IMPACTS["htc"]["pef"]["normalization"]
            * IMPACTS["htc"]["pef"]["weighting"]
            + scores["Human toxicity, non-cancer"]
            / IMPACTS["htn"]["pef"]["normalization"]
            * IMPACTS["htn"]["pef"]["weighting"]
            + scores["Ionising radiation"]
            / IMPACTS["ior"]["pef"]["normalization"]
            * IMPACTS["ior"]["pef"]["weighting"]
            + scores["Land use"]
            / IMPACTS["ldu"]["pef"]["normalization"]
            * IMPACTS["ldu"]["pef"]["weighting"]
            + scores["Ozone depletion"]
            / IMPACTS["ozd"]["pef"]["normalization"]
            * IMPACTS["ozd"]["pef"]["weighting"]
            + scores["Photochemical ozone formation"]
            / IMPACTS["pco"]["pef"]["normalization"]
            * IMPACTS["pco"]["pef"]["weighting"]
            + scores["Resource use, fossils"]
            / IMPACTS["fru"]["pef"]["normalization"]
            * IMPACTS["fru"]["pef"]["weighting"]
            + scores["Resource use, minerals and metals"]
            / IMPACTS["mru"]["pef"]["normalization"]
            * IMPACTS["mru"]["pef"]["weighting"]
            + scores["Water use"]
            / IMPACTS["wtu"]["pef"]["normalization"]
            * IMPACTS["wtu"]["pef"]["weighting"]
        )
    else:
        pef = None

    # PRODUCTION
    production = "".join(
        [
            f"<div style=\"font-size: 1.5em;\">Production: <b>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')}</b> of <b>{exchange.get('name', 'N/A')}</b></div>"
            for exchange in activity.production()
        ]
    )

    # ACTIVITY DATA
    activity_fields = f"{production}" + dict2html(activity)

    w_details.clear_output()
    display(Markdown(f"## (Retrieving technosphere...)"))

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
        w_link = ipywidgets.Button(description="→ visit")
        setattr(w_link, "search", f"code:{code}")
        w_link.on_click(linkto)
        technosphere_widgets.append(
            ipywidgets.VBox(
                [
                    ipywidgets.HTML(
                        value=(
                            f'<details style="cursor: pointer; background-color: #EEE;">'
                            f'  <summary style="font-size: 1.5em">'
                            f"    <b>{amount} {unit}</b> of <b>{name} {{{location}}}</b>"
                            f"  </summary>"
                            f"</summary>"
                            f"{dict2html(exchange)}"
                            f"</details>"
                            f"<ul>"
                            f"  <h4>This exchange was linked to this activity of <b>{db}</b>:</h4>"
                            f"  <li><b>Name</b>: {upstream.get('name')}</li>"
                            f"  <li><b>Location</b>: {upstream.get('location', 'N/A')}</li>"
                            f"  <li><b>Code</b>: {code}</li>"
                            f"</ul>"
                        )
                    ),
                    w_link,
                ],
            )
        )

    w_details.clear_output()
    display(Markdown(f"## (Retrieving biosphere...)"))

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
            for method in [m for m in bw2data.methods if m[0] == method]
        }
        cfs = pandas.io.formats.style.Styler(
            pandas.DataFrame(
                [
                    (
                        ", ".join(meth[1:]),
                        lookup_cf(allcfs[meth], element),
                        bw2data.methods.get(meth, {}).get("unit", "N/A"),
                    )
                    for meth in [
                        m
                        for m in bw2data.methods
                        if m[0] == method
                        and (
                            not w_impact_category.value
                            or w_impact_category.value == m[1:]
                        )
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
            f'<li><details style="cursor: pointer; background-color: #EEE;"><summary style="font-size: 1.5em"><b>Characterization factors</b></summary>{cfs.to_html(index=False)}</details></li>'
            "</ul>"
        )

    # SUBSTITUTIONS
    substitution = [
        f"<span style=\"font-size: 1.5em;\"><b>{exchange.get('amount', 'N/A')} {exchange.get('unit', 'N/A')}</b> of <b>{exchange.get('name', 'N/A')}</b></span>{get_activity(exchange.get('input')).get('comment', '')}"
        for exchange in activity.substitution()
    ]

    # ANALYSIS
    if w_impact_category.value:
        try:
            # TOP EMISSIONS
            lca.switch_method((method,) + impact_category)
            lca.lcia()
            top_emissions = pandas.io.formats.style.Styler(
                pandas.DataFrame(
                    [
                        (score, amount, activity["unit"], activity)
                        for (
                            score,
                            amount,
                            activity,
                        ) in bw2analyzer.ContributionAnalysis().annotated_top_emissions(
                            lca
                        )
                    ],
                    columns=["Score", "Amount", "Unit", "Elementary flow"],
                )
            )
            top_emissions.format(
                formatter={"Score": "{:.4g}".format, "Amount": "{:.4g}".format}
            )
            top_emissions.set_properties(**{"background-color": "#EEE"})
            # TOP PROCESSES
            top_processes = pandas.io.formats.style.Styler(
                pandas.DataFrame(
                    [
                        (score, amount, activity["unit"], activity)
                        for (
                            score,
                            amount,
                            activity,
                        ) in bw2analyzer.ContributionAnalysis().annotated_top_processes(
                            lca
                        )
                    ],
                    columns=["Score", "Amount", "Unit", "Activity"],
                )
            )
            top_processes.set_properties(**{"background-color": "#EEE"})
            top_processes.format(
                formatter={"Score": "{:.4g}".format, "Amount": "{:.4g}".format}
            )
            analysis = (
                f"<h2>{', '.join(lca.method[1:])}</h2>"
                f"<h3>Top Processes</h3>{top_processes.to_html()}"
                f"<h3>Top Emissions</h3>{top_emissions.to_html()}"
            )
        except Exception as e:
            analysis = "Nothing to display. Maybe you selected the biosphere?"
    else:
        analysis = "💡 Please select an impact category"

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
                ipywidgets.HTML("".join(biosphere)),
                ipywidgets.HTML("".join(substitution)),
                ipywidgets.VBox(
                    [
                        ipywidgets.HTML(
                            f"<h2>µPt PEF: {1e6 * pef:10.2f}</h2>" if pef else ""
                        ),
                        ipywidgets.HTML(impacts_error),
                        ipywidgets.HTML(impacts.to_html()),
                    ]
                ),
                ipywidgets.HTML(analysis),
            ],
        )
    )


w_project.observe(changed_project, names="value")
w_database.observe(changed_database, names="value")
w_search.observe(changed_search, names="value")
w_limit.observe(changed_limit, names="value")
w_activity.observe(changed_activity, names="value")
w_method.observe(changed_method, names="value")
w_impact_category.observe(changed_impact_category, names="value")

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
                    w_method,
                    w_impact_category,
                    w_search,
                    w_limit,
                    w_activity,
                    w_back_button,
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
