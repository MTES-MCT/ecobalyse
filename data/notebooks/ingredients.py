"""
This file is the ingredient/activity editor Jupyter Notebook
"""
print("Please wait")
import sys
import os

sys.stdout = open(os.devnull, "w")
from bw2data.project import projects

sys.stdout = sys.__stdout__
from flatdict import FlatDict
import bw2data
import ipywidgets
import json
import pandas
import pandas.io.formats.style
import shutil
import subprocess


os.chdir("/home/jovyan/ecobalyse/data")
PROJECT = "food"
ACTIVITIES = "/home/jovyan/ecobalyse/data/food/activities.json"
ACTIVITIES_TEMP = "/home/jovyan/activities.%s.json"

projects.set_current(PROJECT)
# projects.create_project(PROJECT, activate=True, exist_ok=True)
DATABASE = bw2data.Database("Agribalyse 3.1.1")

list_output = ipywidgets.Output()
git_output = ipywidgets.Output()
reset_output = ipywidgets.Output()
file_output = ipywidgets.Output()

pandas.set_option("display.max_columns", 500)
pandas.set_option("display.max_rows", 500)
pandas.set_option("notebook_repr_html", True)
pandas.set_option("max_colwidth", 15)


def dbsearch(term, **kw):
    return DATABASE.search(term, **kw)


def cleanup_json(activities):
    """consistency of the json file"""
    for i, a in enumerate(activities):
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
    with open(ACTIVITIES_TEMP % w_institut.value, "w") as fp:
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
    "search": "Termes de recherche",
    "default_origin": "Origine par défaut",
    "category": "Catégorie de procédé",
    "bvi": "Bio-diversité",
    # ingredients attributes
    "categories": "Catégories d'ingrédient",
    "raw_to_cooked_ratio": "Cooked/Raw ratio",
    "density": "Densité",
    "inedible_part": "Part non comestible",
    "transport_cooling": "Transport réfrigéré",
    "visible": "Visible",
    "explain": "Commentaires",
    # complements
    "complements.agro-diversity": "Biodiversité territoriale",
    "complements.agro-ecology": "Résilience territoriale",
    "complements.animal-welfare": "Conditions d'élevage",
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
    if not os.path.exists(ACTIVITIES_TEMP % w_institut.value):
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_institut.value)
    try:
        with open(ACTIVITIES_TEMP % w_institut.value) as fp:
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}
    except json.JSONDecodeError:
        shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_institut.value)
        with open(ACTIVITIES_TEMP % w_institut.value) as fp:
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}

    return igs


