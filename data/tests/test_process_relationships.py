from common.export import load_json
from config import PROJECT_ROOT_DIR


def check_process_relationships(items, processes, item_type):
    """
    Check that each processId in items exists in processes and log warnings for duplicates.

    Args:
        items: List of items (ingredients or materials) containing processId
        processes: Dictionary of processes indexed by their id
        item_type: String describing the type of items ("ingredient" or "material")
    """
    # Check each item's processId
    for item in items:
        process_id = item.get("processId")
        if process_id is None:
            continue  # Skip items without processId

        # Verify that the processId exists in processes.json
        if process_id not in processes.keys():
            raise ValueError(
                f"Process ID {process_id} from {item_type} {item.get('name', 'unknown')} not found in processes.json"
            )


def test_process_relationships():
    processes_path = PROJECT_ROOT_DIR / "public" / "data" / "processes.json"
    processes_data = load_json(processes_path)
    processes = {p["id"]: p for p in processes_data}

    # Check ingredients against food processes
    ingredients_path = (
        PROJECT_ROOT_DIR / "public" / "data" / "food" / "ingredients.json"
    )

    ingredients = load_json(ingredients_path)
    check_process_relationships(ingredients, processes, "ingredient")

    # Check materials against textile processes
    materials_path = PROJECT_ROOT_DIR / "public" / "data" / "textile" / "materials.json"

    materials = load_json(materials_path)
    check_process_relationships(materials, processes, "material")
