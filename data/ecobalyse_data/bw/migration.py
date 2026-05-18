GINKO_MIGRATIONS = [
    {
        "name": "diesel-fix",
        "description": "Fix Diesel process name",
        "data": {
            "fields": ("name",),
            "data": [
                (
                    (
                        "Diesel {GLO}| market group for | Cut-off, S - Copied from ecoinvent",
                    ),
                    {
                        "name": "Diesel {GLO}| market group for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Combine harvesting {Canada without Quebec}| combine harvesting | Cut-off, U",
                    ),
                    {
                        "name": "Combine harvesting {Canada without Quebec}| combine harvesting | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Fertilising, by broadcaster {Canada without Quebec}| fertilising, by broadcaster | Cut-off, U",
                    ),
                    {
                        "name": "Fertilising, by broadcaster {Canada without Quebec}| fertilising, by broadcaster | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Land use change, annual crop {CA}| market for land use change, annual crop | Cut-off, U",
                    ),
                    {
                        "name": "Land use change, annual crop {CA}| market for land use change, annual crop | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    ("Peat moss {GLO}| market for peat moss | Cut-off, U",),
                    {
                        "name": "Peat moss {GLO}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    ("Sowing {Canada without Quebec}| sowing | Cut-off, U",),
                    {
                        "name": "Sowing {Canada without Quebec}| sowing | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Swath, by rotary windrower {Canada without Quebec}| swath, by rotary windrower | Cut-off, U",
                    ),
                    {
                        "name": "Swath, by rotary windrower {Canada without Quebec}| swath, by rotary windrower | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tillage, cultivating, chiselling {Canada without Quebec}| tillage, cultivating, chiselling | Cut-off, U",
                    ),
                    {
                        "name": "Tillage, cultivating, chiselling {Canada without Quebec}| tillage, cultivating, chiselling | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tillage, harrowing, by offset disc harrow {CA}| tillage, harrowing, by offset disc harrow | Cut-off, U",
                    ),
                    {
                        "name": "Tillage, harrowing, by offset disc harrow {CA}| tillage, harrowing, by offset disc harrow | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tillage, harrowing, by rotary harrow {CA}| tillage, harrowing, by rotary harrow | Cut-off, U",
                    ),
                    {
                        "name": "Tillage, harrowing, by rotary harrow {CA}| tillage, harrowing, by rotary harrow | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tillage, rolling {Canada without Quebec}| tillage, rolling | Cut-off, U",
                    ),
                    {
                        "name": "Tillage, rolling {Canada without Quebec}| tillage, rolling | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tillage, rotary cultivator {Canada without Quebec}| tillage, rotary cultivator | Cut-off, U",
                    ),
                    {
                        "name": "Tillage, rotary cultivator {Canada without Quebec}| tillage, rotary cultivator | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Application of plant protection product, by field sprayer {Canada without Quebec}| application of plant protection product, by field sprayer | Cut-off, U",
                    ),
                    {
                        "name": "Application of plant protection product, by field sprayer {Canada without Quebec}| application of plant protection product, by field sprayer | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    ("Zinc {GLO}| market for zinc | Cut-off, U",),
                    {
                        "name": "Zinc {GLO}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Transport, freight train {GLO}| market group for transport, freight train | Cut-off, U",
                    ),
                    {
                        "name": "Transport, freight train {GLO}| market group for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Transport, freight, inland waterways, barge {GLO}| market group for transport, freight, inland waterways, barge | Cut-off, U",
                    ),
                    {
                        "name": "Transport, freight, inland waterways, barge {GLO}| market group for transport, freight, inland waterways, barge | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Transport, freight, lorry, unspecified {GLO}| market group for transport, freight, lorry, unspecified | Cut-off, U",
                    ),
                    {
                        "name": "Transport, freight, lorry, unspecified {GLO}| market group for transport, freight, lorry, unspecified | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Transport, freight, sea, bulk carrier for dry goods {GLO}| market for transport, freight, sea, bulk carrier for dry goods | Cut-off, U",
                    ),
                    {
                        "name": "Transport, freight, sea, bulk carrier for dry goods {GLO}| market for transport, freight, sea, bulk carrier for dry goods | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
            ],
        },
    }
]
# migrations necessary to link some remaining unlinked technosphere activities
AGRIBALYSE_MIGRATIONS = [
    {
        "name": "agb-technosphere-fixes",
        "description": "Specific technosphere fixes for Agribalyse 3",
        "data": {
            "fields": ["name", "unit"],
            "data": [
                (
                    (
                        "Wastewater, average {Europe without Switzerland}| market for wastewater, average | Cut-off, S - Copied from Ecoinvent U",
                        "l",
                    ),
                    {"unit": "m3", "multiplier": 1e-3},
                ),
                (
                    (
                        "Wastewater, from residence {RoW}| market for wastewater, from residence | Cut-off, S - Copied from Ecoinvent U",
                        "l",
                    ),
                    {"unit": "m3", "multiplier": 1e-3},
                ),
                (
                    (
                        "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {Europe without Switzerland}| heat production, natural gas, at industrial furnace >100kW | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RER}| market group for | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RoW}| market for heat, district or industrial, natural gas | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Land use change, perennial crop {BR}| market group for land use change, perennial crop | Cut-off, S - Copied from Ecoinvent U",
                        "m2",
                    ),
                    {"unit": "ha", "multiplier": 1e-4},
                ),
            ]
            + sum(
                [
                    [
                        [
                            (f"Water, river, {country}", "l"),
                            {"unit": "cubic meter", "multiplier": 0.001},
                        ],
                        [
                            (f"Water, well, {country}", "l"),
                            {"unit": "cubic meter", "multiplier": 0.001},
                        ],
                    ]
                    # only ES for AGB, all for Ginko
                    for country in ["ES", "ID", "CO", "CR", "EC", "IN", "BR", "US"]
                ],
                [],
            ),
        },
    }
]

PASTOECO_MIGRATIONS = [
    {
        "name": "pastoeco-technosphere-fixes",
        "description": "Fixes to ease linking to agb",
        "data": {
            "fields": ("name",),
            "data": [
                (
                    ("Diesel {Europe without Switzerland}| market for | Cut-off, S",),
                    {
                        "name": "Diesel {Europe without Switzerland}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    ("Petrol, two-stroke blend {GLO}| market for | Cut-off, S",),
                    {
                        "name": "Petrol, two-stroke blend {GLO}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Tap water {Europe without Switzerland}| market for | Cut-off, S",
                    ),
                    {
                        "name": "Tap water {Europe without Switzerland}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    ("Electricity, low voltage {FR}| market for | Cut-off, S",),
                    {
                        "name": "Electricity, low voltage {FR}| market for | Cut-off, S - Copied from Ecoinvent U"
                    },
                ),
                (
                    (
                        "Newborn dairy calf, Conventional, Alsace, at farm gate, FR - MEANS#16615 U",
                    ),
                    {
                        "name": "Newborn dairy calf, Conventional, Alsace, at farm gate - MEANS#16615, FR"
                    },
                ),
            ],
        },
    }
]
WOOLMARK_MIGRATIONS = [
    {
        "name": "woolmark-units-fixes",
        "description": "Fix units",
        "data": {
            "fields": ("unit",),
            "data": [
                (
                    ("t",),
                    {"unit": "kg", "multiplier": 1000},
                ),
                (
                    ("l",),
                    {"unit": "m3", "multiplier": 0.001},
                ),
            ],
        },
    },
    {
        "name": "woolmark-technosphere",
        "description": "Process names for EI 3.9",
        "data": {
            "fields": ("name",),
            "data": [
                (
                    (
                        "Sodium bicarbonate {RoW}| market for sodium bicarbonate | Cut-off, S",
                    ),
                    {"name": "sodium bicarbonate//[GLO] market for sodium bicarbonate"},
                ),
                (
                    ("Wheat grain {AU}| market group for wheat grain | Cut-off, S",),
                    {"name": "wheat grain//[AU] wheat production"},
                ),
            ],
        },
    },
    {
        "name": "woolmark-locations",
        "description": "Remove locations to ease linking to Ecoinvent",
        "data": {
            "fields": ("location",),
            "data": [
                (("(unknown)",), {"location": None}),
            ],
        },
    },
    {
        # all commented migrations related to substances that don't exist in bw biosphere3
        # but that exist in provided EF3.1. So their substances are added anyway
        "name": "woolmark-biosphere-fixes",
        "description": "Fix substances to match biosphere3",
        "data": {
            "fields": ("name", "categories"),
            "data": [
                (
                    ("Water, fresh, AU", ("Resources", "in water")),
                    {
                        "name": "Water, river, AU",
                        "categories": ("natural resource", "in water"),
                    },
                ),
                (
                    ("Sulfate", ("Emissions to soil", "agricultural")),
                    {"categories": ("soil",)},
                ),
                (
                    ("Nitrate", ("Emissions to soil", "agricultural")),
                    {"categories": ("soil",)},
                ),
            ],
        },
    },
]
