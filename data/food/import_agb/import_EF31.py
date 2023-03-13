#!/usr/bin/env python

from bw2io.importers.simapro_lcia_csv import SimaProLCIACSVImporter

EF31 = "181-EF3.1_unofficial_interim_for_AGRIBALYSE_WithSubImpactsEcotox_v20.csv"

ef_importer = SimaProLCIACSVImporter(EF31)
