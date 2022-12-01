import olca


"""
STRANGE : After testing with multiple parameters combination, we can't reproduce with this script the impact result we get manually for cheese ham pizza
"""

# connect to openlca
# to connect to openlca, you need to
# 1) open openlca app
# 2) open the database you want to query
# 3) start IPC server : Tools > Developer Tools > IPC Server

client = olca.Client(8080)

# test with process "pizza, ham and cheese in agribalyse"
pizza_uuid = "895b79bc-fbef-3296-ab43-807fda09e300"

# create product system
product_system = client.create_product_system(
    pizza_uuid, default_providers="prefer", preferred_type="UNIT_PROCESSES"
)

ef = "Environmental Footprint (Mid-point indicator)"
ef3 = "EF 3.0 Method"

# setup calculation

aloc_method = olca.AllocationType.NO_ALLOCATION

setup = olca.CalculationSetup(
    calculation_type=olca.CalculationType.SIMPLE_CALCULATION,
    impact_method=client.find(olca.ImpactMethod, ef3),
    product_system=product_system,
    allocation_method=olca.AllocationType.USE_DEFAULT_ALLOCATION,
)


calc_result = client.calculate(setup)

# print results
for impact_result in calc_result.impact_results:
    if impact_result.impact_category.name == "Climate change":
        print(
            f"{impact_result.impact_category.name} : {impact_result.value},{impact_result.impact_category.ref_unit} "
        )

client.dispose(calc_result)

# returns a climate change impact of 3.11 kgCO2e but when doing it manually in openLCA we get 2.46 kgCO2e
