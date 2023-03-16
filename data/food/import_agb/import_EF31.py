#!/usr/bin/env python

from bw2io.importers.simapro_lcia_csv import SimaProLCIACSVImporter
from bw2io import bw2setup

# from functools import partial
# from bw2io.strategies import link_iterable_by_fields
import bw2data

EF31 = "181-EF3.1_unofficial_interim_for_AGRIBALYSE_WithSubImpactsEcotox_v20.csv"
PROJECT = "AGB3.1.1"
BIOSPHERE = "agribalyse3.1 biosphere"

bw2data.projects.set_current(PROJECT)
bw2setup()
ef_importer = SimaProLCIACSVImporter(EF31, biosphere=BIOSPHERE)
ef_importer.statistics()
ef_importer.write_methods()
