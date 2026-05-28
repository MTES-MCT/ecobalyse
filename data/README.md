# ecobalyse-data

Produce the input data required to make the [Ecobalyse](https://github.com/MTES-MCT/ecobalyse) application work. It uses LCA softwares (Brightway and Simapro) to get LCIA data from multiple databases (Ecoinvent, WFLDB, Agribalyse, …) and to produce JSON files required for [Ecobalyse](https://github.com/MTES-MCT/ecobalyse) to work.

## Pre-requisites

- [Just](https://github.com/casey/just) to run project commands (at least v1.28)
- [uv](https://docs.astral.sh/uv/) to manage Python installs

## Configuration

### Environment variables

[Dynaconf](https://www.dynaconf.com/) is used to manage the configuration. Every
variable in `settings.toml` can be overridden by setting an environment variable
of the same name, prefixed with `EB_`.
The simplest way to do that is to copy the `.env.sample` file as `.env`, and to
edit it as needed.

The following two variables are not managed by Dynaconf, so it’s not enough to put
them in your .env file; you’ll have to make sure that they are actually exported
to your shell:

- If you want to use the Python scripts directly without using `just` you’ll also
have to add the current directory to your python PATH (`export PYTHONPATH=.`)

- By default, Brightway stores data in `~/.local/share/Brightway3/`. It is highly
  recommended to setup the environment variable `BRIGHTWAY2_DIR` in order to chose
  the path where you want the data kept. Note that the directory needs to exist.

## Description of the process

### Importing LCA databases

The first step after installation is to import LCA databases into Brightway
with:

    just import-all

All these files are SimaPro-specific CSV files: Agribalyse provided by ADEME,
Ecoinvent exported from SimaPro, other databases provided by third parties,
and the LCIA method `EF 3.1`.
They will automatically be downloaded to the `EB_DB_CACHE_DIR` folder.

See the `[default.dbfiles]` section in [[settings.toml]] to check the exact
versions being used.

Each file lands in a different Brightway CLA database:

- Agribalyse 3.2
- PastoEco
- Ginko
- CTCPA
- WFLDB
- Ecoinvent 3.9.1
- Woolmark

And `EF 3.1` lands besides other methods of Brightway as:

- Environmental Footprint 3.1 (adapted) patch wtu

### Adding custom processes

Additional LCA processes can be added by defining what you want in a specific
JSON file called `activities_to_create.json` at the root of the repository.
This file currently supports two ways of creating a process: either
`from_scratch` or `from_existing`. All the new processes end-up in another
database called `Ecobalyse`.

The process creation takes place at the end of the import process and is
replayed each time. This mean you can modify the file and relaunch the import
process seceral times and check the result quickly.

#### Creating an LCI process from scratch

The JSON fields are self-explanatory. Here is an example of creating organic
cow milk, with the alias `cow-milk-organic-national-average` (a human-readable
identifier for the process)

```
 {
    "activityCreationType": "from_scratch",
    "alias": "cow-milk-organic-national-average",
    "comment": "",
    "database": "Agribalyse 3.2",
    "exchanges": [
      {
        "activity": {
          "activityName": "Cow milk, organic, system number 1, at farm gate {FR} U"
        },
        "amount": 0.2
      },
      {
        "activity": {
          "activityName": "Cow milk, organic, system number 2, at farm gate {FR} U"
        },
        "amount": 0.2
      },
      {
        "activity": {
          "activityName": "Cow milk, organic, system number 3, at farm gate {FR} U"
        },
        "amount": 0.2
      },
      {
        "activity": {
          "activityName": "Cow milk, organic, system number 4, at farm gate {FR} U"
        },
        "amount": 0.2
      },
      {
        "activity": {
          "activityName": "Cow milk, organic, system number 5, at farm gate {FR} U"
        },
        "amount": 0.2
      }
    ],
    "id": "2bf307e8-8cb0-400b-a4f1-cf615d9e96f4",
    "location": "FR",
    "newName": "Cow milk, organic, national average, at farm gate FR U"
 }
```

#### Creating an LCI from an existing one

Below we create a modified beef meat process by replacing the conventional beef cattle with grass-fed cattle from a pastoral
farming system. As this LCI isn't in the existingActivity's database ("Agribalyse 3.2") but in "PastoEco",
we have to explicit "PastoEco" in the replacementPlan. By following the upstream path of the meat through the supply chain (slaughtering,
processing) and replacing conventional cattle with grass-fed cattle, this LCI will give us the impact of grass-fed meat. LCIs are like
giant trees where we can replace a process at any level.

```
 {
    "activityCreationType": "from_existing",
    "alias": "meat-with-bone-beef-direct-consumption-grass-fed",
    "comment": "",
    "database": "Agribalyse 3.2",
    "existingActivity": {
      "activityName": "Meat with bone, beef, for direct consumption {FR} U"
    },
    "newName": "Meat with bone, beef for direct consumption {{meat-with-bone-beef-direct-consumption-grass-fed}}",
    "replacementPlan": {
      "replace": [
        {
          "from": {
            "activityName": "Beef cattle, conventional, national average, at farm gate {FR} U"
          },
          "to": {
            "activityName": "Cull cow, conventional, highland milk system, pastoral farming system, at farm gate {FR} U",
            "database": "PastoEco"
          }
        }
      ],
      "upstreamPath": [
        {
          "activityName": "Slaughtering and chilling, of beef, industrial production, French production mix, 1 kg of beef quarter {FR} U"
        },
        {
          "activityName": "Slaughtering and chilling, of beef, industrial production, French production mix, at plant, 1 kg of beef carcass {FR} U"
        },
        {
          "activityName": "Live beef, for direct consumption, consumption mix {FR} U"
        }
      ]
    }
  },
```

### Selecting what you want in Ecobalyse
The next configuration files, stored in the `lci_catalog` folder allow to select what we
want in Ecobalyse:

- the list of processes to be exported from Brightway
- the list of ingredients (for the food sector)
- the list of materials (for the textile sector)
- the list of `custom` processes, with hardcoded impacts (in long-term deprecation)

Note that the identifiers of the ingredients (`id`) and materials
(`material_id`) are expected to be persistent. As a summary they should only
change when the semantics of the `displayName` changes.

### ID Stability Guidelines

The identifiers (`id`) defined in `/lci_catalog/__alias__.json` become the process identifiers in the exported
`public/data/processes.json` file used by the Ecobalyse frontend.

#### When IDs should remain stable

IDs **must remain unchanged** in the following cases:

- **Superficial displayName changes**: Minor corrections to the displayName that don't alter the fundamental meaning (e.g., fixing
  typos, adjusting capitalization, or minor wording improvements).

- **Same concept but underlying LCI change** : If the concept stays the same and only the underlying LCI change, the id should remain unchanged.
Example :
  `"displayName":"Sciage + séchage au four en Europe (bois)"`
  LCI change from
  ```
  "activityName": "Sawing + kiln drying in Europe",
  "source": "Ecobalyse"
  ```
  to
  `"source": "Custom"`
  The id should stay the same

#### When IDs should change

IDs **must be changed** when there is a substantial modification to the entity:

- **Substantial displayName changes**: Changes that alter the semantic meaning
  of the entity (e.g., "Chou rouge" → "Chou vert" represents a
  different vegetable variety).

- **Unit changes**: Modifications to the reference unit (e.g., "kg" → "m³")
  fundamentally change what the process represents.

- **Other substantial changes**: Any modification that would make the process
  represent a fundamentally different product or service.

The general principle is that an ID represents a specific product or service
concept. If the concept remains the same, keep the ID. If the concept changes,
generate a new ID.

### Other configuration files

- `impacts.json`: the definition of the LCIA methods, their normalizations and
  weightings. We currently define PEF and ECS (Ecobalyse environment cost).

Note that other non-LCA-depedent JSON file are located in the `ecobalyse`
repository, such as examples of textile products, food recipes, etc.

## Export process

Then run the export process:

    just export-all

This will create:

- `processes_impacts.json` file with detailed impacts
- `processes.json` without detailed impacts
- `ingredients.json` with the list of ingredients (for food)
- `materials.json`with the list of materials (for textile)

All these files are loaded by the Ecobalyse frontend (see in
https://github.com/MTES-MCT/ecobalyse/ ) and exported both in this repository
and in a second configurable location (typically the Ecobalyse repository).

## Jupyter

You can start a `jupyter` server to explore the processes in Brightway or do other Python tasks:

    uv run jupyter lab

The password is empty by default.

### Brightway explorer

In a Jupyter notebook, enter `import notebooks.explore` and then validate with `shift-Enter`.

### Ingredients editor (in deprecation)

In a Jupyter notebook, enter `import notebooks.ingredients` and then validate with `shift-Enter`.
