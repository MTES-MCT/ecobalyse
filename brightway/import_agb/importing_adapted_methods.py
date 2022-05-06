import brightway2 as bw


def main():
    bw.projects.set_current("test")
    bw.bw2setup()

    methods_csv_filepath = r"../EF_adapted.CSV"

    print("Importing the adapted methods in the brightway database...")
    importer = bw.SimaProLCIACSVImporter(methods_csv_filepath, "agribalyse3")
    # importer.apply_strategies()
    # importer.statistics()
    importer.write_methods()


if __name__ == "__main__":
    main()
