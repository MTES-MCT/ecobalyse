from IPython.core.display import display, Markdown, clear_output
from flatdict import FlatDict
import bw2data
import ipywidgets
import json
import os
import pandas
import shutil
import subprocess


os.chdir("/home/jovyan/ecobalyse/data")
PROJECT = "Ecobalyse"
ACTIVITIES = "/home/jovyan/ecobalyse/data/food/export_agb/activities.json"
ACTIVITIES_TEMP = "/home/jovyan/activities.json"
os.getcwd()

bw2data.projects.set_current(PROJECT)
DATABASE = bw2data.Database("Agribalyse 3.1.1")

list_output = ipywidgets.Output()
git_output = ipywidgets.Output()

pandas.set_option("display.max_columns", 500)
pandas.set_option("display.max_rows", 500)
pandas.set_option("notebook_repr_html", True)
pandas.set_option("max_colwidth", 15)


def dbsearch(term, **kw):
    return DATABASE.search(term, **kw)


def cleanup_json(activities):
    for i, a in enumerate(activities):
        # remove uneeded complex ingredient attributes on simple ingredients
        if not a.get("subingredient_default") or not a.get("subingredient_organic"):
            for x in ("subingredient_default", "subingredient_organic", "ratio"):
                _ = activities[i].pop(x, None)
        # remove animal-welfare for non animal products
        if (
            "animal_product" not in a.get("categories", {})
            and "dairy_product" not in a.get("categories", {})
            and "animal-welfare" in a.get("complements", {})
        ):
            del activities[i]["complements"]["animal-welfare"]
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
    with open(ACTIVITIES_TEMP, "w") as fp:
        fp.write(
            json.dumps(
                cleanup_json([from_flat(from_pretty(i)) for i in activities.values()]),
                indent=2,
                ensure_ascii=False,
            )
        )
    with list_output:
        clear_output()
        list_activities()


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
    "search": "Terme de recherche",
    "default_origin": "Default Origin",
    "category": "Categorie de procédé",
    "bvi": "Bio-diversité",
    # ingredients attributes
    "categories": "Categories d'ingrédient",
    "raw_to_cooked_ratio": "Ratio cuit/cru",
    "density": "Densité",
    "inedible_part": "Part non comestible",
    "transport_cooling": "Transport Cooling",
    "visible": "Visible",
    "explain": "Détails",
    # complex ingredients attributes
    "subingredient_default": "Sous-ingrédient conv.",
    "subingredient_organic": "Sous-ingrédient bio",
    "ratio": "Ratio",
    # complements
    "complements.agro-diversity": "AgroDiv",
    "complements.agro-ecology": "AgroEco",
    "complements.animal-welfare": "Animal welf",
}


def to_pretty(d):
    """turn a dict with dotted keys to a dict with pretty keys"""
    return {FIELDS[k]: v for k, v in d.items() if FIELDS.get(k)}


def from_pretty(d):
    """turn a dict with pretty keys to a dict with dotted keys"""
    activity = {reverse(FIELDS)[k]: v for k, v in d.items()}
    # if not activity.get("variants"):
    #    activity["variants"] = {}
    return activity


def read_activities():
    """Return the activities as a dict indexed with id"""
    if not os.path.exists(ACTIVITIES_TEMP):
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP)
    try:
        with open(ACTIVITIES_TEMP) as fp:
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}
    except json.JSONDecodeError:
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP)
        with open(ACTIVITIES_TEMP) as fp:
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}

    return igs


