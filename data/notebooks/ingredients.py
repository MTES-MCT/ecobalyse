"""
This file is the ingredient/activity editor Jupyter Notebook
"""
print("Please wait")
import sys
import os

# don"t display bw2data startup output
sys.stdout = open(os.devnull, "w")
from bw2data.project import projects

sys.stdout = sys.__stdout__
from flatdict import FlatDict
import bw2calc
import bw2data
import ipywidgets
import json
import pandas
import pandas.io.formats.style
import requests
import shutil
import subprocess
import urllib.parse


os.chdir("/home/jovyan/ecobalyse/data")
PROJECT = "food"
ACTIVITIES = "/home/jovyan/ecobalyse/data/food/activities.json"
ACTIVITIES_TEMP = "/home/jovyan/activities.%s.json"
AGRIBALYSE = "Agribalyse 3.1.1"
CROP_GROUPS = [
    "BLE TENDRE",
    "MAIS GRAIN ET ENSILAGE",
    "ORGE",
    "AUTRES CEREALES",
    "COLZA",
    "TOURNESOL",
    "AUTRES OLEAGINEUX",
    "PROTEAGINEUX",
    "PLANTES A FIBRES",
    "SEMENCES",
    "GEL (surfaces gelées sans production)",
    "GEL INDUSTRIEL",
    "AUTRES GELS",
    "RIZ",
    "LEGUMINEUSES A GRAIN",
    "FOURRAGE",
    "ESTIVES LANDES",
    "PRAIRIES PERMANENTES",
    "PRAIRIES TEMPORAIRES",
    "VERGERS",
    "VIGNES",
    "FRUITS A COQUES",
    "OLIVIERS",
    "AUTRES CULTURES INDUSTRIELLES",
    "LEGUMES-FLEURS",
    "CANNE A SUCRE",
    "ARBORICULTURE",
    "DIVERS",
    "BOVINS VIANDE",
    "BOVINS LAIT",
    "OVINS VIANDE",
    "OVINS LAIT",
    "VOLAILLES",
    "PORCINS",
]

projects.set_current(PROJECT)
# projects.create_project(PROJECT, activate=True, exist_ok=True)

list_output = ipywidgets.Output()
git_output = ipywidgets.Output()
reset_output = ipywidgets.Output()
file_output = ipywidgets.Output()
save_output = ipywidgets.Output()
surface_output = ipywidgets.Output()

pandas.set_option("display.max_columns", 500)
pandas.set_option("display.max_rows", 500)
pandas.set_option("notebook_repr_html", True)
pandas.set_option("max_colwidth", 15)


def dbsearch(db, term, **kw):
    return bw2data.Database(db).search(term, **kw)


def cleanup_json(activities):
    """consistency of the json file"""
    for i, a in enumerate(activities):
        # remove categories for non-ingredients
        if a["category"] != "ingredient":
            for x in (
                "categories",
                "raw_to_cooked_ratio",
                "density",
                "inedible_part",
                "transport_cooling",
                "visible",
                "explain",
            ):
                if x in a:
                    del activities[i][x]
                # _ = activities[i].pop(x, None)
    return activities


def save_activities(activities):
    if not w_contributor.value:
        return
    with open(ACTIVITIES_TEMP % w_contributor.value, "w") as fp:
        fp.write(
            json.dumps(
                cleanup_json([from_flat(from_pretty(i)) for i in activities.values()]),
                indent=2,
                ensure_ascii=False,
            )
        )
    clear_form()
    display_all()


def to_flat(d):
    return dict(FlatDict(d, delimiter="."))


def from_flat(d):
    return FlatDict(d, delimiter=".").as_dict()


def reverse(d):
    """turn the values of a dict into keys and keys into values"""
    return {v: k for k, v in d.items()}


FIELDS = {
    # process attributes
    "id": "id",
    "name": "Nom",
    "database": "Base de données",
    "search": "Termes de recherche",
    "default_origin": "Origine par défaut",
    "category": "Catégorie de procédé",
    # ingredients attributes
    "categories": "Catégories d'ingrédient",
    "raw_to_cooked_ratio": "Cooked/Raw ratio",
    "density": "Densité",
    "inedible_part": "Part non comestible",
    "transport_cooling": "Transport réfrigéré",
    "visible": "Visible",
    "explain": "Commentaires",
    # EcosystemicServices for animal products
    "ecosystemicServices.hedges": "Haies",
    "ecosystemicServices.plotSize": "Taille de parcelles",
    "ecosystemicServices.cropDiversity": "Diversité culturale",
    "ecosystemicServices.permanentPasture": "Prairies permanentes",
    "ecosystemicServices.livestockDensity": "Chargement territorial",
    # EcosystemicServices for other products
    "crop_group": "Groupe de culture",
    "land_occupation": "Empreinte terrestre (m²a)",
    "scenario": "Scenario",
}


