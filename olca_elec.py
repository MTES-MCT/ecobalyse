import olca
import pandas as pd

client = olca.Client(8080)

result = client.find(
    olca.Process,
    "Electricity grid mix 1kV-60kV, consumption mix, to consumer, AC, technology mix, 1kV - 60kV",
)
print(result)

process_descriptor = client.get_descriptors(olca.Process)

process_list = []
id_list = []
des_list = []
loc_list = []

for process in process_descriptor:
    process_list.append(process.name)
    id_list.append(process.id)
    des_list.append(process.description)
    loc_list.append(process.location)


processes_df = pd.DataFrame(
    list(zip(process_list, id_list, des_list, loc_list)),
    columns=["name", "id", "desc", "loc"],
)

search_df = processes_df[
    processes_df["name"].str.contains(
        r"Electricity grid mix 1kV-60kV, consumption mix, to consumer, AC, technology mix, 1kV - 60kV"
    )
]

search_df.reset_index(drop=True, inplace=True)
print(search_df["name"])

output_df = search_df.copy()
for i, row in search_df.iterrows():

    # create product system
    product_system = client.create_product_system(
        row["id"], default_providers="prefer", preferred_type="UNIT_PROCESSES"
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
        output_df.at[i, impact_result.impact_category.name] = impact_result.value
        output_df.at[
            i, str(impact_result.impact_category.name + "_unit")
        ] = impact_result.impact_category.ref_unit

    client.dispose(calc_result)

output_df.to_csv("output.csv")