# WIDGETS
## technical identifier of the activity (for API/URL/FK)
style = {"description_width": "initial"}
w_id = ipywidgets.Combobox(
    placeholder="Identifier",
    style=style,
    options=tuple([""] + list(read_activities().keys())),
)
## Name of the activity (for users)
w_name = ipywidgets.Text(
    placeholder="Name",
    style=style,
)
## Is the activity an ingredient?
w_ingredient = ipywidgets.Checkbox(indent=False, style=style, value=False)
## brightway search terms to find the activity
w_search = ipywidgets.Text(placeholder="wheat FR farm", style=style)
w_results = ipywidgets.RadioButtons(
    rows=1,
    options=[""],
    style=style,
    layout=ipywidgets.Layout(width="auto"),
    disabled=True,
)
## default origin
w_default_origin = ipywidgets.Dropdown(
    options=[
        ("Europe et Maghreb", "EuropeAndMaghreb"),
        ("Hors Europe et Maghreb", "OutOfEuropeAndMaghreb"),
        ("France", "France"),
        ("Par avion, hors Europe et Maghreb", "OutOfEuropeAndMaghrebByPlane"),
    ],
    style=style,
)
w_category = ipywidgets.Dropdown(
    options=[
        ("Ingrédient", "ingredient"),
        ("Autre ou sous-ingrédient", "material"),
        ("Énergie", "energy"),
        ("Packaging", "packaging"),
        ("Processing", "processing"),
        ("Transformation", "transformation"),
        ("Transport", "transport"),
        ("Waste Treatment", "waste treatment"),
    ],
)
w_categories = ipywidgets.TagsInput(
    allowed_tags=[
        ("animal_product"),
        ("dairy_product"),
        ("grain_raw"),
        ("grain_processed"),
        ("nut_oilseed_raw"),
        ("nut_oilseed_processed"),
        ("misc"),
        ("spice_condiment_additive"),
        ("vegetable_fresh"),
        ("vegetable_processed"),
        ("organic"),
        ("bleublanccoeur"),
    ],
    style=style,
    allow_duplicates=False,
)
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    options=[
        ("Aucun", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
    style=style,
)
# Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.Dropdown(
    options=[
        ("1.0", 1.0),
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
        ("◼◼◼◼◼ FRUITS ◼◼◼◼◼", ""),
        (" 3% (tomate, mures, myrtilles, framboises, fraises)", 0.03),
        ("10% (pommes, poire, raisin)", 0.1),
        (
            "20% (abricot, groseille, mandarine, mangue, orange, pêche, prune, grenade)",
            0.2,
        ),
        ("30% (banane, pamplemousse, citron)", 0.3),
        ("40% (melon)", 0.4),
        ("50% (amandes, ananas, noix)", 0.5),
        ("◼◼◼◼◼ LEGUMES ◼◼◼◼◼", ""),
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
        ("◼◼◼◼◼ AUTRES ◼◼◼◼◼", ""),
        (" 0% (viande désossée)", 0),
        ("20% (oeuf, viande avec os)", 0.2),
    ]
)
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox(indent=False, style=style, value=True)
## Biodiv
w_bvi = ipywidgets.BoundedFloatText(
    placeholder="Bio diversité",
    # value=0,
    min=0,
    style=style,
)
w_explain = ipywidgets.Textarea(
    placeholder="Détails sur les valeurs de l'ingredient",
    layout=ipywidgets.Layout(width="450px", height="200px"),
)

# Missing Organic activity, we need to build one using subingredients
w_subingredient_default = ipywidgets.Combobox(
    placeholder="wheat grain conventional",
    style=style,
    ensure_option=False,
    options=tuple([""] + list(read_activities().keys())),
)
w_subingredient_organic = ipywidgets.Combobox(
    placeholder="wheat grain organic",
    style=style,
    ensure_option=False,
    options=tuple([""] + list(read_activities().keys())),
)
## Quantity of component necessary to produce 1 unit of constructed process.
##For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16",
w_ratio = ipywidgets.BoundedFloatText(placeholder="Coef", min=0, step=0.05, style=style)

## COMPLEMENTS

# default coef for the complement indicators
w_complement_agrodiv = ipywidgets.IntSlider(
    style=style,
    min=0,
    max=100,
    step=5,
)
w_complement_agroeco = ipywidgets.IntSlider(
    min=0,
    max=100,
    step=5,
    style=style,
)
w_complement_animal_welfare = ipywidgets.IntSlider(
    min=0,
    max=100,
    step=5,
    style=style,
)

# buttons
savebutton = ipywidgets.Button(
    description="Save",
    button_style="warning",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Add or update the activity",
    icon="check",
)
delbutton = ipywidgets.Button(
    description="Delete",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Delete the activity with the 'id' field above",
    icon="trash",
)
getbutton = ipywidgets.Button(
    description="Get",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Fill the form with ingedient from the 'id' field",
    icon="down-to-bracket",
)
resetbutton = ipywidgets.Button(
    description="Reset from branch",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Reset the activities to the branch state",
    icon="sparkles",
)
commitbutton = ipywidgets.Button(
    description="Publish",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Commit the activities into the branch",
    icon="code-commit",
)


def list_activities():
    activities = read_activities()
    with open(ACTIVITIES_TEMP) as fp:
        df = pandas.DataFrame(activities.values(), columns=list(FIELDS.values()))
        df.style
        display(
            Markdown(f"# List of {len(activities)} activities/ingredients:"),
            df,
            Markdown(f"# Resulting JSON file:"),
        )
        display(print(json.dumps(json.load(fp), indent=2, ensure_ascii=False)))


with list_output:
    clear_output()
    list_activities()


def clear_form():
    w_id.options = tuple([""] + list(read_activities().keys()))
    w_id.value = ""
    w_name.value = ""
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
    w_bvi.value = 0
    w_subingredient_default.value = ""
    w_subingredient_organic.value = ""
    w_ratio.value = 0
    w_complement_agrodiv.value = 0
    w_complement_agroeco.value = 0
    w_complement_animal_welfare.disabled = False
    w_complement_animal_welfare.value = 0


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


