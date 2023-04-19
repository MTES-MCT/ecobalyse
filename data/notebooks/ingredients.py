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


def save_ingredients(ingredients):
    with open(INGREDIENTS_TEMP, "w") as fp:
        fp.write(
            json.dumps(
                [from_flat(from_pretty(i)) for i in ingredients.values()],
                indent=2,
            )
        )
    w_id.options = tuple(read_ingredients().keys())


def to_flat(d):
    return dict(FlatDict(d, delimiter="."))


def from_flat(d):
    return FlatDict(d, delimiter=".").as_dict()


def reverse(d):
    """turn the values of a dict into keys and keys into values"""
    return {v: k for k, v in d.items()}


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


def to_pretty(d):
    """turn a dict with dotted keys to a dict with pretty keys"""
    return {FIELDS[k]: v for k, v in d.items() if FIELDS.get(k)}


def from_pretty(d):
    """turn a dict with pretty keys to a dict with dotted keys"""
    ingredient = {reverse(FIELDS)[k]: v for k, v in d.items()}
    # if not ingredient.get("variants"):
    #    ingredient["variants"] = {}
    return ingredient


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


# WIDGETS
## technical identifier of the ingredient (for API/URL)
layout = ipywidgets.Layout(width="500px")
style = {"description_width": "initial"}
w_id = ipywidgets.Combobox(
    placeholder="Identifier",
    description="Id",
    layout=layout,
    style=style,
    options=tuple(read_ingredients().keys()),
)
## Name of the ingredient (for users)
w_name = ipywidgets.Text(
    placeholder="Name",
    description="Name",
    layout=layout,
    style=style,
)
## brightway code of the ingredient process
w_default = ipywidgets.Text(
    placeholder="Default activity",
    description="Default Act.",
    layout=layout,
    style=style,
)
## default origin
w_default_origin = ipywidgets.Dropdown(
    description="Default origin",
    options=[
        ("Europe et Maghreb", "EuropeAndMaghreb"),
        ("Hors Europe et Maghreb", "OutOfEuropeAndMaghreb"),
        ("France", "France"),
        ("Par avion, hors Europe et Maghreb", "OutOfEuropeAndMaghrebByPlane"),
    ],
    layout=layout,
    style=style,
)
w_animal_origin = ipywidgets.Checkbox(description="Animal Origin", layout=layout)
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    description="Transp.Cooling",
    options=[
        ("Aucun", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
    layout=layout,
    style=style,
)
## Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.BoundedFloatText(
    description="Cooked/Raw",
    placeholder="Coef",
    min=0,
    step=0.05,
    layout=layout,
    style=style,
)
## density of the ingredient
w_density = ipywidgets.BoundedFloatText(
    description="Density",
    placeholder="Coef",
    min=0,
    step=0.05,
    layout=layout,
    style=style,
)
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox(description="Visible", layout=layout, style=style)

# fields for (hardcoded) variants
## code of the organic process if any
w_organic_process = ipywidgets.Text(
    description="Organic",
    placeholder="Process",
    layout=layout,
    style=style,
)
## Quantity of simple ingredient necessary to produce 1 unit of complex ingredient
## For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
w_organic_ratio = ipywidgets.BoundedFloatText(
    description="Complex Ratio",
    placeholder="Coef",
    min=0,
    step=0.05,
    layout=layout,
    style=style,
)
w_organic_simple_ingredient_default = ipywidgets.Text(
    description="Original",
    placeholder="Process Name",
    layout=layout,
    style=style,
)
w_organic_simple_ingredient_variant = ipywidgets.Text(
    description="Variant",
    placeholder="Process Name",
    tooltip="Click to add or update the ingredient",
    style=style,
    layout=layout,
)
# default coef for the beyond-lca indicators
w_organic_agrodiv = ipywidgets.FloatSlider(
    description="Agro-Diversity",
    placeholder="Coef",
    style=style,
    min=0,
    max=1,
    step=0.05,
    layout=layout,
)
w_organic_agroeco = ipywidgets.FloatSlider(
    description="Agro-Ecology",
    placeholder="Coef",
    min=0,
    max=1,
    step=0.05,
    style=style,
    layout=layout,
)
w_organic_animal_welfare = ipywidgets.FloatSlider(
    description="Animal Welfare",
    placeholder="Coef",
    min=0,
    max=1,
    step=0.05,
    style=style,
    layout=layout,
)
## code for BleuBlanCoeur process if any
w_bleu_blanc_coeur = ipywidgets.Text(
    description="BleuBlanCoeur",
    placeholder="Process",
    style=style,
    layout=layout,
)


