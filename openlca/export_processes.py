import olca
import pandas as pd


# connect to openlca
# to connect to openlca, you need to
# 1) open openlca app
# 2) open the database you want to query
# 3) start IPC server : Tools > Developer Tools > IPC Server

client = olca.Client(8080)

# select processes you want to export
search_string = "Electricity grid mix 1kV-60kV, consumption mix, to consumer, AC, technology mix, 1kV - 60kV"


# get all processes in a df
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
    list(
        zip(
            loc_list,
            process_list,
            id_list,
            des_list,
        )
    ),
    columns=["loc", "name", "id", "desc"],
)

# search for processes

search_df = processes_df[processes_df["name"].str.contains(search_string)]

search_df.reset_index(drop=True, inplace=True)

output_df = search_df.copy()

# iterate on found processes to export impacts in a csv
for i, row in search_df.iterrows():

    # create product system
    product_system = client.create_product_system(
        row["id"], default_providers="prefer", preferred_type="UNIT_PROCESSES"
    )

    # setup calculation with parameters
    setup = olca.CalculationSetup(
        calculation_type=olca.CalculationType.SIMPLE_CALCULATION,
        impact_method=client.find(
            olca.ImpactMethod, "Environmental Footprint (Mid-point indicator)"
        ),
        product_system=product_system,
        allocation_method=olca.AllocationType.PHYSICAL_ALLOCATION,
    )

    calc_result = client.calculate(setup)
    # print results in a df
    for impact_result in calc_result.impact_results:
        output_df.at[i, impact_result.impact_category.name] = impact_result.value
        output_df.at[
            i, str(impact_result.impact_category.name + "_unit")
        ] = impact_result.impact_category.ref_unit

    client.dispose(calc_result)

output_df.to_csv("processes_impact.csv")
