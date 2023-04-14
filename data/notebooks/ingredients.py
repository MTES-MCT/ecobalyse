from IPython.core.display import display, Markdown
from ipywidgets import interact
import bw2data
import bw2io
import ipywidgets
import json
import json
import os
import pandas as pd

bw2data.projects.set_current("Ecobalyse")
bw2io.bw2setup()
os.chdir("/home/jovyan/ecobalyse/data")
INGREDIENTS_BASE = "/home/jovyan/ecobalyse/data/food/export_agb/ingredients_base.json"

DBNAME = "Ingredients"
database = bw2data.Database(DBNAME)
if DBNAME in bw2data.databases:
    print(f"Database {DBNAME} already exists")
else:
    print(f"Registering new database {DBNAME}")
    database.register()

os.getcwd()

## example
# farine = {
#    "id": "flour",  # human made identifier for API / URL
#    "name": "Farine",  # human made name for the UI
#    "default": "a343353e431d7dddc7bb25cbc41e179a",  # activity simapro identifier
#    "default_origin": "EuropeAndMaghreb",  # enum for the default origin (human choice)
#    "raw_to_cooked_ratio": 1,  # from Agribalyse ?
#    "density": 1,
#    "transport_cooling": "once_transformed",
#    "visible": True,
#    "variants": {
#        "organic": {
#            "beyondLCA": {"agro-diversity": 0.5, "agro-ecology": 0.5},
#            "ratio": 1.16,
#            "simple_ingredient_default": "Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate",
#            "simple_ingredient_variant": "Soft wheat grain, organic, 15% moisture, Central Region, at farm gate",
#        }
#    },
# }


# fields
## technical identifier of the ingredient (for API/URL)
w_id = ipywidgets.Text(
    placeholder="Identifier",
    description="Id",
)
## Name of the ingredient (for users)
w_name = ipywidgets.Text(
    placeholder="Name",
    description="Name",
)
## brightway code of the ingredient process
w_default = ipywidgets.Text(placeholder="Default activity", description="Default Act.")
## default origin
w_origin = ipywidgets.Dropdown(
    options=[
        ("Europe et Maghreb", "EuropeAndMaghreb"),
        ("Hors Europe et Maghreb", "OutOfEuropeAndMaghreb"),
        ("France", "France"),
        ("Par avion, hors Europe et Maghreb", "OutOfEuropeAndMaghrebByPlane"),
    ]
)
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    description="Transport cooling",
    options=[
        ("Aucun", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
)
## density of the ingredient
w_density = ipywidgets.BoundedFloatText(description="Density", min=0.0, max=1.0)
## Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.BoundedFloatText(
    description="Cooked/Raw", min=0.0, max=1.0
)
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox()

# fields for (hardcoded) variants
## code of the organic process if any
w_organic = ipywidgets.Text(description="Organic", placeholder="Process")
## Quantity of simple ingredient necessary to produce 1 unit of complex ingredient
## For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
w_organic_ratio = ipywidgets.BoundedFloatText(description="Cooked/Raw", min=0.0)
w_organic_simple_ingredient_default = ipywidgets.Text(
    description="Original component", placeholder="Process Name"
)
w_organic_simple_ingredient_variant = ipywidgets.Text(
    description="Variant component", placeholder="Process Name"
)
# default coef for the beyond-lca indicators
w_organic_agrodiv = ipywidgets.BoundedFloatText(
    description="Agro-Diversity", min=0, max=1
)
w_organic_agroeco = ipywidgets.BoundedFloatText(
    description="Agro-Ecology", min=0, max=1
)
w_organic_animalwel = ipywidgets.BoundedFloatText(
    description="Animal Welfare", min=0, max=1
)
## code for BleuBlanCoeur process if any
w_bbc = ipywidgets.Text(description="BleuBlanCoeur", placeholder="Process")

# w_variants = ipywidgets.Accordion(
#    children=[
#        ipywidgets.VBox(children=[
#            w_organic,
#            w_organic_agrodiv,
#            w_organic_agroeco,
#            w_organic_animalwel
#        ]),
#        ipywidgets.VBox(children=[
#            w_bbc
#            ])],
#    titles=('Organic','Bleu Blanc Coeur')
# )


# buttons
addbutton = ipywidgets.Button(
    description="Add/update",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Click to add or update the ingredient",
    icon="check",
)
delbutton = ipywidgets.Button(
    description="Delete",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Click to delete the ingredient",
    icon="check",
)
getbutton = ipywidgets.Button(
    description="Get",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Click to get the ingredient",
    icon="check",
)
loadbutton = ipywidgets.Button(
    description="Load from json",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Click to load the ingredient from the JSON file",
    icon="check",
)
out = ipywidgets.Output()
KEYS = [
    "id",
    "name",
    "default",
    "default_origin",
    "raw_to_cooked_ratio",
    "density",
    "transport_cooling",
    "visible",
    "organic",
    "agro-diversity",
    "agro-ecology",
    "animal-welfare",
    "bleu_blanc_coeur",
]


