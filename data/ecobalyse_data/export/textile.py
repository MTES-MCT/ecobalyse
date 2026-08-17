from pathlib import Path

from common.export import export_json
from ecobalyse_data.export.utils import get_metadata_for_scope
from ecobalyse_data.logging import logger
from models.process import Cff, Material


def activities_to_materials_json(
    activities: list[dict], materials_path: Path
) -> list[Material]:
    materials = activities_to_materials_list(activities)

    materials_dicts = [material.model_dump(by_alias=True) for material in materials]

    materials_dicts.sort(key=lambda x: x["id"])

    export_json(materials_dicts, materials_path)

    logger.info(f"-> Exported {len(materials_dicts)} materials to {materials_path}")

    return materials_dicts


def activities_to_materials_list(activities: list[dict]) -> list[Material]:
    materials = []
    for activity in activities:
        materials.extend(activity_to_materials(activity))
    return materials


def activity_to_materials(eco_activity: dict) -> list[Material]:
    materials = []

    for textile_metadata in get_metadata_for_scope(eco_activity, "textile"):
        cff = textile_metadata.get("cff")

        if cff:
            cff = Cff(
                manufacturer_allocation=cff.get("manufacturerAllocation"),
                recycled_quality_ratio=cff.get("recycledQualityRatio"),
            )

        materials.append(
            Material(
                alias=textile_metadata["alias"],
                id=textile_metadata["id"],
                process_id=eco_activity["id"],
                recycled_from=textile_metadata.get("recycledFrom"),
                origin=textile_metadata["origin"],
                name=textile_metadata["name"],
                primary=textile_metadata.get("primary"),
                geographic_origin=textile_metadata["geographicOrigin"],
                default_country=textile_metadata["defaultCountry"],
                cff=cff,
            )
        )
    return materials
