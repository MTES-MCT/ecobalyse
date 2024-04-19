import json
from copy import deepcopy
from os.path import join

from django.conf import settings

from textile.models import (
    Example,
    Material,
    Process,
    Product,
    delchar,
    delkey,
    flatten,
)


def init():
    """populate the db with initial admins and public json data"""

    # PROCESSES
    if Process.objects.count() == 0:
        with open(
            join(
                settings.GITROOT,
                "public",
                "data",
                "textile",
                "processes_impacts.json",
            )
        ) as f:
            processes = json.load(f)
            Process.objects.bulk_create(
                [
                    Process(
                        **delkey("bvi", delchar("-", flatten("impacts", deepcopy(p))))
                    )
                    for p in processes
                ]
            )
    else:
        print("Processes already loaded")

    # MATERIALS
    if Material.objects.count() == 0:
        with open(
            join(
                settings.GITROOT,
                "public",
                "data",
                "textile",
                "materials.json",
            )
        ) as f:
            materials = json.load(f)
            # all fields except the foreignkeys
            Material.objects.bulk_create(
                [
                    Material(
                        **delkey(
                            "recycledFrom",
                            delkey(
                                "materialProcessUuid",
                                delkey(
                                    "recycledProcessUuid",
                                    delkey("primary", flatten("cff", deepcopy(m))),
                                ),
                            ),
                        )
                    )
                    for m in materials
                ]
            )
            # update with recycledFrom
            mobjects = [Material.objects.get(pk=m["id"]) for m in materials]
            recycledFroms = {m["id"]: m.get("recycledFrom") for m in materials}
            materialProcesses = {
                m["id"]: m.get("materialProcessUuid") for m in materials
            }
            recycledProcesses = {
                m["id"]: m.get("recycledProcessUuid") for m in materials
            }
            for m in mobjects:
                m.recycledFrom = (
                    Material.objects.get(pk=recycledFroms[m.id])
                    if recycledFroms[m.id]
                    else None
                )
                m.materialProcessUuid = (
                    Process.objects.get(pk=materialProcesses[m.id])
                    if materialProcesses[m.id]
                    else None
                )
                m.recycledProcessUuid = (
                    Process.objects.get(pk=recycledProcesses[m.id])
                    if recycledProcesses[m.id]
                    else None
                )
            Material.objects.bulk_update(
                mobjects, ["recycledFrom", "materialProcessUuid", "recycledProcessUuid"]
            )
    else:
        print("Materials already loaded")

    # PRODUCTS
    if Product.objects.count() == 0:
        with open(
            join(
                settings.GITROOT,
                "public",
                "data",
                "textile",
                "products.json",
            )
        ) as f:
            products = json.load(f)
            Product.objects.bulk_create(
                [
                    Product(
                        **flatten(
                            "endOfLife",
                            flatten(
                                "use",
                                flatten(
                                    "making",
                                    flatten(
                                        "dyeing",
                                        flatten(
                                            "economics",
                                            delkey(
                                                "use.nonIroningProcessUuid", deepcopy(p)
                                            ),
                                        ),
                                    ),
                                ),
                            ),
                        )
                    )
                    for p in products
                ]
            )
        pobjects = [Product.objects.get(pk=p["id"]) for p in products]
        nonIroningProcesses = {
            p["id"]: p["use"]["nonIroningProcessUuid"] for p in products
        }
        for p in pobjects:
            p.nonIroningProcessUuid = Process.objects.get(pk=nonIroningProcesses[p.id])
        Product.objects.bulk_update(pobjects, ["nonIroningProcessUuid"])
    else:
        print("Products already loaded")

    # EXAMPLES
    if Example.objects.count() == 0:
        with open(
            join(
                settings.GITROOT,
                "public",
                "data",
                "textile",
                "examples.json",
            )
        ) as f:
            examples = json.load(f)
            # all fields except the m2m
            Example.objects.bulk_create([Example._fromJSON(e) for e in examples])
            # create the m2m intermediary records
            for e in examples:
                for s in e["query"]["materials"]:
                    Example.objects.get(pk=e["id"]).add_material(s)
            Example
    else:
        print("Examples already loaded")
