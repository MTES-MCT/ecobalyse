"""Decompose a transformed food product into its agricultural raw materials, electricity,
heat, water and waste, by walking the Agribalyse supply chain in Brightway.

The walk starts from a product activity and follows the technosphere inputs of every
activity classed as a food transformation step. It stops on the activities classed as
raw material (farm gate, primary production, catalog ingredient), energy, water, waste
or transport and accumulates their quantity per kg of product. Quantities are divided by
the production amount of each activity, which already carries the SimaPro allocation
(bw2io inflates the production amount of a co-product by its allocation share at import).

No impact is computed. The graph is abstracted behind `Graph` so that the traversal and
the classification can be tested on an in-memory graph without Brightway.
"""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from bw2data.backends.proxies import Activity

FOOD_SCOPES = {"food", "food2"}
MAX_DEPTH = 12
FARM_GATE_PATHS = (
    ("Agricultural", "Plant production"),
    ("Agricultural", "Animal production"),
)
# ", at farm gate {FR} U", ", at orchard {FR} U", ", at farm {US} - Adapted from WFLDB U",
# but not "Emissions from pesticides, mix for fruit tree, at farm S {GLO}"
FARM_GATE_NAME = re.compile(
    r", at (?:farm(?: gate)?|orchard|landing|vineyard)\b(?! S\b)"
)
# ecoinvent activities of primary production: "Olive {ES}| olive production | Cut-off, U",
# "Cattle for slaughtering, live weight {RoW}| beef cattle production on pasture | ..."
# but not "Activated bentonite {DE}| production |", whose activity part is bare
ECOINVENT_PRODUCTION_NAME = re.compile(r"\}\| [^|]*\w\s+production\b")
# Under "Agricultural", every sub-folder is a transformation step except the farm gate
# itself and the buildings and machinery folder. Animal feed and field operations are
# recursed: they only appear on the transformation side as feed-grade grain mixes (soybean
# oil) or as unit operations filed there (drying of egg powder).
NOT_TRANSFORM_AGRICULTURAL = {
    "Plant production",
    "Animal production",
    "Transformation",
}
# Agribalyse processes outside the "Agricultural" folder that still carry their own
# exchanges: retired processes, and the WFLDB or ecoinvent processes Agribalyse adapted.
OTHER_TRANSFORM_ROOTS = {"Autres"}
ADAPTED_PREFIX = "Adapted from"
FOOD_PATH = ("Agricultural", "Food")
CONSUMPTION_MIX_PATH = ("Agricultural", "Food", "Consumption mixes")
WASTE_NAME_PREFIXES = ("Wastewater", "Waste ", "Disposal,")
UNIT_KWH = "kilowatt hour"
UNIT_MJ = "megajoule"
UNIT_TKM = "ton kilometer"
MJ_PER_KWH = 3.6
# A heat or fuel-burning input, whatever its unit
HEAT_NAME = re.compile(r"^Heat\b|\bburned\b")
# A dataset copied from ecoinvent: "Name {geography}| activity | Cut-off, S - Copied ..."
ECOINVENT_DATASET_NAME = re.compile(r"\}\| ")
COPRODUCT_PATTERN = re.compile(r"^(?P<prefix>.*), 1 (?:kg|L|l) of (?P<product>.*?) \{")


class InputClass(str, Enum):
    """What the walk does with an input activity. Every class but `transform` stops the
    walk and accumulates the input's quantity per kg of product."""

    raw = "raw"  # agricultural raw material, kg per activity name
    elec = "elec"  # electricity, kWh per activity name (keeps the country)
    heat = "heat"  # heat, MJ per activity name (keeps gas, fuel oil, steam…)
    water = "water"  # tap water, kg
    biowaste = "biowaste"  # kg
    transport = "transport"  # tkm
    waste = "waste"  # waste and wastewater treatment, per activity name
    transform = "transform"  # a transformation step: the walk descends into it
    other = "other"  # everything else (salt, chemicals, packaging), per activity name


@dataclass(frozen=True)
class Node:
    name: str
    unit: str
    production_amount: float
    category_path: tuple[str, ...]


