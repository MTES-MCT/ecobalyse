import copy
import re

from tqdm import tqdm

from . import agribalyse


# Patch for https://github.com/brightway-lca/brightway2-io/pull/283
def lower_formula_parameters(db):
    """lower formula parameters"""
    for ds in tqdm(db):
        for k in ds.get("parameters", {}).keys():
            if "formula" in ds["parameters"][k]:
                ds["parameters"][k]["formula"] = ds["parameters"][k]["formula"].lower()
    return db


def remove_azadirachtine(db):
    """Remove all exchanges with azadirachtine, except for apples"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        new_ds["exchanges"] = [
            exc
            for exc in ds["exchanges"]
            if (
                "azadirachtin" not in exc.get("name", "").lower()
                or ds.get("name", "").lower().startswith("apple")
            )
        ]
        new_db.append(new_ds)
    return new_db


def remove_negative_land_use_on_tomato(db):
    """Remove transformation flows from urban on greenhouses
    that cause negative land-use on tomatoes"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if ds.get("name", "").lower().startswith("plastic tunnel"):
            new_ds["exchanges"] = [
                exc
                for exc in ds["exchanges"]
                if not exc.get("name", "")
                .lower()
                .startswith("transformation, from urban")
            ]
        else:
            pass
        new_db.append(new_ds)
    return new_db


def fix_lentil_ldu(db):
    """Replace 'from unspecified' with 'from annual crop'
    to avoid having negative LDU on the lentils.
    Should be removed for AGB 3.2"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if ds.get("name", "").startswith("Lentil"):
            for exc in new_ds["exchanges"]:
                if exc.get("name", "").startswith("Transformation, from unspecified"):
                    exc["name"] = "Transformation, from annual crop"
        else:
            pass
        new_db.append(new_ds)
    return new_db


def remove_some_processes(db):
    """Some processes make the whole import fail
    due to inability to parse the Input and Calculated parameters"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if ds.get("simapro metadata", {}).get("Process identifier") not in (
            "EI3CQUNI000025017103662",
        ):
            new_db.append(new_ds)
    return new_db


