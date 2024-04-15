import json
from copy import deepcopy
from os.path import join

from decouple import config  # python-decouple to read in .env
from django.conf import settings
from django.contrib.auth import get_user_model

from textile.models import Example, Material, Process, Product, Share

# create initial admins given by an env var. Mails separated by comma
for email in [m.strip() for m in str(config("BACKEND_ADMINS")).split(",")]:
    get_user_model().objects.create_superuser(email)


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
    """remove key from dict. The key may be dotted to delete a subfield:
    >>> delkey('a.b', {'a': {'b': 1, 'c': 2}})
    'a': {'c': 2}}
    """
    k = key.split(".")[-1]
    path = list(reversed(key.split(".")[:-1]))
    d = record
    while len(path):
        d = d.get(path.pop())
    if k in d:
        del d[k]
    return record


def init():
    """populate the db with public json data"""
    # PROCESSES
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
                Process(**delkey("bvi", delchar("-", flatten("impacts", deepcopy(p)))))
                for p in processes
            ]
        )

    # MATERIALS
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
        materialProcesses = {m["id"]: m.get("materialProcessUuid") for m in materials}
        recycledProcesses = {m["id"]: m.get("recycledProcessUuid") for m in materials}
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

    # PRODUCTS
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
    nonIroningProcesses = {p["id"]: p["use"]["nonIroningProcessUuid"] for p in products}
    for p in pobjects:
        p.nonIroningProcessUuid = Process.objects.get(pk=nonIroningProcesses[p.id])
    Product.objects.bulk_update(pobjects, ["nonIroningProcessUuid"])

    # EXAMPLES
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
        # all fields except the foreignkeys
        Example.objects.bulk_create(
            [
                Example(
                    **delkey(
                        "materials",
                        delkey(
                            "fabricProcess",
                            delkey("product", flatten("query", deepcopy(e))),
                        ),
                    )
                )
                for e in examples
            ]
        )
        # update with product, materials and fabricProcess
        eobjects = [Example.objects.get(pk=m["id"]) for m in examples]
        products = {e["id"]: e["query"]["product"] for e in examples}
        mobjects = [Material.objects.get(pk=m["id"]) for m in materials]
        fabricProcesses = {m["id"]: m["query"]["fabricProcess"] for m in examples}
        for e in eobjects:
            e.product = Product.objects.get(pk=products[e.id])
            e.fabricProcess = Process.objects.get(alias=fabricProcesses[e.id])
        for example in examples:
            for share in example["query"]["materials"]:
                Share.objects.create(
                    example=Example.objects.get(pk=example["id"]),
                    material=Material.objects.get(pk=share["id"]),
                    share=share["share"],
                )
        Example.objects.bulk_update(eobjects, ["product", "fabricProcess"])
