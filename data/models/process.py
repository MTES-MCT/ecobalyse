import uuid
from enum import Enum
from typing import Annotated, Any

from pydantic import AfterValidator, AliasGenerator, BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel, to_snake

from common.export import (
    validate_id,
)


class Scope(str, Enum):
    food = "food"
    food2 = "food2"
    object = "object"
    textile = "textile"
    veli = "veli"


GENERIC_SCOPES = {Scope.object, Scope.veli, Scope.food2}


class EcoModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=AliasGenerator(
            validation_alias=to_snake,
            serialization_alias=to_camel,
        ),
    )


class ComputedBy(str, Enum):
    brightway = "brightway"
    hardcoded = "hardcoded"


class UnitEnum(str, Enum):
    KG = "kg"
    TKM = "t⋅km"
    KWH = "kWh"
    MJ = "MJ"
    L = "L"
    ITEM = "item"
    M2 = "m2"
    M3 = "m3"


class ForestManagement(str, Enum):
    intensive_plantation = "intensivePlantation"
    sustainable_management = "sustainableManagement"
    certified_sustainable_management = "certifiedSustainableManagement"
    diversified_forest = "diversifiedForest"
    certified_diversified_forest = "certifiedDiversifiedForest"


class Impacts(BaseModel):
    acd: float = 0
    cch: float = 0
    etf: float = 0
    etf_c: Annotated[float, Field(alias="etf-c")] = 0
    fru: float = 0
    fwe: float = 0
    htc: float = 0
    htc_c: Annotated[float, Field(alias="htc-c")] = 0
    htn: float = 0
    htn_c: Annotated[float, Field(alias="htn-c")] = 0
    ior: float = 0
    ldu: float = 0
    mru: float = 0
    ozd: float = 0
    pco: float = 0
    pma: float = 0
    swe: float = 0
    tre: float = 0
    wtu: float = 0
    ecs: float = 0

    model_config = ConfigDict(
        alias_generator=AliasGenerator(
            validation_alias=to_snake,
            serialization_alias=to_camel,
        ),
    )


class Cff(EcoModel):
    manufacturer_allocation: float
    recycled_quality_ratio: float


class Material(EcoModel):
    id: uuid.UUID
    alias: Annotated[str, AfterValidator(validate_id)]
    recycled_from: uuid.UUID | None
    name: str
    origin: str
    primary: bool | None
    geographic_origin: str
    default_country: str
    cff: Cff | None
    process_id: uuid.UUID


class Complements(EcoModel):
    forest: float | None = None
    crop_diversity: float | None = None
    hedges: float | None = None
    permanent_pasture: float | None = None
    plot_size: float | None = None


class IngredientMetadata(EcoModel):
    base_ingredient: str
    crop_group: str | None = None
    scenario: str | None = None
    process_id: uuid.UUID


class ProcessGenericMetadata(EcoModel):
    forest_management: ForestManagement | None = None
    complements: Complements | None = None
    ingredient: IngredientMetadata | None = None
    default_origin: str | None = None


class ProcessGeneric(EcoModel):
    activity_name: str
    alias: Annotated[str, AfterValidator(validate_id)] | None = None
    categories: list[str]
    comment: str
    display_name: str
    elec_kwh: Annotated[float, Field(serialization_alias="elecKwh")]
    heat_mj: Annotated[float, Field(serialization_alias="heatMJ")]
    id: uuid.UUID
    impacts: Impacts
    land_occupation: float | None = None
    location: str | None
    mass_per_unit: float | None
    metadata: ProcessGenericMetadata | None = None
    scopes: list[Scope]
    source: str
    unit: UnitEnum | None
    qty_variation_ratio: float
    visible: bool = True


class EcosystemicServices(EcoModel):
    crop_diversity: float
    hedges: float
    permanent_pasture: float | None = None
    plot_size: float


class Ingredient(EcoModel):
    alias: Annotated[str, AfterValidator(validate_id)]
    base_ingredient: str
    categories: list[str]
    crop_group: str | None
    default_origin: str
    density: float
    ecosystemic_services: EcosystemicServices | None
    id: uuid.UUID
    inedible_part: float
    land_occupation: float | None
    name: str
    raw_to_cooked_ratio: float
    scenario: str | None
    location: str | None
    activity_name: str
    transport_cooling: str
    visible: bool
    process_id: uuid.UUID


class Process(EcoModel):
    bw_activity: Any | None
    categories: list[str]
    comment: str
    computed_by: ComputedBy | None
    mass_per_unit: float | None
    display_name: str
    elec_kwh: Annotated[float, Field(serialization_alias="elecKwh")]
    heat_mj: Annotated[float, Field(serialization_alias="heatMJ")]
    id: uuid.UUID | None
    impacts: Impacts | None = None
    location: str | None
    scopes: list[Scope]
    source: str
    # Process identifier in Simapro
    activity_name: str
    unit: UnitEnum | None
    qty_variation_ratio: float
