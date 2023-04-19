from IPython.core.display import display, Markdown
from flatdict import FlatDict
import bw2data
import ipywidgets
import json
import json
import os
import pandas
import pprint
import shutil
import subprocess


os.chdir("/home/jovyan/ecobalyse/data")
PROJECT = "Ecobalyse"
INGREDIENTS_BASE = "/home/jovyan/ecobalyse/data/food/export_agb/ingredients_base.json"
INGREDIENTS_TEMP = "/home/jovyan/ingredients_base.json"
os.getcwd()

bw2data.projects.set_current(PROJECT)
DATABASE = bw2data.Database("Agribalyse 3.0")


def save_ingredients(ingredients):
    with open(INGREDIENTS_TEMP, "w") as fp:
        fp.write(
            json.dumps(
                [from_flat(from_pretty(i)) for i in ingredients.values()],
                indent=2,
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
    "name": "Name",
    "default": "Process",
    "default_origin": "Default Origin",
    "animal_origin": "Animal Origin",
    "raw_to_cooked_ratio": "Cooked/Raw Ratio",
    "density": "Density",
    "transport_cooling": "Transport Cooling",
    "visible": "Visible",
    "variants.organic.process": "Organic Process Code",
    "variants.organic.ratio": "Complex/Simple Ratio",
    "variants.organic.simple_ingredient_default": "Default component process",
    "variants.organic.simple_ingredient_variant": "Organic component process",
    "variants.organic.beyondLCA.agro-diversity": "Agro Diversity",
    "variants.organic.beyondLCA.agro-ecology": "Agro Ecology",
    "variants.organic.beyondLCA.animal-welfare": "Animal Welfare",
    "variants.bleu_blanc_coeur": "BleuBlancCoeur Process",
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
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}
    except json.JSONDecodeError:
        shutil.copy(INGREDIENTS_BASE, INGREDIENTS_TEMP)
        with open(INGREDIENTS_TEMP) as fp:
            igs = {i["id"]: i for i in [to_pretty(to_flat(i)) for i in json.load(fp)]}

    return igs


# WIDGETS
## technical identifier of the ingredient (for API/URL)
layoutL = ipywidgets.Layout(width="215px", display="flex", justify_content="flex-end")
layoutH = ipywidgets.Layout(width="860px")
layoutA = ipywidgets.Layout(width="900px")
layoutW = ipywidgets.Layout(width="645px")
style = {"description_width": "initial"}
w_id = ipywidgets.Combobox(
    placeholder="Identifier",
    layout=layoutW,
    style=style,
    options=tuple([""] + list(read_ingredients().keys())),
)
## Name of the ingredient (for users)
w_name = ipywidgets.Text(
    placeholder="Name",
    layout=layoutW,
    style=style,
)
## brightway code of the ingredient process
w_search = ipywidgets.Text(placeholder="tomat* FR farm", layout=layoutL, style=style)
w_default = ipywidgets.Select(
    placeholder="Default process",
    rows=1,
    options=[""],
    layout=layoutW,
    style=style,
)
## default origin
w_default_origin = ipywidgets.Dropdown(
    options=[
        ("Europe et Maghreb", "EuropeAndMaghreb"),
        ("Hors Europe et Maghreb", "OutOfEuropeAndMaghreb"),
        ("France", "France"),
        ("Par avion, hors Europe et Maghreb", "OutOfEuropeAndMaghrebByPlane"),
    ],
    layout=layoutW,
    style=style,
)
w_animal_origin = ipywidgets.Checkbox(indent=False, layout=layoutW)
## Transport cooling
w_cooling = ipywidgets.Dropdown(
    options=[
        ("Aucun", "none"),
        ("Toujours", "always"),
        ("Une fois transformé", "once_transformed"),
    ],
    layout=layoutW,
    style=style,
)
## Cooked/Raw ratio
w_raw_to_cooked_ratio = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    value=1,
    min=0,
    step=0.05,
    layout=layoutW,
    style=style,
)
## density of the ingredient
w_density = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    value=1,
    min=0,
    step=0.05,
    layout=layoutW,
    style=style,
)
## Enable/disable the ingredient
w_visible = ipywidgets.Checkbox(indent=False, layout=layoutW, style=style, value=True)

