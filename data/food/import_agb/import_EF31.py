#!/usr/bin/env python

from bw2io.importers.simapro_lcia_csv import SimaProLCIACSVImporter
from bw2io import bw2setup
from functools import partial
from bw2io.strategies import link_iterable_by_fields
from bw2data import Database

EF31 = "181-EF3.1_unofficial_interim_for_AGRIBALYSE_WithSubImpactsEcotox_v20.csv"

bw2setup()
bio = Database("agribalyse3.1 biosphere")
ef_importer = SimaProLCIACSVImporter(EF31, biosphere="agribalyse3.1 biosphere")
ef_importer.apply_strategies()
agbio = Database("agribalyse3.1 biosphere")
agbio.delete_duplicate_exchanges()
agb = Database("agribalyse3.1")
# agb.delete_duplicate_exchanges()

# [{'filename': '(missing)',
#  'name': 'Methane, monochloro-, R-40',
#  'unit': 'kilogram'},
# {'filename': '(missing)',
#  'name': 'Methane, monochloro-, R-40',
#  'unit': 'kilogram'}]


ef_importer.apply_strategy(
    partial(
        link_iterable_by_fields,
        other=bio,
        fields=["name", "unit"],
    )
)
# print("Adding missing CFs...")
# ef_importer.add_missing_cfs()
# for ds in ef_importer.data:
#    for ex in ds["exchanges"]:
#        ex.update({"input": ["biosphere3"]})

ef_importer.statistics()
# ef_importer.write_unlinked("AGB311")
# print("Writing methods...")
ef_importer.write_methods()