def to_pretty(d):
    """turn a dict with dotted keys to a dict with pretty keys"""
    return {FIELDS[k]: v for k, v in d.items() if FIELDS.get(k)}


def from_pretty(d):
    """turn a dict with pretty keys to a dict with dotted keys"""
    activity = {reverse(FIELDS)[k]: v for k, v in d.items()}
    return activity


def read_activities():
    """Return the activities as a dict indexed with id"""

    def read_temp():
        with open(ACTIVITIES_TEMP % w_contributor.value) as fp:
            fs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}
            for k, v in fs.items():
                v.setdefault("Base de données", AGRIBALYSE)
                fs[k] = v
            return fs

    if not os.path.exists(ACTIVITIES_TEMP % w_contributor.value):
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_contributor.value)
    try:
        igs = read_temp()
    except json.JSONDecodeError:
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_contributor.value)
        igs = read_temp()

    return igs


# WIDGETS
## technical identifier of the activity (for API/URL/FK)
style = {"description_width": "initial"}
w_contributor = ipywidgets.Dropdown(
    options=[
        "Écobalyse",
        "ITERG",
        "ACTALIA",
        "IFV",
        "ADEME",
        "ITAB",
        "CTCPA",
        "ITAVI",
        "IDELE",
        "Terres Inovia",
        "CTIFL",
    ],
    value=None,
    style=style,
    description="Contributeur : ",
)
w_filter = ipywidgets.Text(placeholder="Search", style=style)
w_id = ipywidgets.Combobox(
    placeholder="wheat-organic",
    style=style,
    options=tuple([""] + list(read_activities().keys())),
)
## Name of the activity (for users)
w_name = ipywidgets.Text(
    placeholder="Farine bio",
    style=style,
)
## Is the activity an ingredient?
w_ingredient = ipywidgets.Checkbox(indent=False, style=style, value=False)
## brightway search terms to find the activity
w_database = ipywidgets.Dropdown(
    options=[d for d in list(bw2data.databases) if str(d) != "biosphere3"],
    value=AGRIBALYSE if AGRIBALYSE in bw2data.databases else "",
)
w_search = ipywidgets.Text(placeholder="wheat FR farm", style=style)
w_results = ipywidgets.RadioButtons(
    rows=1,
    options=[""],
    style=style,
    layout=ipywidgets.Layout(width="auto", overflow="scroll"),
    disabled=True,
)
## default origin
w_default_origin = ipywidgets.Dropdown(
    options=[
        ("France (à plus de 95%)", "France"),
        ("Europe ou Maghreb (à plus de 95%)", "EuropeAndMaghreb"),
        ("Hors Europe ou Maghreb (à plus de 5%)", "OutOfEuropeAndMaghreb"),
        (
            "Par avion, hors Europe ou Maghreb (mangue, haricots, ...)",
            "OutOfEuropeAndMaghrebByPlane",
        ),
    ],
    style=style,
)
w_category = ipywidgets.Dropdown(
    options=[
        ("Ingrédient", "ingredient"),
        ("Matériau", "material"),
        ("Énergie", "energy"),
        ("Emballage", "packaging"),
        ("Traitement", "processing"),
        ("Transformation", "transformation"),
        ("Transport", "transport"),
        ("Traitement des déchets", "waste treatment"),
    ],
)
w_categories = ipywidgets.TagsInput(
    allowed_tags=[
        "animal_product",
        "dairy_product",
        "grain_raw",
        "grain_processed",
        "nut_oilseed_raw",
        "nut_oilseed_processed",
        "misc",
        "spice_condiment_additive",
        "vegetable_fresh",
        "vegetable_processed",
        "organic",
        "bleublanccoeur",
    ],
    style=style,
    allow_duplicates=False,
)
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    options=[
        ("Non", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
    style=style,
)
# Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.Dropdown(
    options=[
        (
            "1.0 (Prod laitiers, noix, boiss liquides, herbes, fruits et légumes séchés, farines, sel, sucre, épices, cornichons, câpres, condiments)",
            1.0,
        ),
        ("2,330 (Légumineuses)", 2.33),
        ("2,259 (Céréales)", 2.259),
        ("0,974 (Oeufs)", 0.974),
        ("0,856 (Fruits et légumes)", 0.856),
        ("0,819 (Poissons et fruits de mer)", 0.819),
        ("0,792 (Viandes rouges)", 0.792),
        ("0,755 (Volaille)", 0.755),
        ("0,730 (Abats)", 0.730),
    ]
)
w_density = ipywidgets.Dropdown(
    options=[
        ("", 0),
        ("0,6375 (Pomme de terre, frites, racines)", 0.6375),
        ("0,6195 (Onion, poireau, échalote, chou-rave)", 0.6195),
        ("0,3980 (Aubergine, courgette)", 0.398),
        ("0,3620 (Chou, asperge, artichaut, chou de Bruxelles, citrouille)", 0.362),
        ("0,5750 (Citron, agrumes)", 0.575),
        ("0,2710 (Haricots verts/blancs/plat, soja)", 0.271),
        ("0,2355 (Chou-fleur, brocoli, romanesco)", 0.2355),
        (
            "0,2400 (Niébé, flageolet, mungo, petits pois, légumineuses, lentilles, noix, graines, maïs)",
            0.24,
        ),
        (
            "0,1180 (Épinard, laitue, endives, cresson, champignons, autres légers)",
            0.118,
        ),
        ("0,2950 (Poivrons)", 0.295),
        (
            "0,4470 (Concombre, melon, pastèque, tous fruits et baies, noix de coco, céléri, rhubarbe (autres riches en eau)",
            0.447,
        ),
        (
            "1.0000 (Autres, oeuf, algues, fruits de mer, laitiers, viande, farines, poisson, sauce tomate)",
            1.0,
        ),
    ],
)
## inedible part of the ingredient
w_inedible = ipywidgets.Dropdown(
    options=[
        ("", 1),
        ("◼ FRUITS ◼", ""),
        (" 3% (tomate, mures, myrtilles, framboises, fraises)", 0.03),
        ("10% (pommes, poire, raisin)", 0.1),
        (
            "20% (abricot, groseille, mandarine, mangue, orange, pêche, prune, grenade)",
            0.2,
        ),
        ("30% (banane, pamplemousse, citron)", 0.3),
        ("40% (melon)", 0.4),
        ("50% (amandes, ananas, noix)", 0.5),
        ("◼ LEGUMES ◼", ""),
        (" 0% (pois verts)", 0),
        (" 3% (céleri, céleri vert, poivron, radis, épinard)", 0.03),
        (
            "10% (basilic, betterave, chou de Bruxelles, carotte, manioc, céleri-rave, artichaut chinois/japonais, coriandre, concombre, aubergine)",
            0.1,
        ),
        (
            "10% (harico vert, topinambour, menthe, champignon, onion, persil, pomme de terre, échalote, patate douce, igname)",
            0.1,
        ),
        (
            "20% (estragon, navet, broccoli, chou, chou-fleur, chicorée, endive, fenouil, cresson, petits pois, poireau, citrouille, endive rouge, salsifis)",
            0.2,
        ),
        ("30% (avocat)", 0.3),
        ("40% (asperge, scarole, laitue, salade)", 0.4),
        ("50% (chataîgne, olive)", 0.5),
        ("60% (artichaut)", 0.6),
        ("◼ AUTRES ◼", ""),
        (" 0% (viande désossée)", 0),
        ("20% (oeuf, viande avec os)", 0.2),
    ]
)
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox(indent=False, style=style, value=True)
w_explain = ipywidgets.Textarea(
    placeholder="Indiquez tous les commentaires nécessaires à la bonne compréhension des choix qui ont été faits, afin d'assurer la traçabilité de l'info",
    layout=ipywidgets.Layout(width="450px", height="200px"),
)

