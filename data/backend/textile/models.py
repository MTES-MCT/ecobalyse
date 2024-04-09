from django.db import models
import json
from .choices import (
    BUSINESSES,
    CATEGORIES,
    COUNTRIES,
    DYEINGMEDIA,
    FABRICS,
    MAXKINGCOMPLEXITIES,
    ORIGINS,
    STEPUSAGES,
    UNITS,
)

# textile


class Process(models.Model):
    search = models.CharField(max_length=200, blank=True)
    name = models.CharField(max_length=200)
    source = models.CharField(max_length=200)
    info = models.CharField(max_length=200)
    unit = models.CharField(max_length=50, choices=UNITS)
    uuid = models.CharField(max_length=50, primary_key=True)
    acd = models.FloatField()
    cch = models.FloatField()
    etf = models.FloatField()
    etfc = models.FloatField()
    fru = models.FloatField()
    fwe = models.FloatField()
    htc = models.FloatField()
    htcc = models.FloatField()
    htn = models.FloatField()
    htnc = models.FloatField()
    ior = models.FloatField()
    ldu = models.FloatField()
    mru = models.FloatField()
    ozd = models.FloatField()
    pco = models.FloatField()
    pma = models.FloatField()
    swe = models.FloatField()
    tre = models.FloatField()
    wtu = models.FloatField()
    pef = models.FloatField()
    ecs = models.FloatField()
    heat_MJ = models.FloatField(default=0)
    elec_pppm = models.FloatField()
    elec_MJ = models.FloatField()
    waste = models.FloatField()
    alias = models.CharField(max_length=50, null=True)
    step_usage = models.CharField(max_length=50, choices=STEPUSAGES)
    correctif = models.CharField(max_length=200)

    def __str__(self):
        return self.name

    @classmethod
    def toJson(cls):
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


class Product(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=200)
    mass = models.FloatField()
    surfaceMass = models.FloatField()
    yarnSize = models.FloatField()
    fabric = models.CharField(max_length=50, choices=FABRICS)
    # economics
    business = models.CharField(max_length=50, choices=BUSINESSES)
    marketingDuration = models.FloatField()
    numberOfReferences = models.IntegerField()
    price = models.FloatField()
    repairCost = models.FloatField()
    traceability = models.BooleanField()
    # dyeing
    defaultMedium = models.CharField(max_length=50, choices=DYEINGMEDIA)
    # making
    pcrWaste = models.FloatField()
    complexity = models.CharField(max_length=50, choices=MAXKINGCOMPLEXITIES)
    # use
    ironingProcessUuid = models.ForeignKey(
        Process, on_delete=models.SET_NULL, null=True, related_name="productsIroning"
    )
    nonIroningProcessUuid = models.ForeignKey(
        Process, on_delete=models.SET_NULL, null=True, related_name="productsNonIroning"
    )
    daysOfWear = models.IntegerField()
    defaultNbCycles = models.IntegerField()
    ratioDryer = models.FloatField()
    ratioIroning = models.FloatField()
    timeIroning = models.FloatField()
    wearsPerCycle = models.FloatField()
    # enf of life
    volume = models.FloatField()

    def __str__(self):
        return self.name

    @classmethod
    def toJson(cls):
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
                        "ironingProcessUuid": product.ironingProcessUuid,
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
                    "ironingProcessUuid", "nonIroningProcessUuid"
                ).all()
            ]
        )


class Material(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    materialProcessUuid = models.ForeignKey(
        Process, on_delete=models.SET_NULL, null=True, related_name="materials"
    )
    recycledProcessUuid = models.ForeignKey(
        Process, on_delete=models.SET_NULL, null=True, related_name="recycledMaterials"
    )
    recycledFrom = models.ForeignKey(
        "self", null=True, on_delete=models.SET_NULL, blank=True
    )
    name = models.CharField(max_length=200)
    shortName = models.CharField(max_length=50)
    origin = models.CharField(max_length=50, choices=ORIGINS)
    geographicOrigin = models.CharField(max_length=200)
    defaultCountry = models.CharField(max_length=3, choices=COUNTRIES)
    priority = models.IntegerField()
    # cff
    manufacturerAllocation = models.FloatField(null=True, blank=True)
    recycledQualityRatio = models.FloatField(null=True, blank=True)

    def __str__(self):
        return self.name

    @classmethod
    def toJson(cls):
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


class Example(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=200)
    category = models.CharField(max_length=50, choices=CATEGORIES)
    mass = models.FloatField()
    materials = models.ManyToManyField(
        Material, through="Share", related_name="examples"
    )
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True)
    # fields of products (?)
    business = models.CharField(max_length=50, choices=BUSINESSES)
    marketingDuration = models.FloatField(null=True)
    numberOfReferences = models.IntegerField(null=True)
    price = models.FloatField(null=True)
    repairCost = models.FloatField(null=True, blank=True)
    traceability = models.BooleanField(null=True)
    airTransportRatio = models.FloatField(null=True)

    countrySpinning = models.CharField(max_length=50, choices=COUNTRIES)
    countryFabric = models.CharField(max_length=50, choices=COUNTRIES)
    countryDyeing = models.CharField(max_length=50, choices=COUNTRIES)
    countryMaking = models.CharField(max_length=50, choices=COUNTRIES)
    fabricProcess = models.ForeignKey(Process, on_delete=models.CASCADE, null=True)

    def __str__(self):
        return self.name

    @classmethod
    def toJson(cls):
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


class Share(models.Model):
    """m2m relation of Example with an extra field"""

    example = models.ForeignKey(Example, on_delete=models.CASCADE)
    material = models.ForeignKey(Material, on_delete=models.CASCADE)
    share = models.FloatField()
