import json
from copy import deepcopy

from django.db.models import (
    CASCADE,
    SET_NULL,
    BooleanField,
    CharField,
    FloatField,
    ForeignKey,
    IntegerField,
    ManyToManyField,
    Model,
)
from django.utils.translation import gettext_lazy as _

from .choices import (
    BUSINESSES,
    COUNTRIES,
    DYEINGMEDIA,
    FABRICS,
    MAKINGCOMPLEXITIES,
    ORIGINS,
    STEPUSAGES,
    UNITS,
)


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


# textile


class Process(Model):
    class Meta:
        verbose_name_plural = "Processes"

    search = CharField(_("Search term"), max_length=200, blank=True)
    name = CharField(_("Name"), max_length=200)
    source = CharField(_("Source Database"), max_length=200)
    info = CharField(_("Informations"), max_length=200)
    unit = CharField(_("Unit"), max_length=50, choices=UNITS)
    uuid = CharField("UUID", max_length=50, primary_key=True)
    acd = FloatField()
    cch = FloatField()
    etf = FloatField()
    etfc = FloatField()
    fru = FloatField()
    fwe = FloatField()
    htc = FloatField()
    htcc = FloatField()
    htn = FloatField()
    htnc = FloatField()
    ior = FloatField()
    ldu = FloatField()
    mru = FloatField()
    ozd = FloatField()
    pco = FloatField()
    pma = FloatField()
    swe = FloatField()
    tre = FloatField()
    wtu = FloatField()
    pef = FloatField()
    ecs = FloatField()
    heat_MJ = FloatField(default=0)
    elec_pppm = FloatField()
    elec_MJ = FloatField()
    waste = FloatField()
    alias = CharField(_("Alias"), max_length=50, null=True)
    step_usage = CharField(_("Step Usage"), max_length=50, choices=STEPUSAGES)
    correctif = CharField(_("Correction"), max_length=200)

    def __str__(self):
        return self.name

    @classmethod
    def _fromJSON(cls, process):
        """Takes a json of a process, returns a Process instance"""
        return Process(
            **delkey("bvi", delchar("-", flatten("impacts", deepcopy(process))))
        )

    @classmethod
    def allToJSON(cls):
        return json.dumps(
            [
                {
                    "name": process.name,
                    "info": process.info,
                    "unit": process.unit,
                    "source": process.source,
                    "correctif": process.correctif,
                    "step_usage": process.step_usage,
                    "uuid": process.uuid,
                    "impacts": {
                        "acd": process.acd,
                        "cch": process.cch,
                        "etf": process.etf,
                        "etfc": process.etfc,
                        "fru": process.fru,
                        "fwe": process.fwe,
                        "htc": process.htc,
                        "htcc": process.htcc,
                        "htn": process.htn,
                        "htnc": process.htnc,
                        "ior": process.ior,
                        "ldu": process.ldu,
                        "mru": process.mru,
                        "ozd": process.ozd,
                        "pco": process.pco,
                        "pma": process.pma,
                        "swe": process.swe,
                        "tre": process.tre,
                        "wtu": process.wtu,
                        "ecs": process.ecs,
                        "pef": process.pef,
                    },
                    "heat_MJ": process.heat_MJ,
                    "elec_pppm": process.elec_pppm,
                    "elec_MJ": process.elec_MJ,
                    "waste": process.waste,
                    "alias": process.alias,
                }
                for process in cls.objects.all()
            ]
        )