## COMPLEMENTS

# default coef for the ecosystemic services indicators
w_ecosys_hedges = ipywidgets.FloatText(style=style, step=0.01)
w_ecosys_plotSize = ipywidgets.FloatText(step=0.01, style=style)
w_ecosys_cropDiversity = ipywidgets.FloatText(step=0.01, style=style)
w_ecosys_permanentPasture = ipywidgets.FloatText(step=0.01, style=style)
w_ecosys_livestockDensity = ipywidgets.FloatText(step=0.01, style=style)
# parameters used to compute ecosystemicServices
w_cropGroup = ipywidgets.Dropdown(options=CROP_GROUPS, style=style, value=None)
w_landFootprint = ipywidgets.FloatText()
w_scenario = ipywidgets.Dropdown(options=["reference", "organic", "import"], value=None)

# buttons
savebutton = ipywidgets.Button(
    description="Enregistrer localement",
    button_style="warning",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Enregistre l'ingrédient créé ou modifié",
    icon="check",
    layout=ipywidgets.Layout(width="auto"),
)
delbutton = ipywidgets.Button(
    description="Supprimer localement",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Supprime l'ingrédient correspondant à l'identifiant 'id'",
    icon="trash",
    layout=ipywidgets.Layout(width="auto"),
)
resetbutton = ipywidgets.Button(
    description="Réinitialiser",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Annuler tous les changements et revenir à l'état déjà publié",
    icon="sparkles",
)
clear_reset_button = ipywidgets.Button(
    description="X",
    button_style="",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Nettoyer sous le bouton",
    layout=ipywidgets.Layout(width="50px"),
)
clear_git_button = ipywidgets.Button(
    description="X",
    button_style="",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Nettoyer sous le bouton",
    layout=ipywidgets.Layout(width="50px"),
)
clear_save_button = ipywidgets.Button(
    description="X",
    button_style="",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Nettoyer sous les boutons",
    layout=ipywidgets.Layout(width="50px"),
)
commitbutton = ipywidgets.Button(
    description="Publier pour validation",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Publier et soumettre à validation",
    icon="code-commit",
    layout=ipywidgets.Layout(width="auto"),
)