class Graph(Protocol):
    def node(self, name: str) -> Node | None: ...

    def inputs(self, node: Node) -> list[tuple[Node, float]]:
        """Technosphere inputs of `node` with their amount for one production of it,
        before normalisation by `production_amount`."""
        ...

    def siblings(self, node: Node) -> list[Node]:
        """Activities born from the same multi-output process (the co-products)."""
        ...


@dataclass
class CatalogIngredient:
    alias: str
    metadata_id: str
    activity_name: str
    source: str
    display_name: str
    scopes: tuple[str, ...]
    scenario: str | None
    default_origin: str | None


def load_catalog_ingredients(
    lci_catalog_dir: Path,
) -> dict[str, list[CatalogIngredient]]:
    """Food ingredients of the LCI catalog keyed by Brightway activity name, one entry
    per metadata variant (alias)."""
    by_activity: dict[str, list[CatalogIngredient]] = {}
    for path in sorted(lci_catalog_dir.glob("*/*.json")):
        activity = json.loads(path.read_text())
        if "ingredient" not in activity.get("categories", []):
            continue
        if not FOOD_SCOPES & set(activity.get("scopes", [])):
            continue
        activity_name = activity["activityName"]
        for metadata in activity.get("metadata", []):
            if not FOOD_SCOPES & set(metadata.get("scopes", [])):
                continue
            by_activity.setdefault(activity_name, []).append(
                CatalogIngredient(
                    alias=metadata["alias"],
                    metadata_id=metadata["id"],
                    activity_name=activity_name,
                    source=activity.get("source", ""),
                    display_name=metadata.get("displayName", ""),
                    scopes=tuple(metadata.get("scopes", [])),
                    scenario=metadata.get("scenario"),
                    default_origin=metadata.get("defaultOrigin"),
                )
            )
    return by_activity


def preferred_ingredient(variants: list[CatalogIngredient]) -> CatalogIngredient:
    """The variant a component should point at. Several aliases can share one activity
    (the carrot activity also stands for beetroot and parsnip): prefer the alias whose
    first word names the activity, then food2, then the reference scenario."""

    def rank(ingredient: CatalogIngredient) -> tuple[int, int, int, str]:
        first_word = ingredient.alias.split("-")[0]
        return (
            0 if first_word in ingredient.activity_name.lower() else 1,
            0 if "food2" in ingredient.scopes else 1,
            0 if ingredient.scenario == "reference" else 1,
            ingredient.alias,
        )

    return min(variants, key=rank)


def is_farm_gate(node: Node) -> bool:
    """A raw agricultural product: farm-gate folder, farm-gate name, or an ecoinvent
    primary production activity."""
    return (
        node.category_path[:2] in FARM_GATE_PATHS
        or FARM_GATE_NAME.search(node.name) is not None
        or ECOINVENT_PRODUCTION_NAME.search(node.name) is not None
    )


def is_transform_path(path: tuple[str, ...]) -> bool:
    """An Agribalyse process with its own exchanges that the walk may descend into."""
    if path[:1] == ("Agricultural",):
        return path[1:2] not in {(folder,) for folder in NOT_TRANSFORM_AGRICULTURAL}
    if path[:1] in {(root,) for root in OTHER_TRANSFORM_ROOTS}:
        return True
    return (
        path[:1] == ("Others",)
        and path[1:2] != ()
        and path[1].startswith(ADAPTED_PREFIX)
    )


def heat_mj_per_unit(node: Node) -> float:
    """MJ per unit of a heat input. A few ecoinvent heat and diesel markets are labelled
    kWh in our Agribalyse 3.2 import while their amounts are MJ: ecoinvent publishes them
    in MJ and Agribalyse 4.0 shows the same amounts in MJ. Their amount is kept as is. A
    native Agribalyse activity really in kWh ("Energy from Liquefied petroleum gas,
    burned", 0.083 kg of LPG per unit) is converted."""
    if node.unit == UNIT_KWH and not ECOINVENT_DATASET_NAME.search(node.name):
        return MJ_PER_KWH
    return 1.0