# fields for (hardcoded) variants
## code of the organic process if any
w_organic_search = ipywidgets.Text(
    placeholder="tomat* organic", layout=layoutL, style=style
)
w_organic_process = ipywidgets.Select(
    placeholder="Process",
    layout=layoutW,
    options=[""],
    rows=1,
    style=style,
)
## Quantity of simple ingredient necessary to produce 1 unit of complex ingredient
## For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
w_organic_ratio = ipywidgets.BoundedFloatText(
    placeholder="Coef",
    min=0,
    step=0.05,
    layout=layoutW,
    style=style,
)
w_organic_default_search = ipywidgets.Text(
    placeholder="flour conventio*", layout=layoutL, style=style
)
w_organic_simple_ingredient_default = ipywidgets.Select(
    placeholder="Process",
    layout=layoutW,
    options=[""],
    rows=1,
    style=style,
)
w_organic_variant_search = ipywidgets.Text(
    placeholder="flour organic", layout=layoutL, style=style
)
w_organic_simple_ingredient_variant = ipywidgets.Select(
    placeholder="Process",
    tooltip="Click to add or update the ingredient",
    style=style,
    options=[""],
    rows=1,
    layout=layoutW,
)
# default coef for the beyond-lca indicators
w_organic_agrodiv = ipywidgets.FloatSlider(
    placeholder="Agro-diversity coefficient",
    style=style,
    min=0,
    max=1,
    step=0.05,
    layout=layoutW,
)
w_organic_agroeco = ipywidgets.FloatSlider(
    placeholder="Agro-ecology coefficient",
    min=0,
    max=1,
    step=0.05,
    style=style,
    layout=layoutW,
)
w_organic_animal_welfare = ipywidgets.FloatSlider(
    placeholder="Animal Welfare coefficient",
    min=0,
    max=1,
    step=0.05,
    style=style,
    layout=layoutW,
)
## code for BleuBlanCoeur process if any
w_bleu_blanc_coeur_search = ipywidgets.Text(
    placeholder="bleu blanc", layout=layoutL, style=style
)
w_bleu_blanc_coeur = ipywidgets.Select(
    placeholder="Process",
    style=style,
    options=[""],
    rows=1,
    layout=layoutW,
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


def list_ingredients():
    ingredients = read_ingredients()
    display(Markdown(f"# List of {len(ingredients)} ingredients:"))
    display(pandas.DataFrame(ingredients.values(), columns=list(FIELDS.values())))


@out.capture()
def add_ingredient(_):
    ingredient = {
        "id": w_id.value,
        "name": w_name.value,
        "default": w_default.value,
        "default_origin": w_default_origin.value,
        "animal_origin": w_animal_origin.value,
        "raw_to_cooked_ratio": w_raw_to_cooked_ratio.value,
        "density": w_density.value,
        "transport_cooling": w_cooling.value,
        "visible": w_visible.value,
        "variants.organic.process": w_organic_process.value,
        "variants.organic.ratio": w_organic_ratio.value,
        "variants.organic.simple_ingredient_default": w_organic_simple_ingredient_default.value,
        "variants.organic.simple_ingredient_variant": w_organic_simple_ingredient_variant.value,
        "variants.organic.beyondLCA.agro-diversity": w_organic_agrodiv.value,
        "variants.organic.beyondLCA.agro-ecology": w_organic_agroeco.value,
        "variants.organic.beyondLCA.animal-welfare": w_organic_animal_welfare.value,
        "variants.bleu_blanc_coeur": w_bleu_blanc_coeur.value,
    }
    ingredient = {k: v for k, v in ingredient.items() if v != ""}
    ingredients = read_ingredients()
    ingredients.update({ingredient["id"]: to_pretty(ingredient)})
    save_ingredients(ingredients)
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
    shutil.copy(INGREDIENTS_BASE, INGREDIENTS_TEMP)
    out.clear_output()
    list_ingredients()
    w_id.options = tuple(read_ingredients().keys())


def clear_form():
    w_id.options = tuple([""] + list(read_ingredients().keys()))
    w_id.value = ""
    w_name.value = ""
    w_search.value = ""
    w_default.options = [""]
    w_default.value = ""
    w_default_origin.value = "EuropeAndMaghreb"
    w_animal_origin.value = False
    w_raw_to_cooked_ratio.value = 0
    w_density.value = 0
    w_cooling.value = "none"
    w_visible.value = True
    w_organic_search.value = ""
    w_organic_process.options = [""]
    w_organic_process.value = ""
    w_organic_ratio.value = 0
    w_organic_default_search.value = ""
    w_organic_simple_ingredient_default.options = [""]
    w_organic_simple_ingredient_default.value = ""
    w_organic_variant_search.value = ""
    w_organic_simple_ingredient_variant.options = [""]
    w_organic_simple_ingredient_variant.value = ""
    w_organic_agrodiv.value = 0
    w_organic_agroeco.value = 0
    w_organic_animal_welfare.value = 0
    w_bleu_blanc_coeur_search.value = ""
    w_bleu_blanc_coeur.options = [""]
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
    code = i.get("default")
    act = DATABASE.get(code)
    w_default.options = [(act["name"], code)]
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


def change_search_of(field):
    def change_search(change):
        results = list(DATABASE.search(change.new, limit=50))
        field.rows = len(results)
        field.options = tuple([(repr(r), r["code"]) for r in results])

    return change_search


w_id.observe(change_id, names="value")
w_search.observe(change_search_of(w_default), names="value")
w_organic_search.observe(change_search_of(w_organic_process), names="value")
w_organic_default_search.observe(
    change_search_of(w_organic_simple_ingredient_default), names="value"
)
w_organic_variant_search.observe(
    change_search_of(w_organic_simple_ingredient_variant), names="value"
)
w_bleu_blanc_coeur_search.observe(change_search_of(w_bleu_blanc_coeur), names="value")
savebutton.on_click(add_ingredient)
delbutton.on_click(del_ingredient)
resetbutton.on_click(reset_ingredients)
commitbutton.on_click(commit_ingredients)


display(
    Markdown("# Get/Add/Modify an ingredient :"),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["id"], layout=layoutL),
            w_id,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["name"], layout=layoutL),
            w_name,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label("Search process in " + DATABASE.name, layout=layoutL),
            w_search,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["default"], layout=layoutL),
            w_default,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["animal_origin"], layout=layoutL),
            w_animal_origin,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["default_origin"], layout=layoutL),
            w_default_origin,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["raw_to_cooked_ratio"], layout=layoutL),
            w_raw_to_cooked_ratio,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["density"], layout=layoutL),
            w_density,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (
            ipywidgets.Label(FIELDS["transport_cooling"], layout=layoutL),
            w_cooling,
        ),
        layout=layoutH,
    ),
    ipywidgets.HBox(
        (ipywidgets.Label(FIELDS["visible"], layout=layoutL), w_visible),
        layout=layoutH,
    ),
    ipywidgets.Accordion(
        children=[
            ipywidgets.VBox(
                (
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label("Search organic process", layout=layoutL),
                            w_organic_search,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.process"],
                                layout=layoutL,
                            ),
                            w_organic_process,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.ratio"], layout=layoutL
                            ),
                            w_organic_ratio,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                "Search default component", layout=layoutL
                            ),
                            w_organic_default_search,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.simple_ingredient_default"],
                                layout=layoutL,
                            ),
                            w_organic_simple_ingredient_default,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                "Search organic component", layout=layoutL
                            ),
                            w_organic_variant_search,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.simple_ingredient_variant"],
                                layout=layoutL,
                            ),
                            w_organic_simple_ingredient_variant,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.beyondLCA.agro-diversity"],
                                layout=layoutL,
                            ),
                            w_organic_agrodiv,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.beyondLCA.agro-ecology"],
                                layout=layoutL,
                            ),
                            w_organic_agroeco,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.organic.beyondLCA.animal-welfare"],
                                layout=layoutL,
                            ),
                            w_organic_animal_welfare,
                        ),
                        layout=layoutH,
                    ),
                )
            ),
            ipywidgets.VBox(
                (
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                "Search bleu blanc coeur process", layout=layoutL
                            ),
                            w_bleu_blanc_coeur_search,
                        ),
                        layout=layoutH,
                    ),
                    ipywidgets.HBox(
                        (
                            ipywidgets.Label(
                                FIELDS["variants.bleu_blanc_coeur"], layout=layoutL
                            ),
                            w_bleu_blanc_coeur,
                        ),
                        layout=layoutH,
                    ),
                )
            ),
        ],
        titles=["Organic", "Bleu Blanc Coeur"],
        layout=layoutA,
    ),
    ipywidgets.HBox((savebutton, delbutton)),
    Markdown("# Reset or Publish ingredients :"),
    Markdown(
        "Reset the ingredients to the branch state, or Publish to the `ingredients` branch"
    ),
    ipywidgets.HBox((resetbutton, commitbutton)),
    out,
)


with out:
    list_ingredients()
    with open(INGREDIENTS_TEMP) as fp:
        display(pprint.pprint(json.load(fp)))
