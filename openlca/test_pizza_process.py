import olca
import pandas as pd

client = olca.Client(8080)

# test with process "pizza, ham and cheese"
pizza_uuid = "895b79bc-fbef-3296-ab43-807fda09e300"
elec_fr_uuid = "33e73a05-ceb0-4e48-a680-b7e026f11222"

# create product system
product_system = client.create_product_system(
    elec_fr_uuid, default_providers="prefer", preferred_type="UNIT_PROCESSES"
)

ef = "Environmental Footprint (Mid-point indicator)"
ef3 = "EF 3.0 Method"

# setup calculation
setup = olca.CalculationSetup(
    calculation_type=olca.CalculationType.SIMPLE_CALCULATION,
    impact_method=client.find(olca.ImpactMethod, ef),
    product_system=product_system,
    allocation_method=olca.AllocationType.PHYSICAL_ALLOCATION,
)


calc_result = client.calculate(setup)

# print results
for impact_result in calc_result.impact_results:
    print(
        f"{impact_result.impact_category.name} : {impact_result.value},{impact_result.impact_category.ref_unit} "
    )

client.dispose(calc_result)