def classify(
    node: Node, catalog_names: set[str], stop_at_catalog: bool = False
) -> InputClass:
    """Class of an input activity, first rule wins. A catalog ingredient is raw unless it
    is itself a transformed Agribalyse product (then it is recursed, so that the olive oil
    consumption mix reaches the olives), or always with `stop_at_catalog`. Electricity is
    a kWh input named "Electricity" (all are ecoinvent markets). Heat is every MJ input
    (gas and fuel oil heat markets, propane furnaces, steam) and every kWh input named as
    heat or a burned fuel, see `heat_mj_per_unit`. Any other kWh activity (coffee
    treatment with electric machinery) is a process, classed by the rules below."""
    path = node.category_path
    if node.name.startswith("Tap water"):
        return InputClass.water
    if node.name in catalog_names and (stop_at_catalog or not is_transform_path(path)):
        return InputClass.raw
    if node.unit == UNIT_KWH and node.name.startswith("Electricity"):
        return InputClass.elec
    if node.unit == UNIT_MJ or (node.unit == UNIT_KWH and HEAT_NAME.search(node.name)):
        return InputClass.heat
    if node.name.startswith("Biowaste"):
        return InputClass.biowaste
    if node.unit == UNIT_TKM or node.name.startswith("Transport"):
        return InputClass.transport
    if path[:1] == ("Waste to treatment",) or node.name.startswith(WASTE_NAME_PREFIXES):
        return InputClass.waste
    if "treatment of" in node.name and "Cut-off" in node.name:
        return InputClass.waste
    if is_farm_gate(node):
        return InputClass.raw
    if is_transform_path(path):
        return InputClass.transform
    return InputClass.other


@dataclass
class Totals:
    """Quantities per kg of the product that owns them."""

    raw: dict[str, float] = field(default_factory=dict)
    elec_kwh: float = 0.0
    elec_detail: dict[str, float] = field(default_factory=dict)
    heat_mj: float = 0.0
    heat_detail: dict[str, float] = field(default_factory=dict)
    water_kg: float = 0.0
    biowaste_kg: float = 0.0
    transport_tkm: float = 0.0
    waste: dict[str, float] = field(default_factory=dict)
    other: dict[str, float] = field(default_factory=dict)
    other_units: dict[str, str] = field(default_factory=dict)
    steps: set[str] = field(default_factory=set)
    truncated: set[str] = field(default_factory=set)

    def add(self, other: Totals, factor: float) -> None:
        for name, quantity in other.raw.items():
            self.raw[name] = self.raw.get(name, 0.0) + quantity * factor
        self.elec_kwh += other.elec_kwh * factor
        for name, quantity in other.elec_detail.items():
            self.elec_detail[name] = self.elec_detail.get(name, 0.0) + quantity * factor
        self.heat_mj += other.heat_mj * factor
        for name, quantity in other.heat_detail.items():
            self.heat_detail[name] = self.heat_detail.get(name, 0.0) + quantity * factor
        self.water_kg += other.water_kg * factor
        self.biowaste_kg += other.biowaste_kg * factor
        self.transport_tkm += other.transport_tkm * factor
        for name, quantity in other.waste.items():
            self.waste[name] = self.waste.get(name, 0.0) + quantity * factor
        for name, quantity in other.other.items():
            self.other[name] = self.other.get(name, 0.0) + quantity * factor
        self.other_units.update(other.other_units)
        self.steps |= other.steps
        self.truncated |= other.truncated

    @property
    def raw_kg(self) -> float:
        return sum(self.raw.values())

    @property
    def main_raw(self) -> tuple[str, float] | None:
        if not self.raw:
            return None
        return max(self.raw.items(), key=lambda raw_item: raw_item[1])

    @property
    def main_raw_share(self) -> float | None:
        main = self.main_raw
        if main is None or self.raw_kg == 0:
            return None
        return main[1] / self.raw_kg