def change_categories(change):
    w_complement_animal_welfare.disabled = (
        False
        if "animal_product" in w_categories.value
        or "dairy_product" in w_categories.value
        or not w_categories.value
        else True
    )


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
    set_field(w_search, i.get("search"), "")
    res = dbsearch(terms)
    if res:
        w_results.options = [[display_of(r) for r in res][0]]
    else:
        w_results.options = []
    set_field(
        w_default_origin,
        i.get("default_origin"),
        "EuropeAndMaghreb",
    )
    set_field(w_category, i.get("category"), "")
    set_field(w_categories, i.get("categories"), [])
    set_field(w_raw_to_cooked_ratio, i.get("raw_to_cooked_ratio"), 1)
    set_field(w_density, i.get("density"), 0)
    set_field(w_inedible, i.get("inedible_part"), 0)
    set_field(w_cooling, i.get("transport_cooling"), "none")
    set_field(w_visible, i.get("visible"), True)
    set_field(w_bvi, i.get("bvi"), 0)
    set_field(w_subingredient_default, i.get("subingredient_default"), "")
    set_field(w_subingredient_organic, i.get("subingredient_organic"), "")
    set_field(w_ratio, i.get("ratio"), 0)
    set_field(w_complement_agrodiv, i.get("complements.agro-diversity"), 0)
    set_field(w_complement_agroeco, i.get("complements.agro-ecology"), 0)
    set_field(
        w_complement_animal_welfare,
        i.get("complements.animal-welfare"),
        0,
    )


w_id.observe(change_id, names="value")


def change_search_of(field):
    def change_search(change):
        results = list(dbsearch(change.new, limit=20))
        field.rows = len(results)
        field.options = [display_of(r) for r in results]
        if results:
            field.value = display_of(results[0])

    return change_search


def add_activity(_):
    activity = {
        "id": w_id.value,
        "name": w_name.value,
        "search": w_search.value,
        "category": w_category.value,
        "categories": w_categories.value,
        "default_origin": w_default_origin.value,
        "raw_to_cooked_ratio": w_raw_to_cooked_ratio.value,
        "density": w_density.value,
        "inedible_part": w_inedible.value,
        "transport_cooling": w_cooling.value,
        "visible": w_visible.value,
        "bvi": w_bvi.value,
        "explain": w_explain.value,
        "subingredient_default": w_subingredient_default.value,
        "subingredient_organic": w_subingredient_organic.value,
        "ratio": w_ratio.value,
        "complements.agro-diversity": w_complement_agrodiv.value,
        "complements.agro-ecology": w_complement_agroeco.value,
        "complements.animal-welfare": w_complement_animal_welfare.value,
    }
    activity = {k: v for k, v in activity.items() if v != ""}
    activities = read_activities()
    if "id" in activity:
        activities.update({activity["id"]: to_pretty(activity)})
        save_activities(activities)


def delete_activity(_):
    activities = read_activities()
    if w_id.value in activities:
        del activities[w_id.value]
        save_activities(activities)
        clear_form()


def reset_branch():
    if subprocess.run(["git", "reset", "--hard"]).returncode != 0:
        print("FAILED: git reset --hard")
    elif subprocess.run(["git", "fetch", "--all"]).returncode != 0:
        print("FAILED: git fetch --all")
    elif subprocess.run(["git", "checkout", "origin/ingredients"]).returncode != 0:
        print("FAILED: git checkout origin/ingredients")
    elif subprocess.run(["git", "branch", "-D", "ingredients"]).returncode != 0:
        print("FAILED: git branch -D ingredients")
    elif (
        subprocess.run(
            ["git", "branch", "ingredients", "origin/ingredients"]
        ).returncode
        != 0
    ):
        print("FAILED: git branch ingredients origin/ingredients")
    elif subprocess.run(["git", "checkout", "ingredients"]).returncode != 0:
        print("FAILED: git checkout ingredients")
    else:
        print("FAILED. Please tell the devs")


def reset_activities(_):
    with git_output:
        try:
            if subprocess.run(["git", "pull", "origin", "ingredients"]).returncode != 0:
                print("FAILED: git pull")
            else:
                print(
                    "SUCCEEDED. The activity is now up to date with the ingredients branch"
                )
        except:
            reset_branch()

    shutil.copy(ACTIVITIES, ACTIVITIES_TEMP)
    w_id.options = tuple(read_activities().keys())
    with list_output:
        clear_output()
        list_activities()