class Product(Model):
    id = CharField("ID", max_length=50, primary_key=True)
    name = CharField(_("Name"), max_length=200)
    mass = FloatField()
    surfaceMass = FloatField()
    yarnSize = FloatField()
    fabric = CharField(_("Fabric"), max_length=50, choices=FABRICS)
    # economics
    business = CharField(_("Business Type"), max_length=50, choices=BUSINESSES)
    marketingDuration = FloatField()
    numberOfReferences = IntegerField()
    price = FloatField()
    repairCost = FloatField()
    traceability = BooleanField()
    # dyeing
    defaultMedium = CharField(_("Default Medium"), max_length=50, choices=DYEINGMEDIA)
    # making
    pcrWaste = FloatField()
    complexity = CharField(_("Complexity"), max_length=50, choices=MAKINGCOMPLEXITIES)
    # use
    ironingElecInMJ = FloatField()
    nonIroningProcessUuid = ForeignKey(
        Process, SET_NULL, null=True, related_name="productsNonIroning"
    )
    daysOfWear = IntegerField()
    defaultNbCycles = IntegerField()
    ratioDryer = FloatField()
    ratioIroning = FloatField()
    timeIroning = FloatField()
    wearsPerCycle = FloatField()
    # enf of life
    volume = FloatField()

    def __str__(self):
        return self.name

    @classmethod
    def _fromJSON(cls, product):
        """takes a json of a product, return an instance of Product"""
        # all fields except the foreignkeys
        p = Product(
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
                                delkey("use.nonIroningProcessUuid", deepcopy(product)),
                            ),
                        ),
                    ),
                ),
            )
        )
        p.nonIroningProcessUuid = Process.objects.get(
            pk=product["use"]["nonIroningProcessUuid"]
        )
        return p

    @classmethod
    def allToJSON(cls):
        return json.dumps(
            [
                {
                    "id": product.id,
                    "name": product.name,
                    "mass": product.mass,
                    "surfaceMass": product.surfaceMass,
                    "yarnSize": product.yarnSize,
                    "fabric": product.fabric,
                    "economics": {
                        "business": product.business,
                        "marketingDuration": product.marketingDuration,
                        "numberOfReferences": product.numberOfReferences,
                        "price": product.price,
                        "repairCost": product.repairCost,
                        "traceability": product.traceability,
                    },
                    "dyeing": {"defaultMedium": product.defaultMedium},
                    "making": {
                        "pcrWaste": product.pcrWaste,
                        "complexity": product.complexity,
                        "durationInMinutes": product.durationInMinutes,
                    },
                    "use": {
                        "ironingElecInMJ": product.ironingElecInMJ,
                        "nonIroningProcessUuid": product.nonIroningProcessUuid,
                        "daysOfWear": product.daysOfWear,
                        "defaultNbCycles": product.defaultNbCycles,
                        "ratioDryer": product.ratioDryer,
                        "ratioIroning": product.ratioIroning,
                        "timeIroning": product.timeIroning,
                        "wearsPerCycle": product.wearsPerCycle,
                    },
                    "endOfLife": {"volume": product.volume},
                }
                for product in cls.objects.select_related(
                    "nonIroningProcessUuid",
                ).all()
            ]
        )


class Material(Model):
    id = CharField("ID", max_length=50, primary_key=True)
    materialProcessUuid = ForeignKey(
        Process, SET_NULL, null=True, related_name="materials"
    )
    recycledProcessUuid = ForeignKey(
        Process, SET_NULL, null=True, related_name="recycledMaterials"
    )
    recycledFrom = ForeignKey("self", SET_NULL, null=True, blank=True)
    name = CharField(_("Name"), max_length=200)
    shortName = CharField(_("Short Name"), max_length=50)
    origin = CharField(_("Origin"), max_length=50, choices=ORIGINS)
    geographicOrigin = CharField(_("Geographic Origin"), max_length=200)
    defaultCountry = CharField(_("Default Country"), max_length=3, choices=COUNTRIES)
    priority = IntegerField()
    # cff
    manufacturerAllocation = FloatField(null=True, blank=True)
    recycledQualityRatio = FloatField(null=True, blank=True)

    def __str__(self):
        return self.name

    @classmethod
    def _fromJSON(cls, material):
        """takes a json of a material, returns a Material instance, without recursive FK"""
        m = Material(
            **delkey(
                "recycledFrom",
                delkey(
                    "materialProcessUuid",
                    delkey(
                        "recycledProcessUuid",
                        delkey("primary", flatten("cff", deepcopy(material))),
                    ),
                ),
            )
        )
        if material["materialProcessUuid"]:
            m.materialProcessUuid = Process.objects.get(
                pk=material["materialProcessUuid"]
            )
        if material["recycledProcessUuid"]:
            m.recycledProcessUuid = Process.objects.get(
                pk=material["recycledProcessUuid"]
            )
        # if material["recycledFrom"]:
        #    m.recycledFrom = Material.objects.get(pk=material["recycledFrom"])
        return m

    @classmethod
    def allToJSON(cls):
        return json.dumps(
            [
                {
                    "id": material.id,
                    "materialProcessUuid": material.materialProcessUuid,
                    "recycledProcessUuid": material.recycledProcessUuid,
                    "recycledFrom": material.recycledFrom_id,  # Using _id to get the foreign key value directly
                    "name": material.name,
                    "shortName": material.shortName,
                    "origin": material.origin,
                    "geographicOrigin": material.geographicOrigin,
                    "defaultCountry": material.defaultCountry,
                    "priority": material.priority,
                    "cff": {
                        "manufacturerAllocation": material.manufacturerAllocation,
                        "recycledQualityRatio": material.recycledQualityRatio,
                    },
                }
                for material in cls.objects.all().select_related("recycledFrom")
            ]
        )