@dataclass
class Decomposition:
    product: str
    unit: str
    totals: Totals
    coproducts: list[tuple[str, float]]

    def to_dict(self) -> dict:
        totals = self.totals
        return {
            "product": self.product,
            "unit": self.unit,
            "raw": totals.raw,
            "raw_kg": totals.raw_kg,
            "main_raw": totals.main_raw[0] if totals.main_raw else None,
            "main_raw_kg": totals.main_raw[1] if totals.main_raw else None,
            "main_raw_share": totals.main_raw_share,
            "elec_kwh": totals.elec_kwh,
            "elec_detail": totals.elec_detail,
            "heat_mj": totals.heat_mj,
            "heat_detail": totals.heat_detail,
            "water_kg": totals.water_kg,
            "biowaste_kg": totals.biowaste_kg,
            "transport_tkm": totals.transport_tkm,
            "waste": totals.waste,
            "other": totals.other,
            "other_units": totals.other_units,
            "coproducts": self.coproducts,
            "steps": sorted(totals.steps),
            "truncated": sorted(totals.truncated),
        }


class Decomposer:
    """Memoised traversal: the totals of an activity per kg of its product are computed
    once and reused by every product that consumes it."""

    def __init__(
        self,
        graph: Graph,
        catalog_names: set[str],
        stop_at_catalog: bool = False,
        max_depth: int = MAX_DEPTH,
    ):
        self.graph = graph
        self.catalog_names = catalog_names
        self.stop_at_catalog = stop_at_catalog
        self.max_depth = max_depth
        self._memo: dict[str, Totals] = {}
        self._raw_mix: dict[str, bool] = {}

    def decompose(self, product_name: str) -> Decomposition:
        node = self.graph.node(product_name)
        if node is None:
            raise KeyError(f"activity not found: {product_name}")
        totals = self._totals(node, stack=(), depth=0)
        return Decomposition(
            product=product_name,
            unit=node.unit,
            totals=totals,
            coproducts=[
                (sibling.name, sibling.production_amount)
                for sibling in self.graph.siblings(node)
            ],
        )

    def classify(self, node: Node) -> InputClass:
        """Class of an input during this walk: the module-level `classify` rules, plus
        one rule that needs the graph. A consumption mix that the rules would descend
        into is classed raw when it averages several raw materials (see `_is_raw_mix`),
        so the goat milk mix stays one raw material instead of being split into its farm
        systems. The rules alone only see the activity itself, not its inputs."""
        input_class = classify(node, self.catalog_names, self.stop_at_catalog)
        if input_class is InputClass.transform and self._is_raw_mix(node):
            return InputClass.raw
        return input_class

    def _is_raw_mix(self, node: Node) -> bool:
        """A consumption mix averaging several raw materials with their transport (the
        goat milk mix over its farm systems) is kept whole as the raw material, so that
        the variants are not split. A mix of a single raw material is walked through."""
        if node.category_path[:3] != CONSUMPTION_MIX_PATH:
            return False
        if node.name not in self._raw_mix:
            classes = [
                classify(input_node, self.catalog_names, self.stop_at_catalog)
                for input_node, amount in self.graph.inputs(node)
                if amount
            ]
            raws = classes.count(InputClass.raw)
            self._raw_mix[node.name] = raws >= 2 and set(classes) <= {
                InputClass.raw,
                InputClass.transport,
            }
        return self._raw_mix[node.name]

    def _totals(self, node: Node, stack: tuple[str, ...], depth: int) -> Totals:
        if node.name in self._memo:
            return self._memo[node.name]
        totals = Totals(steps={node.name})
        production_amount = node.production_amount or 1.0
        for input_node, amount in self.graph.inputs(node):
            # `amount` is for one run of the activity, which makes `production_amount` of
            # product. Dividing gives the quantity per kg of product. The Comté activity
            # takes 10 kg of milk for a production amount of 2.0785 kg, so 4.81 kg of
            # milk per kg of Comté.
            quantity = amount / production_amount
            if quantity == 0:
                continue
            input_class = self.classify(input_node)
            if input_class is InputClass.raw:
                totals.raw[input_node.name] = (
                    totals.raw.get(input_node.name, 0.0) + quantity
                )
            elif input_class is InputClass.elec:
                totals.elec_kwh += quantity
                totals.elec_detail[input_node.name] = (
                    totals.elec_detail.get(input_node.name, 0.0) + quantity
                )
            elif input_class is InputClass.heat:
                heat_mj = quantity * heat_mj_per_unit(input_node)
                totals.heat_mj += heat_mj
                totals.heat_detail[input_node.name] = (
                    totals.heat_detail.get(input_node.name, 0.0) + heat_mj
                )
            elif input_class is InputClass.water:
                totals.water_kg += quantity
            elif input_class is InputClass.biowaste:
                totals.biowaste_kg += quantity
            elif input_class is InputClass.transport:
                totals.transport_tkm += quantity
            elif input_class is InputClass.waste:
                totals.waste[input_node.name] = (
                    totals.waste.get(input_node.name, 0.0) + quantity
                )
            elif input_class is InputClass.transform:
                if input_node.name in stack or depth >= self.max_depth:
                    totals.truncated.add(input_node.name)
                    self._add_other(totals, input_node, quantity)
                    continue
                child = self._totals(input_node, stack + (node.name,), depth + 1)
                totals.add(child, quantity)
            else:
                self._add_other(totals, input_node, quantity)
        self._memo[node.name] = totals
        return totals

    @staticmethod
    def _add_other(totals: Totals, input_node: Node, quantity: float) -> None:
        totals.other[input_node.name] = (
            totals.other.get(input_node.name, 0.0) + quantity
        )
        totals.other_units[input_node.name] = input_node.unit