def addform(
    id_=w_id,
    name=w_name,
    default=w_default,
    default_origin=w_origin,
    raw_to_cooked_ratio=w_raw_to_cooked_ratio,
    density=w_density,
    transport_cooling=w_cooling,
    visible=w_visible,
    organic=w_organic,
    organic_ratio=w_organic_ratio,
    organic_simple_ingredient_default=w_organic_simple_ingredient_default,
    w_organic_simple_ingredient_variant=w_organic_simple_ingredient_variant,
    agrodiv=w_organic_agrodiv,
    agroeco=w_organic_agroeco,
    animalwel=w_organic_animalwel,
    bbc=w_bbc,
):
    display(addbutton)


def getform(id_=w_id):
    display(getbutton)
    display(delbutton)


@out.capture()
def loadform():
    display(loadbutton)


@out.capture()
def add_ingredient(addbutton):
    ingredient = {
        "id": w_id.value,
        "name": w_name.value,
        "default": w_default.value,
        "default_origin": w_origin.value,
        "raw_to_cooked_ratio": w_raw_to_cooked_ratio.value,
        "density": w_density.value,
        "transport_cooling": w_cooling.value,
        "visible": w_visible.value,
    }
    if w_organic.value or w_bbc:
        ingredient["variants"] = {}
    if w_organic.value:
        ingredient["variants"]["organic"] = {
            "ratio": w_organic_ratio.value,
            "w_organic_simple_ingredient_default": w_organic_simple_ingredient_default.value,
            "w_organic_simple_ingredient_variant": w_organic_simple_ingredient_variant.value,
            "process": w_organic.value,
            "agro-diversity": w_organic_agrodiv.value,
            "agro-ecology": w_organic_agroeco.value,
            "animal-welfare": w_organic_animalwel.value,
        }
    if w_bbc.value:
        ingredient["variants"]["bleu_blanc_coeur"] = w_bbc.value

    if (DBNAME, ingredient["name"]) in database:
        existing = database.get(ingredient["name"])
        for k in KEYS:
            existing[k] = ingredient[k]
        existing.save()
    else:
        id_ = ingredient["id"]
        ingredient["database"] = DBNAME
        database.new_activity(id_, **ingredient).save()
    out.clear_output()
    list_ingredients()


def load_ingredients(loadbutton):
    with open(INGREDIENTS_BASE) as fp:
        database.write({(DBNAME, i["id"]): i for i in json.load(fp)})


def get_ingredient(getbutton):
    i = database.get(w_id.value)
    w_id.value = i["id"]
    w_name.value = i["name"]
    w_default.value = i["default"]
    w_origin.value = i["default_origin"]
    w_raw_to_cooked_ratio.value = i["raw_to_cooked_ratio"]
    w_density.value = i["density"]
    w_cooling.value = i["transport_cooling"]
    w_visible.value = i["visible"]
    w_organic.value = i["variants"]["organic"]["process"]
    w_organic_ratio.value = i["variants"]["organic"]["ratio"]
    w_organic_simple_ingredient_default.value = i["variants"]["organic"][
        "simple_ingredient_default"
    ]
    w_organic_simple_ingredient_variant.value = i["variants"]["organic"][
        "simple_ingredient_variant"
    ]
    w_organic_agrodiv.value = i["variants"]["organic"]["agro-diversity"]
    w_organic_agroeco.value = i["variants"]["organic"]["agro-ecology"]
    w_organic_animalwel.value = i["variants"]["organic"]["animal-welfare"]
    w_bbc.value = i["variants"]["bleu_blanc_coeur"]


@out.capture()
def del_ingredient(getbutton):
    if (DBNAME, w_id.value) in database:
        database.get(w_id.value).delete()
    out.clear_output()
    list_ingredients()


addbutton.on_click(add_ingredient)
delbutton.on_click(del_ingredient)
getbutton.on_click(get_ingredient)
loadbutton.on_click(load_ingredients)


def list_ingredients():
    data = bw2data.Database(DBNAME).load().values()
    ingredients = [{k: i.get(k) for k in KEYS} for i in data]
    idf = pd.DataFrame(ingredients)
    display(Markdown(f"# List of {len(ingredients)} ingredients:"))
    display(idf)


display(Markdown("# Get/delete an ingredient :"))
interact(getform)
display(Markdown("# Add/modify an ingredient :"))
interact(addform)

display(Markdown("# Load ingredients from JSON :"))
interact(loadform)

out.observe(addform, "add")
out.observe(getform, "get")
out.observe(loadform, "load")

display(out)

with out:
    list_ingredients()