# buttons
savebutton = ipywidgets.Button(
    description="Save",
    button_style="warning",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Add or update the ingredient",
    icon="check",
)
delbutton = ipywidgets.Button(
    description="Delete",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Delete the ingredient with the 'id' field above",
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
    tooltip="Reset the ingredients to the branch state",
    icon="sparkles",
)
commitbutton = ipywidgets.Button(
    description="Publish",
    button_style="danger",  # 'success', 'info', 'warning', 'danger' or ''
    tooltip="Commit the ingredients into the branch",
    icon="code-commit",
)
out = ipywidgets.Output()


def resetform():
    display(resetbutton)


def commitform():
    display(commitbutton)


def list_ingredients():
    ingredients = read_ingredients()
    display(Markdown(f"# List of {len(ingredients)} ingredients:"))
    display(pandas.DataFrame(ingredients.values(), columns=list(FIELDS.values())))


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
    clear_form()
    out.clear_output()
    list_ingredients()


@out.capture()
def del_ingredient(_):
    ingredients = read_ingredients()
    del ingredients[w_id.value]
    save_ingredients(ingredients)
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


def clear_form():
    w_id.value = ""
    w_name.value = ""
    w_default.value = ""
    w_default_origin.value = "EuropeAndMaghreb"
    w_animal_origin.value = False
    w_raw_to_cooked_ratio.value = 0
    w_density.value = 0
    w_cooling.value = "none"
    w_visible.value = True
    w_organic_process.value = ""
    w_organic_ratio.value = 0
    w_organic_simple_ingredient_default.value = ""
    w_organic_simple_ingredient_variant.value = ""
    w_organic_agrodiv.value = 0
    w_organic_agroeco.value = 0
    w_organic_animal_welfare.value = 0
    w_bleu_blanc_coeur.value = ""


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
    i = from_pretty(read_ingredients().get(change.new, {}))
    if not i:
        return
    set_field(w_name, i.get("name"), "")
    set_field(w_default, i.get("default"), "")
    set_field(
        w_default_origin,
        i.get("default_origin"),
        "EuropeAndMaghreb",
    )
    set_field(w_animal_origin, i.get("animal_origin"), False)
    set_field(w_raw_to_cooked_ratio, i.get("raw_to_cooked_ratio"), 0)
    set_field(w_density, i.get("density"), 0)
    set_field(w_cooling, i.get("transport_cooling"), "none")
    set_field(w_visible, i.get("visible"), True)
    set_field(w_organic_process, i.get("variants.organic.process"), "")
    set_field(w_organic_ratio, i.get("variants.organic.ratio"), 0)
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
    set_field(w_organic_agrodiv, i.get("variants.organic.beyondLCA.agro-diversity"), 0)
    set_field(w_organic_agroeco, i.get("variants.organic.beyondLCA.agro-ecology"), 0)
    set_field(
        w_organic_animal_welfare, i.get("variants.organic.beyondLCA.animal-welfare"), 0
    )
    set_field(w_bleu_blanc_coeur, i.get("variants.bleu_blanc_coeur"), "")


w_id.observe(change_id, names="value")
savebutton.on_click(add_ingredient)
delbutton.on_click(del_ingredient)
# getbutton.on_click(get_ingredient)
resetbutton.on_click(reset_ingredients)
commitbutton.on_click(commit_ingredients)


display(Markdown("# Get/Add/Modify an ingredient :"))
display(
    w_id,
    w_name,
    w_default,
    w_default_origin,
    w_animal_origin,
    w_raw_to_cooked_ratio,
    w_density,
    w_cooling,
    w_visible,
    w_organic_process,
    w_organic_ratio,
    w_organic_simple_ingredient_default,
    w_organic_simple_ingredient_variant,
    w_organic_agrodiv,
    w_organic_agroeco,
    w_organic_animal_welfare,
    w_bleu_blanc_coeur,
    ipywidgets.HBox((savebutton, delbutton)),
)

display(Markdown("# Reset ingredients :"))
display(Markdown("Reset the ingredients to the branch state"))
interact(resetform)
display(Markdown("# Publish ingredients :"))
display(Markdown("Publish the ingredients to the `ingredients` branch"))
interact(commitform)

out.observe(resetform, "load")

display(out)

with out:
    list_ingredients()
