import uuid
from enum import Enum
from typing import Any, List, Optional

from pydantic import AfterValidator, AliasGenerator, BaseModel, ConfigDict, Field
from pydantic.alias_generators import to_camel, to_snake
from typing_extensions import Annotated

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
    simapro = "simapro"


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
    recycled_from: Optional[uuid.UUID]
    name: str
    origin: str
    primary: Optional[bool]
    geographic_origin: str
    default_country: str
    cff: Optional[Cff]
    process_id: uuid.UUID


class Complements(EcoModel):
    forest: Optional[float] = None
    crop_diversity: Optional[float] = None
    hedges: Optional[float] = None
    permanent_pasture: Optional[float] = None
    plot_size: Optional[float] = None


class IngredientMetadata(EcoModel):
    base_ingredient: str
    crop_group: Optional[str] = None
    density: float
    inedible_part: float
    raw_to_cooked_ratio: float
    scenario: Optional[str] = None
    transport_cooling: str
    process_id: uuid.UUID


class ProcessGenericMetadata(EcoModel):
    forest_management: Optional[ForestManagement] = None
    complements: Optional[Complements] = None
    ingredient: Optional[IngredientMetadata] = None
    default_origin: Optional[str] = None


class ProcessGeneric(EcoModel):
    activity_name: str
    alias: Optional[Annotated[str, AfterValidator(validate_id)]] = None
    categories: List[str]
    comment: str
    display_name: str
    elec_mj: Annotated[float, Field(serialization_alias="elecMJ")]
    heat_mj: Annotated[float, Field(serialization_alias="heatMJ")]
    id: uuid.UUID
    impacts: Impacts
    land_occupation: Optional[float] = None
    location: Optional[str]
    mass_per_unit: Optional[float]
    metadata: Optional[ProcessGenericMetadata] = None
    scopes: List[Scope]
    source: str
    unit: Optional[UnitEnum]
    qty_variation_ratio: float
    visible: bool = True


class EcosystemicServices(EcoModel):
    crop_diversity: float
    hedges: float
    permanent_pasture: Optional[float] = None
    plot_size: float


class Ingredient(EcoModel):
    alias: Annotated[str, AfterValidator(validate_id)]
    base_ingredient: str
    categories: List[str]
    crop_group: Optional[str]
    default_origin: str
    density: float
    ecosystemic_services: Optional[EcosystemicServices]
    id: uuid.UUID
    inedible_part: float
    land_occupation: Optional[float]
    name: str
    raw_to_cooked_ratio: float
    scenario: Optional[str]
    location: Optional[str]
    activity_name: str
    transport_cooling: str
    visible: bool
    process_id: uuid.UUID


class Process(EcoModel):
    bw_activity: Optional[Any]
    categories: List[str]
    comment: str
    computed_by: Optional[ComputedBy]
    mass_per_unit: Optional[float]
    display_name: str
    elec_mj: Annotated[float, Field(serialization_alias="elecMJ")]
    heat_mj: Annotated[float, Field(serialization_alias="heatMJ")]
    id: Optional[uuid.UUID]
    impacts: Optional[Impacts] = None
    location: Optional[str]
    scopes: List[Scope]
    source: str
    # Process identifier in Simapro
    activity_name: str
    unit: Optional[UnitEnum]
    qty_variation_ratio: float