# WIDGETS
## technical identifier of the activity (for API/URL/FK)
style = {"description_width": "initial"}
w_institut = ipywidgets.Dropdown(
    options=["Écobalyse", "ITERG", "ACTALIA", "IFV"],
    value=None,
    style=style,
    description="Contributeur : ",
)
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
            "Par avion, hors Europe ou Maghreb (mangue, horicots, ...)",
            "OutOfEuropeAndMaghrebByPlane",
        ),
    ],
    style=style,
)
w_category = ipywidgets.Dropdown(
    options=[
        ("Ingrédient", "ingredient"),
        ("Matériau ou sous-ingrédient", "material"),
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
## Biodiv
w_bvi = ipywidgets.BoundedFloatText(
    placeholder="0",
    # value=0,
    min=0,
    style=style,
)
w_explain = ipywidgets.Textarea(
    placeholder="Indiquez tous les commentaires nécessaires à la bonne compréhension des choix qui ont été faits, afin d'assurer la traçabilité de l'info",
    layout=ipywidgets.Layout(width="450px", height="200px"),
)

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
commitbutton = ipywidgets.Button(
    description="Publier pour validation",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Publier et soumettre à validation",
    icon="code-commit",
    layout=ipywidgets.Layout(width="auto"),
)


@list_output.capture()
def list_activities():
    activities = read_activities()
    df = pandas.io.formats.style.Styler(
        pandas.DataFrame(activities.values(), columns=list(FIELDS.values()))
    )
    df.set_properties(**{"background-color": "#EEE"})
    display(
        ipywidgets.HTML(
            f"<h2>List of {len(activities)} processes/ingredients:</h2>{df.to_html()}"
        ),
    )


class printer(str):
    def __repr__(self):
        return self


@file_output.capture()
def display_output_file():
    with open(ACTIVITIES_TEMP % w_institut.value) as fp:
        display(
            printer(json.dumps(json.load(fp), indent=2, ensure_ascii=False)),
            display_id=True,
        )


def display_all():
    list_output.clear_output()
    file_output.clear_output()
    list_activities()
    display_output_file()


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
        results = list(dbsearch(change.new, limit=10))
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


def reset_branch():
    if subprocess.run(["git", "reset", "--hard"], capture_output=True).returncode != 0:
        display("ÉCHEC de la commande: git reset --hard")
    elif subprocess.run(["git", "fetch", "--all"], capture_output=True).returncode != 0:
        display("ÉCHEC de la commande: git fetch --all")
    elif (
        subprocess.run(
            ["git", "checkout", "origin/ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git checkout origin/ingredients")
    elif (
        subprocess.run(
            ["git", "branch", "-D", "ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git branch -D ingredients")
    elif (
        subprocess.run(
            ["git", "branch", "ingredients", "origin/ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git branch ingredients origin/ingredients")
    elif (
        subprocess.run(
            ["git", "checkout", "ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git checkout ingredients")
    else:
        display("ÉCHEC. Prévenez l'équipe Écobalyse")


@reset_output.capture()
def reset_activities(_):
    if not w_institut:
        display("Sélectionnez d'abord le bon contributeur")
        return
    elif (
        subprocess.run(
            ["git", "pull", "origin", "ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display(
            "ÉCHEC de la commande: git pull origin ingredients. Prénenez l'équipe Écobalyse'"
        )
        reset_branch()
    else:
        display(
            "SUCCÈS. La liste d'ingrédients et procédés est à jour avec la branche ingredients"
        )

    shutil.copy(ACTIVITIES, ACTIVITIES_TEMP % w_institut.value)
    w_id.options = tuple(read_activities().keys())
    clear_form()
    display_all()


def clear_git_output(_):
    git_output.clear_output()


def clear_reset_output(_):
    reset_output.clear_output()


@git_output.capture()
def commit_activities(_):
    if not w_institut:
        display("Sélectionnez d'abord le bon contributeur")
        return
    shutil.copy(ACTIVITIES_TEMP % w_institut.value, ACTIVITIES)
    if subprocess.run(["git", "add", ACTIVITIES], capture_output=True).returncode != 0:
        display("ÉCHEC de la commande: git add")
        reset_branch()
    elif (
        subprocess.run(
            [
                "git",
                "commit",
                "-m",
                f"Changed ingredients (contributed by {w_institut.value}",
            ],
            capture_output=True,
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git commit")
        reset_branch()
    elif (
        subprocess.run(
            ["git", "pull", "origin", "ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git pull")
        reset_branch()
    elif (
        subprocess.run(
            ["git", "push", "origin", "ingredients"], capture_output=True
        ).returncode
        != 0
    ):
        display("ÉCHEC de la commande: git push")
        reset_branch()
    else:
        display(
            "SUCCÈS. Merci !! Vous pouvez prévenir l'équipe Écobalyse qu'il y a des nouveautés en attente de validation"
        )


w_search.observe(change_search_of(w_results), names="value")
savebutton.on_click(add_activity)
delbutton.on_click(delete_activity)
resetbutton.on_click(reset_activities)
clear_reset_button.on_click(clear_reset_output)
commitbutton.on_click(commit_activities)
clear_git_button.on_click(clear_git_output)


display(
    ipywidgets.HTML("<h1>Éditeur d'ingrédients</h1>"),
    w_institut,
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
                        """<h2>Documentation de cet outil</h2> <ul><li>Étape 1) Cliquez sur le
                        bouton « ▶▶ » dans la barre d'outils supérieure pour récupérer la dernière
                        version de cet éditeur d'ingrédients. Si l'éditeur ne se recharge pas,
                        patientez une ou deux minutes puis recommencez</li> <li>Étape 2) Dans le
                        sous-onglet « Liste », rechargez la liste des ingrédients déjà publiés en
                        cliquant sur le bouton vert « Réinitialiser ». Puis consultez la liste des
                        ingrédients déjà ajoutés avant d'ajouter un nouvel ingrédients</li>
                        <li>Étape 3) Ajouter un ingrédient :</li> Aller dans le sous-onglet
                        « Formulaire » pour renseigner les caractéristiques de l’ingrédient à
                        ajouter. <div style="padding-left: 50px">En utilisant l'explorateur depuis
                        un autre onglet, il faut d'abord identifier l'ICV correspondant à
                        l’ingrédient souhaité. Prenons l'exemple du sucre de canne. Par exemple
                        l’ICV « Brown sugar, production, at plant {FR} U » semble être le plus
                        adapté à l’ingrédient sucre de canne tel qu’il est utilisé en usine. Pour
                        vérifier qu’il est bien fabriqué à partir de canne à sucre, le sous-onglet
                        Technosphere de l'explorateur permet de vérifier les procédés qui entrent
                        dans la composition de « Brown sugar, production, at plant {FR} U ». Il
                        s’agit bien du procédé « Sugar, from sugarcane {RoW}| sugarcane processing,
                        traditional annexed plant | Cut-off, S - Copied from Écoinvent U {RoW}
                        ».</div> Après chaque ingrédient ajouté, cliquez sur « Enregistrer
                        localement ». Réitérez cette étape pour chaque ingrédient.<li>Etape 5) :
                        Validez tous les ingrédients ajoutés pour envoyer les ajouts à l’équipe
                        Écobalyse. Allez sur l’onglet « Publier », et cliquez sur le bouton une fois
                        l’ensemble des modifications faites et les ingrédients ajoutés.</li></ul>
                        """
                    ),
                )
            ),
            ipywidgets.VBox(
                (
                    ipywidgets.HBox((resetbutton, clear_reset_button)),
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
                    ipywidgets.HBox((savebutton, delbutton)),
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
                    ipywidgets.HTML(
                        "<hr/>Gardez la valeur par défaut 0 pour la valeur de bio-diversité :"
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
                                ),
                            ),
                        ],
                    ),
                    ipywidgets.Accordion(
                        titles=["Compléments hors ACV pour les ingredients"],
                        children=[
                            ipywidgets.VBox(
                                (
                                    ipywidgets.HTML(
                                        """Voir la <a style="color:blue"
                                        href="https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/complements-hors-acv">documentation</a>
                                        sur les compléments hors ACV"""
                                    ),
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
                                        """Les conditions d'élevage ne sont exportées que si
                                        l'ingrédient est dans la catégorie <i>animal_product</i> ou
                                        <i>dairy_product</i>."""
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
                )
            ),
            ipywidgets.VBox(
                (ipywidgets.HTML(f"<h2>Fichier JSON résultant:</h2>"), file_output)
            ),
            ipywidgets.VBox(
                [
                    ipywidgets.HTML(
                        """Si vous êtes satisfait(e) de vos modifications locales, vous devez
                        <b>publier</b> vos modifications, qui vont alors arriver dans la branche <a
                        style="color:blue"
                        href="https://github.com/MTES-MCT/ecobalyse/tree/ingredients">ingredients</a>
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
