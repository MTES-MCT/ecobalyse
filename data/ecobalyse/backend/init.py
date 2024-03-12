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
        Material.objects.bulk_create(
            [
                Material(**delkey("recycledFrom", delkey("primary", flatten("cff", p))))
                for p in materials
            ]
        )
        tuples = [
            (Material.objects.get(pk=p["id"]), p.get("recycledFrom")) for p in materials
        ]
        for t in tuples:
            t[0].recycledFrom = Material.objects.get(pk=t[1]) if t[1] else None
        Material.objects.bulk_update([t[0] for t in tuples], ["recycledFrom"])
