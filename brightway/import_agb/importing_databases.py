import brightway2 as bw

from custom_import_migrations import (
    wfldb_technosphere_migration_data,
    agb_technosphere_migration_data,
)


def main():
    bw.projects.set_current("EF calculation")
    bw.bw2setup()

    """  # Ecoinvent
        # del bw.databases['ecoinvent 3.8_cutoff']
        if "ecoinvent 3.8_cutoff" in bw.databases:
            print("Database has already been imported.")
        else:
            fp_ei38cutoff = r"../databases/ecoinvent 3.8_cutoff_ecoSpold02/datasets"
            ei35cut = bw.SingleOutputEcospold2Importer(
                fp_ei38cutoff, "ecoinvent 3.8_cutoff", use_mp=False
            )
            ei35cut.apply_strategies()
            ei35cut.statistics()
            ei35cut.write_database()

        if "ecoinvent 3.8_conseq" in bw.databases:
            print("Database has already been imported.")
        else:
            fp_ei38cutoff = r"../databases/ecoinvent 3.8_consequential_ecoSpold02/datasets"
            ei35cut = bw.SingleOutputEcospold2Importer(
                fp_ei38cutoff, "ecoinvent 3.8_conseq", use_mp=False
            )
            ei35cut.apply_strategies()
            ei35cut.statistics()
            ei35cut.write_database()
    """
    # Agribalyse
    # del bw.databases['agribalyse3']
    if "agribalyse3" in bw.databases:
        print("Database has already been imported.")
    else:
        agb_csv_filepath = r"./agribalyse3_no_param.CSV"

        agb_importer = bw.SimaProCSVImporter(agb_csv_filepath, "agribalyse3")

        agb_technosphere_migration = bw.Migration("agb-technosphere")
        agb_technosphere_migration.write(
            agb_technosphere_migration_data,
            description="Specific technosphere fixes for Agribalyse 3",
        )

        agb_importer.apply_strategies()
        agb_importer.statistics()
        agb_importer.migrate("agb-technosphere")
        """ agb_importer.match_database(
            "ecoinvent 3.8_cutoff",
            fields=("reference product", "location", "unit", "name"),
        ) """
        agb_importer.apply_strategies()
        agb_importer.statistics()

        # The only remaining unlinked exchanges are final waste flows and a land use change process. We will consider
        # that they can be ignored.

        agb_importer.add_unlinked_flows_to_biosphere_database()
        agb_importer.add_unlinked_activities()
        agb_importer.statistics()
        agb_importer.write_database()

    """ # WFLDB
    # del bw.databases['WFLDB']
    if "WFLDB" in bw.databases:
        print("Database has already been imported.")
    else:
        wfldb_csv_filepath = r"../databases/WFLDB_no_param.CSV"

        wfldb_importer = bw.SimaProCSVImporter(wfldb_csv_filepath, "WFLDB")

        wfldb_technosphere_migration = bw.Migration("wfldb-technosphere")
        wfldb_technosphere_migration.write(
            wfldb_technosphere_migration_data,
            description="Specific technosphere fixes for World Food DB",
        )

        wfldb_importer.apply_strategies()
        wfldb_importer.statistics()
        wfldb_importer.migrate("wfldb-technosphere")
        wfldb_importer.apply_strategies()
        wfldb_importer.statistics()

        # The only unlinked process is Wastewater, average {CH}| treatment of, capacity 5E9l/year | Cut-off, S - Copied from ecoinvent
        # But it is only used by an orphan process, so it is considered ok to ignore it.

        wfldb_importer.add_unlinked_activities()
        wfldb_importer.add_unlinked_flows_to_biosphere_database()
        wfldb_importer.statistics()
        wfldb_importer.write_database() """


if __name__ == "__main__":
    main()