def remove_creosote(db):
    """Remove creosote flows from flattened system trellis (AGB, WFLDB)"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        name = ds["name"].lower()
        if "treillis" in name or "trellis" in name:
            new_ds["exchanges"] = [
                exc
                for exc in ds["exchanges"]
                # this is for system trellis
                if exc.get("name", "")
                not in ("Pyrene", "Fluoranthene", "Phenanthrene", "Naphtalene")
                # this is for unit trellis
                and "creosote" not in exc.get("name", "").lower()
            ]
        new_db.append(new_ds)
    return new_db


def remove_acetamiprid(db):
    """Remove acetamiprid in FR activities"""
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if ds.get("location") == "FR":
            new_ds["exchanges"] = [
                exc for exc in ds["exchanges"] if exc.get("name", "") != "Acetamiprid"
            ]
        new_db.append(new_ds)
    return new_db


def use_unit_processes(db):
    """the woolmark dataset comes with dependent processes
    which are set as system processes.
    Ecoinvent has these processes but as unit processes.
    So we change the name so that the linking be done"""
    for ds in tqdm(db):
        for exc in ds["exchanges"]:
            if exc["name"].endswith(" | Cut-off, S"):
                exc["name"] = exc["name"].replace(" | Cut-off, S", "")
                exc["name"] = re.sub(
                    r" \{([A-Za-z]{2,3})\}\| ", r"//[\1] ", exc["name"]
                )
    return db


def uraniumFRU(db):
    """reduce the FRU of Uranium"""
    new_db = []
    for method in tqdm(db):
        new_method = copy.deepcopy(method)
        if new_method["name"][1] == "Resource use, fossils":
            for k, v in new_method.items():
                if k == "exchanges":
                    for cf in v:
                        if cf["name"].startswith("Uranium"):
                            # lower by 40%
                            cf["amount"] *= 1 - 0.4
        new_db.append(new_method)
    return new_db


def noLT(db):
    """exclude long term impacts"""
    new_db = []
    for method in tqdm(db):
        new_method = copy.deepcopy(method)
        for k, v in new_method.items():
            if k == "exchanges":
                for cf in v:
                    if any(["long-term" in cat for cat in cf["categories"]]):
                        cf["amount"] = 0
        new_db.append(new_method)
    return new_db


def extract_name_location_product(db):
    """extract the product, name and location from
    ecoinvent passing in SimaPro"""
    pattern = re.compile(
        r"^(?P<product>.+?)(?://\[(?P<cc1>[^\]]+)\]| \{(?P<cc2>[^}]+)\}\|)\s*(?P<activity>.+)$"
    )
    new_db = []
    for ds in tqdm(db):
        s = ds["name"].strip()
        m = pattern.match(s)
        if not m:
            breakpoint
            raise ValueError(f"Unexpected activity name: {s!r}")

        new_ds = copy.deepcopy(ds)
        # pick whichever group matched
        loc = m.group("cc1") or m.group("cc2")
        new_ds["location"] = loc.strip()
        new_ds["reference product"] = m.group("product").strip()
        new_db.append(new_ds)

    return new_db


def extract_simapro_metadata(db):
    new_db = []
    dqr_pattern = r"The overall DQR of this product is: (?P<overall>[\d.]+) {P: (?P<P>[\d.]+), TiR: (?P<TiR>[\d.]+), GR: (?P<GR>[\d.]+), TeR: (?P<TeR>[\d.]+)}"
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if "simapro metadata" in ds:
            for sp_field, value in ds["simapro metadata"].items():
                if value != "Unspecified":
                    new_ds[sp_field] = value

            # Getting the Data Quality Rating of the data when relevant
            if "Comment" in ds["simapro metadata"]:
                match = re.search(
                    pattern=dqr_pattern, string=ds["simapro metadata"]["Comment"]
                )

                if match:
                    new_ds["DQR"] = {
                        "overall": float(match["overall"]),
                        "P": float(match["P"]),
                        "TiR": float(match["TiR"]),
                        "GR": float(match["GR"]),
                        "TeR": float(match["TeR"]),
                    }

            del new_ds["simapro metadata"]
        new_db.append(new_ds)
    return new_db


def extract_simapro_location(db):
    new_db = []
    location_pattern = r"\{(?P<location>[\w ,\/\-\+]+)\}"
    location_pattern_2 = r"\/\ *(?P<location>[\w ,\/\-]+) U$"
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        if ds.get("location") is None:
            match = re.search(pattern=location_pattern, string=ds["name"])
            if match is not None:
                new_ds["location"] = match["location"]
            else:
                match = re.search(pattern=location_pattern_2, string=ds["name"])
                if match is not None:
                    new_ds["location"] = match["location"]
                elif ("French production," in ds["name"]) or (
                    "French production mix," in ds["name"]
                ):
                    new_ds["location"] = "FR"
                elif "CA - adapted for maple syrup" in ds["name"]:
                    new_ds["location"] = "CA"
                elif ", IT" in ds["name"]:
                    new_ds["location"] = "IT"
                elif ", TR" in ds["name"]:
                    new_ds["location"] = "TR"
                elif "/GLO" in ds["name"]:
                    new_ds["location"] = "GLO"
        new_db.append(new_ds)
    return new_db


def extract_ciqual(db):
    new_db = []
    ciqual_pattern = r"\[Ciqual code: (?P<ciqual>[\d_]+)\]"
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        # Getting products CIQUAL code when relevant
        if "ciqual" in ds["name"].lower():
            match = re.search(pattern=ciqual_pattern, string=ds["name"])
            new_ds["ciqual_code"] = match["ciqual"] if match is not None else ""
        new_db.append(new_ds)
    return new_db


def extract_tags(db):
    new_db = []
    for ds in tqdm(db):
        new_ds = copy.deepcopy(ds)
        # Getting activity tags
        name_without_spaces = ds["name"].replace(" ", "")
        for packaging in agribalyse.PACKAGINGS:
            if f"|{packaging.replace(' ', '')}|" in name_without_spaces:
                new_ds["packaging"] = packaging

        for stage in agribalyse.STAGES:
            if f"|{stage.replace(' ', '')}" in name_without_spaces:
                new_ds["stage"] = stage

        for transport_type in agribalyse.TRANSPORT_TYPES:
            if f"|{transport_type.replace(' ', '')}|" in name_without_spaces:
                new_ds["transport_type"] = transport_type

        for preparation_mode in agribalyse.PREPARATION_MODES:
            if f"|{preparation_mode.replace(' ', '')}|" in name_without_spaces:
                new_ds["preparation_mode"] = preparation_mode

        if "simapro name" in ds:
            del new_ds["simapro name"]

        if "filename" in ds:
            del new_ds["filename"]
        new_db.append(new_ds)
    return new_db