@list_output.capture()
def list_activities(filter=""):
    activities = {
        i: a
        for i, a in read_activities().items()
        if not filter
        or filter.lower() in a["Nom"].lower()
        or filter.lower() in a["id"].lower()
    }
    df = pandas.io.formats.style.Styler(
        pandas.DataFrame(activities.values(), columns=list(FIELDS.values()))
    )
    df.set_properties(**{"background-color": "#EEE"})
    list_output.clear_output()
    display(
        ipywidgets.HTML(
            f"<h2>List of {len(activities)} processes/ingredients:</h2>{df.to_html()}",
            layout=ipywidgets.Layout(width="auto", overflow="scroll"),
        ),
    )


class printer(str):
    def __repr__(self):
        return self


@file_output.capture()
def display_output_file():
    with open(ACTIVITIES_TEMP % w_contributor.value) as fp:
        display(
            printer(json.dumps(json.load(fp), indent=2, ensure_ascii=False)),
            display_id=True,
        )


def display_all():
    list_output.clear_output()
    file_output.clear_output()
    list_activities(w_filter.value)
    display_output_file()


def clear_form():
    w_id.options = tuple([""] + list(read_activities().keys()))
    w_id.value = ""
    w_name.value = ""
    w_database.value = AGRIBALYSE if AGRIBALYSE in bw2data.databases else ""
    w_search.value = ""
    w_results.options = [""]
    w_results.value = ""
    w_category.value = None
    w_categories.value = []
    w_explain.value = ""
    w_default_origin.value = "EuropeAndMaghreb"
    w_raw_to_cooked_ratio.value = 1
    w_density.value = 0
    w_inedible.value = 1
    w_cooling.value = "none"
    w_visible.value = True
    w_ecosys_hedges.value = 0
    w_ecosys_plotSize.value = 0
    w_ecosys_cropDiversity.value = 0
    w_ecosys_permanentPasture.value = 0
    w_ecosys_livestockDensity.value = 0
    w_cropGroup.value = None
    w_landFootprint.value = 0
    w_scenario.value = None


def set_field(field, value, default):
    """the field is supposed to be empty.
    We store the default value but set field.empty=True
    """
    if value is None:
        field.value = default
    else:
        field.value = value
    return field


def display_of(activity):
    return f"{activity['name']} ({activity.get('unit','(aucune)')}) code:{activity['code']}"


def change_contributor(_):
    list_activities(w_filter.value)


w_contributor.observe(change_contributor, names="value")


def change_categories(_):
    pass


w_categories.observe(change_categories, names="value")


def change_id(change):
    if not change.new:
        clear_form()
        return
    i = from_pretty(read_activities().get(change.new, {}))
    if not i:
        return
    set_field(w_name, i.get("name"), "")
    terms = i.get("search", "")
    set_field(w_database, i.get("database"), "")
    set_field(w_search, i.get("search"), "")
    res = dbsearch(w_database.value, terms)
    if res:
        w_results.options = [[display_of(r) for r in res][0]]
    else:
        w_results.options = []
    set_field(
        w_default_origin,
        i.get("default_origin"),
        "EuropeAndMaghreb",
    )
    set_field(w_explain, i.get("explain"), "")
    set_field(w_category, i.get("category"), "")
    set_field(w_categories, i.get("categories"), [])
    set_field(w_raw_to_cooked_ratio, i.get("raw_to_cooked_ratio"), 1)
    set_field(w_density, i.get("density"), 0)
    set_field(w_inedible, i.get("inedible_part"), 0)
    set_field(w_cooling, i.get("transport_cooling"), "none")
    set_field(w_visible, i.get("visible"), True)
    set_field(w_ecosys_hedges, i.get("ecosystemicServices.hedges"), 0)
    set_field(w_ecosys_plotSize, i.get("ecosystemicServices.plotSize"), 0)
    set_field(w_ecosys_cropDiversity, i.get("ecosystemicServices.cropDiversity"), 0)
    set_field(
        w_ecosys_permanentPasture, i.get("ecosystemicServices.permanentPasture"), 0
    )
    set_field(
        w_ecosys_livestockDensity, i.get("ecosystemicServices.livestockDensity"), 0
    )
    set_field(w_scenario, i.get("scenario"), None)
    set_field(w_cropGroup, i.get("crop_group"), None)
    set_field(w_landFootprint, i.get("land_occupation"), 0)