class Example(Model):
    id = CharField("ID", max_length=50, primary_key=True)
    name = CharField(_("Name"), max_length=200)

    @property
    def category(self):
        return self.product.name

    mass = FloatField()
    materials = ManyToManyField(Material, through="Share")
    product = ForeignKey(Product, CASCADE, null=True, verbose_name=_("Category"))
    business = CharField(_("Company type"), max_length=50, choices=BUSINESSES)
    marketingDuration = FloatField(_("Marketing Duration"), null=True)
    numberOfReferences = IntegerField(_("Number Of References"), null=True)
    price = FloatField(_("Price"), null=True)
    repairCost = FloatField(_("Repair Cost"), null=True, blank=True)
    traceability = BooleanField(_("Traceability Displayed?"), null=True)
    airTransportRatio = FloatField(_("Air Transport Ratio"), null=True)

    countrySpinning = CharField(_("Spinning Country"), max_length=50, choices=COUNTRIES)
    countryFabric = CharField(_("Fabric Country"), max_length=50, choices=COUNTRIES)
    countryDyeing = CharField(_("Country Of Dyeing"), max_length=50, choices=COUNTRIES)
    countryMaking = CharField(
        _("Country Of Manufacture"), max_length=50, choices=COUNTRIES
    )
    fabricProcess = ForeignKey(
        Process, CASCADE, verbose_name=_("Fabric Process"), null=True
    )

    def __str__(self):
        return self.name

    @classmethod
    def _fromJSON(cls, example):
        """takes a json of an example, return an instance of Example"""
        # all fields except some
        e = Example(
            **delkey(
                "materials",  # handled by add_material
                delkey(
                    "category",  # computed from product
                    delkey(
                        "fabricProcess",  # added below
                        delkey(
                            "product",  # added below
                            flatten("query", deepcopy(example)),
                        ),
                    ),
                ),
            )
        )
        e.product = Product.objects.get(pk=example["query"]["product"])
        e.fabricProcess = Process.objects.get(alias=example["query"]["fabricProcess"])
        return e

    def add_material(self, share):
        """Add a Material to the example"""
        Share.objects.create(
            material=Material.objects.get(pk=share["id"]),
            share=share["share"],
            example=self,
        )

    @classmethod
    def allToJSON(cls):
        examples = (
            cls.objects.all()
            .prefetch_related("materials")
            .select_related("product", "fabricProcess")
        )
        output = []
        for example in examples:
            materials_data = []
            for material in example.materials.all():
                share_relation = (
                    example.share_set.get(material=material)
                    if example.share_set.filter(material=material).exists()
                    else None
                )
                materials_data.append(
                    {
                        "id": material.id,
                        "share": share_relation.share if share_relation else None,
                    }
                )
            query_data = {
                "mass": example.mass,
                "materials": materials_data,
                "product": example.product_id if example.product else None,
                "countrySpinning": example.countrySpinning,
                "countryFabric": example.countryFabric,
                "countryDyeing": example.countryDyeing,
                "countryMaking": example.countryMaking,
                "fabricProcess": example.fabricProcess_id
                if example.fabricProcess
                else None,
                "business": example.business,
                "marketingDuration": example.marketingDuration,
                "numberOfReferences": example.numberOfReferences,
                "price": example.price,
                "traceability": example.traceability,
            }
            if example.repairCost is not None:
                query_data["repairCost"] = example.repairCost

            output.append(
                {
                    "id": example.id,
                    "name": example.name,
                    "category": example.category,
                    "query": query_data,
                }
            )
        return json.dumps(output)


class Share(Model):
    """m2m relation of Example with an extra field"""

    class Meta:
        verbose_name_plural = _("Materials")

    example = ForeignKey(Example, CASCADE)
    material = ForeignKey(Material, CASCADE)
    share = FloatField()
