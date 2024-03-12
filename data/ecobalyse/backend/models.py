from django.db import models
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
    durationInMinutes = models.FloatField()
    # use
    ironingProcessUuid = models.CharField(max_length=50)
    nonIroningProcessUuid = models.CharField(max_length=50)
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


class Material(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    materialProcessUuid = models.CharField(max_length=50)
    recycledProcessUuid = models.CharField(max_length=50, null=True)
    recycledFrom = models.ForeignKey("self", null=True, on_delete=models.SET_NULL)
    name = models.CharField(max_length=200)
    shortName = models.CharField(max_length=50)
    origin = models.CharField(max_length=50, choices=ORIGINS)
    geographicOrigin = models.CharField(max_length=200)
    defaultCountry = models.CharField(max_length=3, choices=COUNTRIES)
    priority = models.IntegerField()
    # cff
    manufacturerAllocation = models.FloatField(null=True)
    recycledQualityRatio = models.FloatField(null=True)

    def __str__(self):
        return self.name


class Process(models.Model):
    search = models.CharField(max_length=200)
    name = models.CharField(max_length=200)
    source = models.CharField(max_length=200)
    info = models.CharField(max_length=200)
    unit = models.CharField(max_length=50, choices=UNITS)
    uuid = models.CharField(max_length=50)
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
    heat_MJ = models.FloatField()
    elec_pppm = models.FloatField()
    elec_MJ = models.FloatField()
    waste = models.FloatField()
    alias = models.CharField(max_length=50, null=True)
    step_usage = models.CharField(max_length=50, choices=STEPUSAGES)
    correctif = models.CharField(max_length=200)

    def __str__(self):
        return self.name


class Example(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=200)
    category = models.CharField(max_length=50, choices=CATEGORIES)
    mass = models.FloatField()
    materials = models.ManyToManyField(Material, through="Share")
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    countrySpinning = models.CharField(max_length=50, choices=COUNTRIES)
    countryFabric = models.CharField(max_length=50, choices=COUNTRIES)
    countryDyeing = models.CharField(max_length=50, choices=COUNTRIES)
    countryMaking = models.CharField(max_length=50, choices=COUNTRIES)
    fabricProcess = models.ForeignKey(Process, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


class Share(models.Model):
    """m2m relation of Example with an extra field"""

    exemple = models.ForeignKey(Example, on_delete=models.CASCADE)
    material = models.ForeignKey(Material, on_delete=models.CASCADE)
    share = models.FloatField()