w_id.observe(change_id, names="value")


def changed_database_to(field):
    def changed_database(change):
        results = list(dbsearch(change.new, w_search.value, limit=10))
        field.rows = len(results)
        field.options = [display_of(r) for r in results]
        if results:
            field.value = display_of(results[0])
            display_surface(results[0])
        else:
            surface_output.clear_output()

    return changed_database


def changed_search_to(field):
    def changed_search(change):
        results = list(dbsearch(w_database.value, change.new, limit=10))
        field.rows = len(results)
        field.options = [display_of(r) for r in results]
        if results:
            field.value = display_of(results[0])
            display_surface(results[0])
        else:
            surface_output.clear_output()

    return changed_search


def change_filter(change):
    list_output.clear_output()
    list_activities(change.new)


w_filter.observe(change_filter, names="value")


@save_output.capture()
def add_activity(_):
    activity = {
        "id": w_id.value,
        "name": w_name.value.strip(),
        "database": w_database.value,
        "search": w_search.value.strip(),
        "category": w_category.value,
        "categories": w_categories.value,
        "default_origin": w_default_origin.value,
        "raw_to_cooked_ratio": w_raw_to_cooked_ratio.value,
        "density": w_density.value,
        "inedible_part": w_inedible.value,
        "transport_cooling": w_cooling.value,
        "visible": w_visible.value,
        "explain": w_explain.value.strip(),
    }
    activity.update(
        {
            "ecosystemicServices.hedges": w_ecosys_hedges.value,
            "ecosystemicServices.plotSize": w_ecosys_plotSize.value,
            "ecosystemicServices.cropDiversity": w_ecosys_cropDiversity.value,
            "ecosystemicServices.permanentPasture": w_ecosys_permanentPasture.value,
            "ecosystemicServices.livestockDensity": w_ecosys_livestockDensity.value,
        }
        if "animal_product" in w_categories.value
        or "dairy_product" in w_categories.value
        else {
            "crop_group": w_cropGroup.value,
            "scenario": w_scenario.value,
            "land_occupation": w_landFootprint.value,
        }
    )
    activity = {k: v for k, v in activity.items() if v != ""}
    activities = read_activities()
    if "id" not in activity:
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>Vous devez rentrer un identifiant d'ingrédient (en anglais, en minuscule, sans espace</pre>"
            )
        )
    elif (
        activity["id"].lower() != activity["id"]
        or activity["id"].replace(" ", "") != activity["id"]
    ):
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>L'identifiant doit être en minuscule et sans espace</pre>"
            )
        )
    else:
        save_output.clear_output()
        activities.update({activity["id"]: to_pretty(activity)})
        save_activities(activities)


def delete_activity(_):
    activities = read_activities()
    if w_id.value in activities:
        del activities[w_id.value]
        save_activities(activities)


def current_branch():
    return (
        subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True
        )
        .stdout.decode()
        .strip()
    )


def reset_branch():
    branch = current_branch()
    if subprocess.run(["git", "reset", "--hard"], capture_output=True).returncode != 0:
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>ÉCHEC de la commande: git reset --hard"
            )
        )
    elif subprocess.run(["git", "fetch", "--all"], capture_output=True).returncode != 0:
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>ÉCHEC de la commande: git fetch --all"
            )
        )
    elif (
        subprocess.run(
            ["git", "checkout", f"origin/{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                f"<pre style='color: red'>ÉCHEC de la commande: git checkout origin/{branch}"
            )
        )
    elif (
        subprocess.run(
            ["git", "branch", "-D", f"{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                f"<pre style='color: red'>ÉCHEC de la commande: git branch -D {branch}"
            )
        )
    elif (
        subprocess.run(
            ["git", "branch", f"{branch}", f"origin/{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                f"<pre style='color: red'>ÉCHEC de la commande: git branch {branch} origin/{branch}"
            )
        )
    elif (
        subprocess.run(["git", "checkout", f"{branch}"], capture_output=True).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                f"<pre style='color: red'>ÉCHEC de la commande: git checkout {branch}"
            )
        )
    else:
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>ÉCHEC. Prévenez l'équipe Écobalyse"
            )
        )