class BrightwayGraph:
    """Graph over one bw2data database. The SimaPro category path is read on the
    production exchange, the activity-level `categories` field is empty in our import."""

    def __init__(self, database):
        self.database = database
        self._nodes: dict[str, Node] = {}
        self._activities: dict[str, Activity] = {}
        self._by_name: dict[str, Activity] | None = None

    def _index(self) -> dict[str, Activity]:
        if self._by_name is None:
            self._by_name = {activity["name"]: activity for activity in self.database}
        return self._by_name

    def _node_of(self, activity: Activity) -> Node:
        name = activity["name"]
        if name not in self._nodes:
            productions = list(activity.production())
            production = productions[0] if productions else None
            self._nodes[name] = Node(
                name=name,
                unit=activity["unit"],
                production_amount=float(production["amount"]) if production else 1.0,
                category_path=tuple((production or {}).get("categories") or ()),
            )
            self._activities[name] = activity
        return self._nodes[name]

    def node(self, name: str) -> Node | None:
        activity = self._index().get(name)
        return self._node_of(activity) if activity is not None else None

    def food_activity_names(self) -> list[str]:
        """Names of every activity under the `Agricultural / Food` category, the
        scope of the ecolysis workbook."""
        return sorted(
            name
            for name, activity in self._index().items()
            if self._node_of(activity).category_path[:2] == FOOD_PATH
        )

    def inputs(self, node: Node) -> list[tuple[Node, float]]:
        activity = self._activities[node.name]
        return [
            (self._node_of(exchange.input), float(exchange["amount"]))
            for exchange in activity.technosphere()
            if exchange.input["name"] != node.name
        ]

    def siblings(self, node: Node) -> list[Node]:
        match = COPRODUCT_PATTERN.match(node.name)
        if match is None:
            return []
        prefix = match.group("prefix") + ", 1 "
        return [
            self._node_of(activity)
            for name, activity in self._index().items()
            if name.startswith(prefix) and name != node.name
        ]


class InMemoryGraph:
    """Graph for tests: nodes and their inputs given as plain data."""

    def __init__(
        self,
        nodes: dict[str, Node],
        inputs: dict[str, list[tuple[str, float]]],
        siblings: dict[str, list[str]] | None = None,
    ):
        self._nodes = nodes
        self._inputs = inputs
        self._siblings = siblings or {}

    def node(self, name: str) -> Node | None:
        return self._nodes.get(name)

    def inputs(self, node: Node) -> list[tuple[Node, float]]:
        return [
            (self._nodes[name], amount)
            for name, amount in self._inputs.get(node.name, [])
        ]

    def siblings(self, node: Node) -> list[Node]:
        return [self._nodes[name] for name in self._siblings.get(node.name, [])]