def commit_activities(_):
    shutil.copy(ACTIVITIES_TEMP, ACTIVITIES)
    with git_output:
        try:
            if subprocess.run(["git", "pull", "origin", "ingredients"]).returncode != 0:
                print("FAILED: git pull")
            elif subprocess.run(["git", "add", ACTIVITIES]).returncode != 0:
                print("FAILED: git add")
            elif (
                subprocess.run(
                    ["git", "commit", "-m", "Changed ingredients"]
                ).returncode
                != 0
            ):
                print("FAILED: git commit")
            elif (
                subprocess.run(["git", "push", "origin", "ingredients"]).returncode != 0
            ):
                print("FAILED: git push")
            else:
                print("SUCCEEDED. Please tell the devs to merge the ingredients branch")
        except:
            reset_branch()


w_search.observe(change_search_of(w_results), names="value")
savebutton.on_click(add_activity)
delbutton.on_click(delete_activity)
resetbutton.on_click(reset_activities)
commitbutton.on_click(commit_activities)


display(
    ipywidgets.HTML(
        value="<h1>Avant de commencer</h1>Appuyez sur le bouton ▸▸ dans la barre d'outil, puis sur le bouton vert « Reset from branch »"
    ),
    Markdown("# Procédé à ajouter/modifier/supprimer :"),
    ipywidgets.HBox(
        (
            ipywidgets.Label(
                FIELDS["id"],
            ),
            w_id,
        ),
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
        value="Le terme de recherche doit être minimal et permettre d'arriver au bon procédé. Le procédé sélectionné est le premier de la liste. Si vous ne pouvez pas différencier deux procédés vous pouvez indiquer son code avec : <i>code:1234567890....</i>"
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(
                "Search (" + DATABASE.name + ")",
            ),
            w_search,
        ),
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(
                "Résultat de recherche",
            ),
            w_results,
        ),
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(
                FIELDS["category"],
            ),
            w_category,
        ),
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(
                FIELDS["bvi"],
            ),
            w_bvi,
        ),
    ),
    ipywidgets.Accordion(
        titles=["Si le procédé est un ingrédient"],
        children=[
            ipywidgets.VBox(
                (
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["visible"],
                            ),
                            w_visible,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["categories"],
                            ),
                            w_categories,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["default_origin"],
                            ),
                            w_default_origin,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["raw_to_cooked_ratio"],
                            ),
                            w_raw_to_cooked_ratio,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["density"],
                            ),
                            w_density,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["inedible_part"],
                            ),
                            w_inedible,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["transport_cooling"],
                            ),
                            w_cooling,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["explain"],
                            ),
                            w_explain,
                        ),
                    ),
                ),
            ),
        ],
    ),
    ipywidgets.Accordion(
        titles=["Si l'ingrédient est bio mais n'a pas de procédé bio"],
        children=[
            ipywidgets.VBox(
                (
                    ipywidgets.HTML(
                        value="Sélectionnez les sous-ingrédients conventionnel et bio permettant de créer le nouvel ingrédient bio. Ces sous-ingrédients doivent prélablement avoir été ajoutés à la liste"
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["subingredient_default"],
                            ),
                            w_subingredient_default,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["subingredient_organic"],
                            ),
                            w_subingredient_organic,
                        ),
                    ),
                    ipywidgets.HTML(
                        value="Le ratio est la quantité de sous-ingrédient simple nécessaire pour produire 1 unité d'ingrédient bio. Vous avez besoin de 1.16 kg de blé (sous-ingrédient) pour produire 1 kg de farine (ingrédient final) -> ratio = 1.16. Formule: Impact farine bio = impact farine conventionnelle + ratio * ( impact blé bio -  impact blé c  onventionnel)"
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["ratio"],
                            ),
                            w_ratio,
                        ),
                    ),
                ),
            ),
        ],
    ),
    ipywidgets.Accordion(
        titles=["Compléments hors ACV (ingrédient uniquement)"],
        children=[
            ipywidgets.VBox(
                (
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["complements.agro-diversity"],
                            ),
                            w_complement_agrodiv,
                        ),
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["complements.agro-ecology"],
                            ),
                            w_complement_agroeco,
                        ),
                    ),
                    ipywidgets.HTML(
                        value="Le bien-être animal n'est exporté que si l'ingrédient est dans la catégorie <i>animal_product</i> ou <i>dairy_product</i>"
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["complements.animal-welfare"],
                            ),
                            w_complement_animal_welfare,
                        ),
                    ),
                ),
            ),
        ],
    ),
    ipywidgets.HBox((savebutton, delbutton)),
    Markdown("# Reset or Publish activities :"),
    Markdown(
        "Reset the activities to the branch state, or Publish to the `ingredients` branch"
    ),
    ipywidgets.HBox((resetbutton, commitbutton)),
    git_output,
    list_output,
)
