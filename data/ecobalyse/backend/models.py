from django.db import models

# textile

fabrics = {
    "weaving": "Tissage",
    "knitting-straight": "Tricotage Rectiligne",
    "knitting-circular": "Tricotage Circulaire",
    "knitting-integral": "Tricotage Intégral / Whole garment",
    "knitting-fully-fashioned": "Tricotage Fully fashioned / Seamless",
    "knitting-mix": "Tricotage moyen (par défaut)",
}
businesses = {
    "small-business": "PME/TPE",
    "large-business-with-services": "Grande entreprise proposant un service de réparation et de garantie",
    "large-business-without-services": "Grande entreprise ne proposant pas de service de réparation ou de garantie",
}
dyeingMediums = {"article": "Article", "fabric": "Tissu", "yarn": "Fil"}
makingComplexities = {
    "very-high": "Très élevée",
    "high": "Élevée",
    "medium": "Moyenne",
    "low": "Faible",
    "very-low": "Très faible",
    "not-applicable": "Non applicable",
}


class Product(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    name = models.CharField(max_length=50)
    mass = models.FloatField()
    surfaceMass = models.FloatField()
    yarnSize = models.FloatField()
    fabric = models.CharField(max_length=50, choices=fabrics)
    # economics
    business = models.CharField(max_length=50, choices=businesses)
    marketingDuration = models.FloatField()
    numberOfReferences = models.IntegerField()
    price = models.FloatField()
    repairCost = models.FloatField()
    traceability = models.BooleanField()
    # dyeing
    defaultMedium = models.CharField(max_length=50, choices=dyeingMediums)
    # making
    pcrWaste = models.FloatField()
    complexity = models.CharField(max_length=50, choices=makingComplexities)
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
