from enum import StrEnum


class Category(StrEnum):
    ENERGY = "energy"
    EOL = "eol"
    INGREDIENT = "ingredient"
    MATERIAL = "material"
    MATERIAL_TYPE_METAL = "material_type:metal"
    MATERIAL_TYPE_PLASTIC = "material_type:plastic"
    MATERIAL_TYPE_UPHOLSTERY = "material_type:upholstery"
    MATERIAL_TYPE_WOOD = "material_type:wood"
    PACKAGING = "packaging"
    TEXTILE_MATERIAL = "textile_material"
    TRANSFORMATION = "transformation"
    TRANSPORT = "transport"
    USE = "use"


class Unit(StrEnum):
    ITEM = "Item(s)"
    KG = "kg"
    KWH = "kWh"
    L = "L"
    M2 = "m2"
    M3 = "m3"
    MJ = "MJ"
    T_KM = "t⋅km"
