from IPython.core.display import display, Markdown
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


def dbsearch(term, **kw):
    return DATABASE.search(term, **kw)


def save_activities(activities):
    with open(ACTIVITIES_TEMP, "w") as fp:
        fp.write(
            json.dumps(
                [from_flat(from_pretty(i)) for i in activities.values()],
                indent=2,
                ensure_ascii=False,
            )
        )
    clear_form()


def to_flat(d):
    return dict(FlatDict(d, delimiter="."))


def from_flat(d):
    return FlatDict(d, delimiter=".").as_dict()


def reverse(d):
    """turn the values of a dict into keys and keys into values"""
    return {v: k for k, v in d.items()}


FIELDS = {
    "id": "id",
    "name": "Nom",
    "search": "Terme de recherche",
    "default_origin": "Default Origin",
    "category": "Categorie de procédé",
    "categories": "Categories d'ingrédient",
    "raw_to_cooked_ratio": "Ratio cuit/cru",
    "density": "Densité",
    "inedible_part": "Part non comestible",
    "transport_cooling": "Transport Cooling",
    "visible": "Visible",
    "bvi": "Bio-diversité",
    "explain": "Détails",
    "subingredient_default": "Sous-ingrédient conventionnel",
    "subingredient_organic": "Sous-ingrédient bio",
    "ratio": "Ratio Complexe/Simple",
    "complements.agro-diversity": "Agro Diversity",
    "complements.agro-ecology": "Agro Ecology",
    "complements.animal-welfare": "Animal Welfare",
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
## Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    value=1,
    min=0,
    step=0.05,
    style=style,
)
## density of the ingredient
w_density = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    value=1,
    min=0,
    step=0.05,
    style=style,
)
## inedible part of the ingredient
w_inedible = ipywidgets.BoundedFloatText(
    placeholder="Part non comestible",
    value=0,
    min=0,
    max=1,
    style=style,
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
    disabled=False,
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
w_ratio = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    min=0,
    step=0.05,
    style=style,
)

## COMPLEMENTS

# default coef for the complement indicators
w_complement_agrodiv = ipywidgets.IntSlider(
    placeholder="Agro-diversity coefficient",
    style=style,
    min=0,
    max=100,
    step=5,
)
w_complement_agroeco = ipywidgets.IntSlider(
    placeholder="Agro-ecology coefficient",
    min=0,
    max=100,
    step=5,
    style=style,
)
w_complement_animal_welfare = ipywidgets.IntSlider(
    placeholder="Animal Welfare coefficient",
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
out = ipywidgets.Output()
outgit = ipywidgets.Output()


@out.capture()
def list_activities():
    activities = read_activities()
    with open(ACTIVITIES_TEMP) as fp:
        pandas.set_option("display.max_rows", 500)
        display(
            Markdown(f"# List of {len(activities)} activities/ingredients:"),
            pandas.DataFrame(activities.values(), columns=list(FIELDS.values())),
            Markdown(f"# Resulting JSON file:"),
        )
        display(print(json.dumps(json.load(fp), indent=2, ensure_ascii=False)))


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
    out.clear_output()
    list_activities()


def delete_activity(_):
    activities = read_activities()
    if w_id.value in activities:
        del activities[w_id.value]
        save_activities(activities)
    out.clear_output()
    list_activities()


def commit_activities(_):
    shutil.copy(ACTIVITIES_TEMP, ACTIVITIES)
    outgit.clear_output()
    with outgit:
        try:
            assert (
                subprocess.run(["git", "pull", "origin", "ingredients"]).returncode == 0
            ), "git pull failed"
            assert (
                subprocess.run(["git", "add", ACTIVITIES]).returncode == 0
            ), "git add failed"
            assert (
                subprocess.run(
                    ["git", "commit", "-m", "Changed ingredients"]
                ).returncode
                == 0
            ), "git commit failed"
            assert (
                subprocess.run(["git", "push", "origin", "ingredients"]).returncode == 0
            ), "git push failed"
            print("SUCCEEDED. Please tell the devs")
        except:
            subprocess.run(["git", "reset", "--hard"])
            subprocess.run(["git", "checkout", "origin/ingredients"])
            subprocess.run(["git", "branch", "-D", "ingredients"])
            subprocess.run(["git", "branch", "ingredients", "origin/ingredients"])
            subprocess.run(["git", "checkout", "ingredients"])
            print("FAILED. Please tell the devs")
    out.clear_output()
    list_activities()


def reset_activities(_):
    shutil.copy(ACTIVITIES, ACTIVITIES_TEMP)
    out.clear_output()
    list_activities()
    w_id.options = tuple(read_activities().keys())


def clear_form():
    w_id.options = tuple([""] + list(read_activities().keys()))
    w_id.value = ""
    w_name.value = ""
    w_search.value = ""
    w_results.options = [""]
    w_results.value = ""
    w_category.value = None
    w_categories.value = []
    w_default_origin.value = "EuropeAndMaghreb"
    w_raw_to_cooked_ratio.value = 0
    w_density.value = 0
    w_inedible.value = 0
    w_cooling.value = "none"
    w_visible.value = True
    w_bvi.value = 0
    w_subingredient_default.value = ""
    w_subingredient_organic.value = ""
    w_ratio.value = 0
    w_complement_agrodiv.value = 0
    w_complement_agroeco.value = 0
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
    set_field(w_raw_to_cooked_ratio, i.get("raw_to_cooked_ratio"), 0)
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


def display_of(activity):
    return f"{activity['name']} ({activity.get('unit','(aucune)')}) code:{activity['code']}"


def change_search_of(field):
    def change_search(change):
        results = list(dbsearch(change.new, limit=20))
        field.rows = len(results)
        field.options = [display_of(r) for r in results]
        if results:
            field.value = display_of(results[0])

    return change_search


w_id.observe(change_id, names="value")
w_search.observe(change_search_of(w_results), names="value")
savebutton.on_click(add_activity)
delbutton.on_click(delete_activity)
resetbutton.on_click(reset_activities)
commitbutton.on_click(commit_activities)


display(
    Markdown("# Procédé à ajouter/modifier/supprimer :"),
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
        titles=["Compléments hors ACV"],
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
    outgit,
    out,
)

list_activities()
