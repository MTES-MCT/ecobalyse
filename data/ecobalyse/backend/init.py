from os.path import dirname, join, abspath
import json
from backend.models import Process, Material, Example, Product

here = dirname(abspath(__file__))


def flatten(field, record):
    """take a record and flatten the given fields
    >>> flatten('b', {a: 1, b: {c: 2, d: 3}})
    {a: 1, c: 2, d: 3}
    """
    if field in record:
        if record.get(field):
            record.update(record[field])
        del record[field]

    return record


def delchar(char, record):
    """remove invalid char from dict keys
    >>> delchar('-', {htn-c: 0, htc-c: 0})
    {htnc: 0, htcc: 0}
    """
    return {k.replace(char, ""): v for k, v in record.items()}


def delkey(key, record):
    """remove key from dict"""
    if key in record:
        del record[key]
    return record


def init():
    """populate the db with public json data"""
    # PROCESSES
    with open(
        join(
            dirname(dirname(dirname(here))),
            "public",
            "data",
            "textile",
            "processes.json",
        )
    ) as f:
        processes = json.load(f)
        Process.objects.bulk_create(
            [
                Process(**delkey("bvi", delchar("-", flatten("impacts", p))))
                for p in processes
            ]
        )

    # MATERIALS
    with open(
        join(
            dirname(dirname(dirname(here))),
            "public",
            "data",
            "textile",
            "materials.json",
        )
    ) as f:
        materials = json.load(f)
        # all fields except the recursive recycledFrom foreignkey
        Material.objects.bulk_create(
            [
                Material(
                    **delkey(
                        "recycledFrom", delkey("primary", flatten("cff", m.copy()))
                    )
                )
                for m in materials
            ]
        )
        # update with recycledFrom
        mobjects = [Material.objects.get(pk=m["id"]) for m in materials]
        recycledFroms = {m["id"]: m.get("recycledFrom") for m in materials}
        for m in mobjects:
            m.recycledFrom = (
                Material.objects.get(pk=recycledFroms[m.id])
                if recycledFroms[m.id]
                else None
            )
        Material.objects.bulk_update(mobjects, ["recycledFrom"])

    # PRODUCTS
    with open(
        join(
            dirname(dirname(dirname(here))),
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
                                "making", flatten("dyeing", flatten("economics", p))
                            ),
                        ),
                    )
                )
                for p in products
            ]
        )
