from IPython.core.display import display, Markdown
from flatdict import FlatDict
from ipywidgets import interact
import ipywidgets
import json
import json
import os
import pandas
import shutil
import subprocess

os.chdir("/home/jovyan/ecobalyse/data")
INGREDIENTS_BASE = "/home/jovyan/ecobalyse/data/food/export_agb/ingredients_base.json"
INGREDIENTS_TEMP = "/home/jovyan/ingredients_base.json"
os.getcwd()


# fields
## technical identifier of the ingredient (for API/URL)
w_id = ipywidgets.Text(
    placeholder="Identifier",
    description="Id",
)
## Name of the ingredient (for users)
w_name = ipywidgets.Text(
    placeholder="Name", description="Name", layout=ipywidgets.Layout(width="200px")
)
## brightway code of the ingredient process
w_default = ipywidgets.Text(placeholder="Default activity", description="Default Act.")
## default origin
w_default_origin = ipywidgets.Dropdown(
    options=[
        ("Europe et Maghreb", "EuropeAndMaghreb"),
        ("Hors Europe et Maghreb", "OutOfEuropeAndMaghreb"),
        ("France", "France"),
        ("Par avion, hors Europe et Maghreb", "OutOfEuropeAndMaghrebByPlane"),
    ]
)
w_animal_origin = ipywidgets.Checkbox(description="Animal Origin")
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    description="Transp.Cool.",
    options=[
        ("Aucun", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
)
## density of the ingredient
w_density = ipywidgets.Text(description="Density", placeholder="Float")
## Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.Text(description="Cooked/Raw", placeholder="Float")
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox(description="Visible")

# fields for (hardcoded) variants
## code of the organic process if any
w_organic_process = ipywidgets.Text(description="Organic", placeholder="Process")
## Quantity of simple ingredient necessary to produce 1 unit of complex ingredient
## For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
w_organic_ratio = ipywidgets.Text(description="Cplx Ratio", placeholder="Float")
w_organic_simple_ingredient_default = ipywidgets.Text(
    description="Original", placeholder="Process Name"
)
w_organic_simple_ingredient_variant = ipywidgets.Text(
    description="Variant",
    placeholder="Process Name",
    tooltip="Click to add or update the ingredient",
)
# default coef for the beyond-lca indicators
w_organic_agrodiv = ipywidgets.Text(description="Agro-Div.", placeholder="Float")
w_organic_agroeco = ipywidgets.Text(description="Agro-Eco.", placeholder="Float")
w_organic_animal_welfare = ipywidgets.Text(
    description="Anim.Welf.", placeholder="Float"
)
## code for BleuBlanCoeur process if any
w_bleu_blanc_coeur = ipywidgets.Text(description="BleuBlanCoeur", placeholder="Process")


# buttons
addbutton = ipywidgets.Button(
    description="Save",
    button_style="warning",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Add or update the ingredient",
    icon="check",
)
delbutton = ipywidgets.Button(
    description="Delete",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Delete the ingredient",
    icon="trash",
)
getbutton = ipywidgets.Button(
    description="Get",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Fill the form from the id field",
    icon="down-to-bracket",
)
resetbutton = ipywidgets.Button(
    description="Reset from branch",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Reset the ingredients to the branch state",
    icon="sparkles",
)
clearbutton = ipywidgets.Button(
    description="Clear the form",
    button_style="success",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Clear the form",
    icon="broom-wide",
)
commitbutton = ipywidgets.Button(
    description="Publish",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Commit the ingredients into the branch",
    icon="code-commit",
)
out = ipywidgets.Output()
FIELDS = {
    "id": "id",
    "name": "Name",
    "default": "Process Code",
    "default_origin": "Default Origin",
    "animal_origin": "Animal Origin",
    "raw_to_cooked_ratio": "Cooked/Raw Ratio",
    "density": "Density",
    "transport_cooling": "Transport Cooling",
    "visible": "Visible",
    "variants.organic.process": "Organic Process Code",
    "variants.organic.ratio": "Complex/Simple Ratio",
    "variants.organic.simple_ingredient_default": "Original Ingredient Name",
    "variants.organic.simple_ingredient_variant": "Variant Ingredient Name",
    "variants.organic.beyondLCA.agro-diversity": "Agro Div.",
    "variants.organic.beyondLCA.agro-ecology": "Agro Eco",
    "variants.organic.beyondLCA.animal-welfare": "Animal Welf",
    "variants.bleu_blanc_coeur": "BleuBlancCoeur Process Code",
}


def save_ingredients(ingredients):
    with open(INGREDIENTS_TEMP, "w") as fp:
        fp.write(
            json.dumps(
                [from_flat(from_pretty(i)) for i in ingredients.values()],
                indent=2,
            )
        )


def reverse(d):
    """turn the values of a dict into keys and keys into values"""
    return {v: k for k, v in d.items()}


def to_pretty(d):
    """turn a dict with dotted keys to a dict with pretty keys"""
    return {FIELDS[k]: v for k, v in d.items() if FIELDS.get(k)}


def from_pretty(d):
    """turn a dict with pretty keys to a dict with dotted keys"""
    ingredient = {reverse(FIELDS)[k]: v for k, v in d.items()}
    # if not ingredient.get("variants"):
    #    ingredient["variants"] = {}
    return ingredient


def addform(
    id_=w_id,
    name=w_name,
    default=w_default,
    default_origin=w_default_origin,
    animal_origin=w_animal_origin,
    raw_to_cooked_ratio=w_raw_to_cooked_ratio,
    density=w_density,
    transport_cooling=w_cooling,
    visible=w_visible,
    organic=w_organic_process,
    organic_ratio=w_organic_ratio,
    organic_simple_ingredient_default=w_organic_simple_ingredient_default,
    w_organic_simple_ingredient_variant=w_organic_simple_ingredient_variant,
    agrodiv=w_organic_agrodiv,
    agroeco=w_organic_agroeco,
    animalwel=w_organic_animal_welfare,
    bbc=w_bleu_blanc_coeur,
):
    display(getbutton)
    display(delbutton)
    display(addbutton)
    display(clearbutton)


def resetform():
    display(resetbutton)


def commitform():
    display(commitbutton)


def clearform():
    display(clearbutton)


def list_ingredients():
    ingredients = read_ingredients()
    display(Markdown(f"# List of {len(ingredients)} ingredients:"))
    display(pandas.DataFrame(ingredients.values(), columns=FIELDS.values()))


def to_float(s):
    try:
        return float(s)
    except:
        return ""


@out.capture()
def add_ingredient(_):
    ingredient = {
        "id": w_id.value,
        "name": w_name.value,
        "default": w_default.value,
        "default_origin": w_default_origin.value,
        "animal_origin": w_animal_origin.value,
        "raw_to_cooked_ratio": to_float(w_raw_to_cooked_ratio.value),
        "density": to_float(w_density.value),
        "transport_cooling": w_cooling.value,
        "visible": w_visible.value,
        "variants.organic.process": w_organic_process.value,
        "variants.organic.ratio": to_float(w_organic_ratio.value),
        "variants.organic.simple_ingredient_default": w_organic_simple_ingredient_default.value,
        "variants.organic.simple_ingredient_variant": w_organic_simple_ingredient_variant.value,
        "variants.organic.beyondLCA.agro-diversity": to_float(w_organic_agrodiv.value),
        "variants.organic.beyondLCA.agro-ecology": to_float(w_organic_agroeco.value),
        "variants.organic.beyondLCA.animal-welfare": to_float(
            w_organic_animal_welfare.value
        ),
        "variants.bleu_blanc_coeur": w_bleu_blanc_coeur.value,
    }
    ingredient = {k: v for k, v in ingredient.items() if v != ""}
    ingredients = read_ingredients()
    ingredients.update({ingredient["id"]: to_pretty(ingredient)})
    save_ingredients(ingredients)
    clear_form(None)
    out.clear_output()
    list_ingredients()


@out.capture()
def commit_ingredients(_):
    shutil.copy(INGREDIENTS_TEMP, INGREDIENTS_BASE)
    subprocess.run(f"git add {INGREDIENTS_BASE}")
    subprocess.run("git commit -m 'new ingredients'")
    subprocess.run("git push origin ingredients'")
    out.clear_output()
    list_ingredients()


@out.capture()
def reset_ingredients(_):
    subprocess.run("git reset --hard")
    shutil.copy(INGREDIENTS_BASE, INGREDIENTS_TEMP)
    out.clear_output()
    list_ingredients()


def clear_form(_):
    w_id.value = ""
    w_name.value = ""
    w_default.value = ""
    w_default_origin.value = "EuropeAndMaghreb"
    w_animal_origin.value = False
    w_raw_to_cooked_ratio.value = ""
    w_density.value = ""
    w_cooling.value = "none"
    w_visible.value = True
    w_organic_process.value = ""
    w_organic_ratio.value = ""
    w_organic_simple_ingredient_default.value = ""
    w_organic_simple_ingredient_variant.value = ""
    w_organic_agrodiv.value = ""
    w_organic_agroeco.value = ""
    w_organic_animal_welfare.value = ""
    w_bleu_blanc_coeur.value = ""


def set_field(field, value, default):
    """the field is supposed to be empty.
    We store the default value but set field.empty=True
    """
    if type(value) is not bool:
        value = str(value)
    if value is None:
        field.empty = True
        field.value = default
    else:
        field.empty = False
        field.value = value
    return field


def get_ingredient(_):
    i = from_pretty(read_ingredients()[w_id.value])
    set_field(w_name, i.get("name"), "")
    set_field(w_default, i.get("default"), "")
    set_field(w_default_origin, i.get("default_origin"), "EuropeAndMaghreb")
    set_field(w_animal_origin, i.get("animal_origin"), False)
    set_field(w_raw_to_cooked_ratio, i.get("raw_to_cooked_ratio"), "")
    set_field(w_density, i.get("density"), "")
    set_field(w_cooling, i.get("transport_cooling"), "none")
    set_field(w_visible, i.get("visible"), True)
    set_field(w_organic_process, i.get("variants.organic.process"), "")
    set_field(w_organic_ratio, i.get("variants.organic.ratio"), "")
    set_field(
        w_organic_simple_ingredient_default,
        i.get("variants.organic.simple_ingredient_default"),
        "",
    )
    set_field(
        w_organic_simple_ingredient_variant,
        i.get("variants.organic.simple_ingredient_variant"),
        "",
    )
    set_field(w_organic_agrodiv, i.get("variants.organic.beyondLCA.agro-diversity"), "")
    set_field(w_organic_agroeco, i.get("variants.organic.beyondLCA.agro-ecology"), "")
    set_field(
        w_organic_animal_welfare, i.get("variants.organic.beyondLCA.animal-welfare"), ""
    )
    set_field(w_bleu_blanc_coeur, i.get("variants.bleu_blanc_coeur"), "")


def read_ingredients():
    """Return the ingredients as a dict indexed with id"""
    if not os.path.exists(INGREDIENTS_TEMP):
        shutil.copy(INGREDIENTS_BASE, INGREDIENTS_TEMP)
    try:
        with open(INGREDIENTS_TEMP) as fp:
            return {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}
    except json.JSONDecodeError:
        shutil.copy(INGREDIENTS_BASE, INGREDIENTS_TEMP)
        with open(INGREDIENTS_TEMP) as fp:
            return {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}


# def to_flat(ingredient):
#    [flat_dict] = pandas.json_normalize(ingredient).to_dict(orient="records")
#    return flat_dict


def to_flat(d):
    return dict(FlatDict(d, delimiter="."))


def from_flat(d):
    return FlatDict(d, delimiter=".").as_dict()


@out.capture()
def del_ingredient(_):
    ingredients = read_ingredients()
    del ingredients[w_id.value]
    save_ingredients(ingredients)
    out.clear_output()
    list_ingredients()


addbutton.on_click(add_ingredient)
delbutton.on_click(del_ingredient)
getbutton.on_click(get_ingredient)
resetbutton.on_click(reset_ingredients)
clearbutton.on_click(clear_form)
commitbutton.on_click(commit_ingredients)


display(Markdown("# Get/Add/Modify an ingredient :"))
interact(addform)

display(Markdown("# Reset ingredients :"))
display(Markdown("Reset the ingredients to the branch state"))
interact(resetform)
interact(commitform)

out.observe(addform, "add")
out.observe(resetform, "load")

display(out)

with out:
    list_ingredients()