@surface_output.capture()
def display_surface(activity):
    surface_output.clear_output()
    display(ipywidgets.HTML("Computing surface... (please wait at least 15s)"))
    lca = bw2calc.LCA({activity: 1})
    method = ("selected LCI results", "resource", "land occupation")
    try:
        lca.lci()
        lca.switch_method(method)
        lca.lcia()
        bwsurface = lca.score
        bwoutput = str(bwsurface)
    except Exception as e:
        bwsurface = 0
        bwoutput = repr(e)
    try:
        process = urllib.parse.quote(activity["name"], encoding=None, errors=None)
        spsurface = json.loads(
            requests.get(
                f"http://simapro.ecobalyse.fr:8000/surface?process={process}"
            ).content
        )["surface"]

        spoutput = str(spsurface)
        spsurface = float(spsurface)
    except Exception as e:
        spsurface = 0
        spoutput = repr(e)
    w_landFootprint.value = spsurface or bwsurface
    surface_output.clear_output()
    display(
        ipywidgets.HTML(
            "<ul>" f"<li>Brightway: {bwoutput}" f"<li>SimaPro: {spoutput}" "</ul>"
        )
    )


@reset_output.capture()
def reset_activities(_):
    branch = current_branch()
    if not w_contributor.value:
        display("Sélectionnez d'abord le bon contributeur")
        return
    elif (
        subprocess.run(
            ["git", "pull", "origin", f"{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                f"<pre style='color: red'>ÉCHEC de la commande: git pull origin {branch}. Prénenez l'équipe Écobalyse'"
            )
        )
        reset_branch()
    else:
        display(
            ipywidgets.HTML(
                f"<pre style='color: green'>SUCCÈS. La liste d'ingrédients et procédés est à jour avec la branche {branch}"
            )
        )

    shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_contributor.value)
    w_id.options = tuple(read_activities().keys())
    clear_form()
    display_all()


def clear_git_output(_):
    git_output.clear_output()


def clear_save_output(_):
    save_output.clear_output()


def clear_reset_output(_):
    reset_output.clear_output()


@git_output.capture()
def commit_activities(_):
    git_output.clear_output()
    branch = current_branch()
    if not w_contributor.value:
        display(ipywidgets.HTML("Sélectionnez d'abord le bon contributeur"))
        return
    shutil.copy(ACTIVITIES_TEMP % w_contributor.value, ACTIVITIES)
    display(ipywidgets.HTML("Veuillez patienter quelques secondes..."))
    if (
        subprocess.run(["npm", "run", "format:json"], capture_output=True).returncode
        != 0
    ):
        display(
            ipywidgets.HTML(
                "<pre style='color: red'>ÉCHEC de la commande: npm run format:json"
            )
        )
        reset_branch()
    elif (
        subprocess.run(["git", "add", ACTIVITIES], capture_output=True).returncode != 0
    ):
        display(
            ipywidgets.HTML("<pre style='color: red'>ÉCHEC de la commande: git add")
        )
        reset_branch()
    elif (
        subprocess.run(
            [
                "git",
                "commit",
                "-m",
                f"Changed ingredients (contributed by {w_contributor.value})",
            ],
            capture_output=True,
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML("<pre style='color: red'>ÉCHEC de la commande: git commit")
        )
        reset_branch()
    elif (
        subprocess.run(
            ["git", "pull", "origin", f"{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML("<pre style='color: red'>ÉCHEC de la commande: git pull")
        )
        reset_branch()
    elif (
        subprocess.run(
            ["git", "push", "origin", f"{branch}"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            ipywidgets.HTML("<pre style='color: red'>ÉCHEC de la commande: git push")
        )
        reset_branch()
    else:
        display(
            ipywidgets.HTML(
                "<pre style='color: green'>SUCCÈS. Merci !! Vous pouvez prévenir l'équipe Écobalyse qu'il y a des nouveautés en attente de validation"
            )
        )


w_database.observe(changed_database_to(w_results), names="value")
w_search.observe(changed_search_to(w_results), names="value")
savebutton.on_click(add_activity)
delbutton.on_click(delete_activity)
resetbutton.on_click(reset_activities)
clear_reset_button.on_click(clear_reset_output)
commitbutton.on_click(commit_activities)
clear_git_button.on_click(clear_git_output)
clear_save_button.on_click(clear_save_output)


branch = current_branch()
list_activities(w_filter.value)
display(
    ipywidgets.HTML("<h1>Éditeur d'ingrédients</h1>"),
    w_contributor,
    ipywidgets.Tab(
        titles=[
            "Documentation",
            "Liste",
            "Formulaire",
            "Aperçu du fichier",
            "Publier",
        ],
        layout=ipywidgets.Layout(width="auto", overflow="scroll"),
        children=[
            ipywidgets.VBox(
                (
                    ipywidgets.HTML(
                        """
<h2>Documentation de cet outil</h2> <ul>
                        """
                        """
<li><b>Étape 1)</b> Cliquez sur le bouton « ▶▶ » dans la barre d'outils supérieure
pour récupérer la dernière version de cet éditeur d'ingrédients. Si l'éditeur
ne se recharge pas, patientez une ou deux minutes puis recommencez</li>
                        """
                        """
<li><b>Étape 2)</b> Cliquez sur le sous-onglet « Liste », puis sélectionnez le
Contributeur pour charger votre liste temporaire d'ingrédients. Vous pouvez
annuler les changements temporaires et revenir à la liste publiée en cliquant
sur le bouton vert « Réinitialiser ». </li>
                        """
                        """
<li><b>Étape 3)</b> Ajouter un ingrédient :</li>
Aller dans le sous-onglet « Formulaire » pour renseigner les caractéristiques
de l’ingrédient à ajouter. <div style="padding-left: 50px">En utilisant
l'explorateur depuis un autre onglet, il faut d'abord identifier l'ICV
correspondant à l’ingrédient souhaité. Prenons l'exemple du sucre de canne. Par
exemple l’ICV « Brown sugar, production, at plant {FR} U » semble être le plus
adapté à l’ingrédient sucre de canne tel qu’il est utilisé en usine. Pour
vérifier qu’il est bien fabriqué à partir de canne à sucre, le sous-onglet
Technosphere de l'explorateur permet de vérifier les procédés qui entrent dans
la composition de « Brown sugar, production, at plant {FR} U ». Il s’agit bien
du procédé « Sugar, from sugarcane {RoW}| sugarcane processing, traditional
annexed plant | Cut-off, S - Copied from Écoinvent U {RoW} ».</div> Après
chaque ingrédient ajouté, cliquez sur « Enregistrer localement ». Réitérez
cette étape pour chaque ingrédient.
                        """
                        """
<li><b>Étape 4)</b> : Validez tous vos ingrédients ajoutés : allez sur l’onglet
« Publier », et cliquez sur le bouton rouge une fois l’ensemble des
modifications faites et les ingrédients ajoutés. Vos modifications arrivent sur
la branche indiquée et pourra être vérifiée et intégrée en production dans
Ecobalyse</li></ul>
                        """
                    ),
                )
            ),
            ipywidgets.VBox(
                (
                    ipywidgets.HBox((resetbutton, clear_reset_button)),
                    w_filter,
                    reset_output,
                    list_output,
                )
            ),
            ipywidgets.VBox(
                (
                    ipywidgets.HTML(
                        "Identifiant technique de l'ingrédient à ajouter, modifier ou supprimer (en anglais, sans espace) : "
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["id"],
                            ),
                            w_id,
                        ),
                    ),
                    ipywidgets.HBox((savebutton, delbutton, clear_save_button)),
                    ipywidgets.VBox((save_output,)),
                    ipywidgets.HTML(
                        "<hr/>Nom de l'ingrédient tel qu'il va apparaître dans l'outil (en français) :"
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["name"],
                            ),
                            w_name,
                        ),
                    ),
                    ipywidgets.HTML(
                        """<hr/>Mots clés permettant de faire remonter le bon ICV Agribalyse en
                        <b>premier</b> dans la liste des résultats. Il faut rester le plus succint
                        possible pour que les termes de recherche restent valable dans une future
                        version d'Agribalyse. Si vous ne pouvez pas différencier deux procédés vous
                        pouvez préciser son code avec: <i>code:1234567890...</i>. Vous pouvez vous
                        aider de l'explorateur dans un autre onglet pour naviguer dans
                        Agribalyse."""
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label("Base de données"),
                            w_database,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label("Termes de recherche"),
                            w_search,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                "Résultats",
                            ),
                            w_results,
                        ),
                    ),
                    ipywidgets.HTML("<hr/>Surface mobilisée :"),
                    surface_output,
                    ipywidgets.HTML(
                        "<hr/>Pour un ingrédient, renseignez « ingrédient » :"
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["category"],
                            ),
                            w_category,
                        ),
                    ),
                    ipywidgets.Accordion(
                        titles=["Si le procédé est un ingrédient"],
                        children=[
                            ipywidgets.VBox(
                                (
                                    ipywidgets.HTML(
                                        """Indiquez « visible » pour que l'ingrédient soit visible
                                        dans Écobalyse. (Un ingrédient en attente peut être publié
                                        mais invisible) :"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["visible"],
                                            ),
                                            w_visible,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>Sélectionnez la catégorie principale de
                                        l'ingrédient. (par exemple un sucre de canne peut être
                                        catégorisé comme légume transformé, par analogie avec le
                                        sucre de betterave). Si l'ingrédient dispose d'un label
                                        (bio, bleublanccoeur) ajoutez cette catégorie à la suite de
                                        la catégorie principale """
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["categories"],
                                            ),
                                            w_categories,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>Indiquez l'origine par défaut. Se référer à la <a
                                        style="color:blue"
                                        href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/transport">documentation
                                        Écobalyse</a>"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["default_origin"],
                                            ),
                                            w_default_origin,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>Le rapport cuit/cru est nécessaire pour le calcul
                                        d'impact. Si besoin se référer à la <a style="color:blue"
                                        href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/rapport-cru-cuit">documentation
                                        Écobalyse</a>, page « rapport cuit/cru » qui reprend les
                                        règles Agribalyse :"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["raw_to_cooked_ratio"],
                                            ),
                                            w_raw_to_cooked_ratio,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """ <hr/>La densité est nécessaire pour le calcul d'impact.
                                        Si besoin se référer à la <a style="color:blue"
                                        href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/densite">documentation
                                        Écobalyse</a>, page « densité » , qui reprend les règles
                                        Agribalyse"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["density"],
                                            ),
                                            w_density,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>La part non comestible est nécessaire pour le calcul
                                        d'impact. Si besoin se référer à la <a style="color:blue"
                                        href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/part-non-comestible">documentation
                                        Écobalyse</a>, page « part non-comestible, qui reprend les
                                        règles Agribalyse. En l'absence d'info, prendre un
                                        ingrédient équivalent en terme de part non comestible"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["inedible_part"],
                                            ),
                                            w_inedible,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        "<hr/>Sélectionnez le mode de transport : régrigéré ou non"
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["transport_cooling"],
                                            ),
                                            w_cooling,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>Indiquez tous les commentaires nécessaires à la bonne
                                        compréhension des choix qui ont été faits, afin d'assurer la
                                        traçabilité de l'info"""
                                    ),
                                    ipywidgets.HBox(
                                        (
                                            ipywidgets.Label(
                                                FIELDS["explain"],
                                            ),
                                            w_explain,
                                        ),
                                    ),
                                    ipywidgets.HTML(
                                        """<hr/>Pour les services écosystémiques, voir
                                            la <a style="color:blue"
                                            href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/complements-hors-acv">documentation</a>
                                            (TODO: mettre à jour le lien)
                                            """
                                    ),
                                    ipywidgets.Accordion(
                                        titles=[
                                            "Services écosystémiques : Ingrédients d'origine animale",
                                            "Services écosystémiques : Autres ingrédients",
                                        ],
                                        children=[
                                            ipywidgets.VBox(
                                                [
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "ecosystemicServices.hedges"
                                                                ],
                                                            ),
                                                            w_ecosys_hedges,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "ecosystemicServices.plotSize"
                                                                ],
                                                            ),
                                                            w_ecosys_plotSize,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "ecosystemicServices.cropDiversity"
                                                                ],
                                                            ),
                                                            w_ecosys_cropDiversity,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "ecosystemicServices.permanentPasture"
                                                                ],
                                                            ),
                                                            w_ecosys_permanentPasture,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "ecosystemicServices.livestockDensity"
                                                                ],
                                                            ),
                                                            w_ecosys_livestockDensity,
                                                        ),
                                                    ),
                                                ]
                                            ),
                                            ipywidgets.VBox(
                                                [
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS["crop_group"],
                                                            ),
                                                            w_cropGroup,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS["scenario"],
                                                            ),
                                                            w_scenario,
                                                        ),
                                                    ),
                                                    ipywidgets.HBox(
                                                        (
                                                            ipywidgets.Label(
                                                                FIELDS[
                                                                    "land_occupation"
                                                                ],
                                                            ),
                                                            w_landFootprint,
                                                        ),
                                                    ),
                                                ]
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                )
            ),
            ipywidgets.VBox(
                (ipywidgets.HTML(f"<h2>Fichier JSON résultant:</h2>"), file_output)
            ),
            ipywidgets.VBox(
                [
                    ipywidgets.HTML(
                        f"""Si vous êtes satisfait(e) de vos modifications locales, vous devez
                        <b>publier</b> vos modifications, qui vont alors arriver dans la branche <a
                        style="color:blue"
                        href="https://github.com/MTES-MCT/ecobalyse/tree/{branch}">{branch}</a>
                        du dépôt Écobalyse.<br/> L'équipe Écobalyse pourra ensuite recalculer les
                        impacts et intégrer vos contributions."""
                    ),
                    ipywidgets.HBox((commitbutton, clear_git_button)),
                    git_output,
                ]
            ),
        ],
    ),
)
