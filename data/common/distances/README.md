# Country distances

This folder computes road / sea / air distances between countries and exports
`public/data/transports.json`

## Pipeline

```
compute_distances.py ───────► distances_raw.json   { from: { to: {road, sea, air} } }
       │ (country centroid)
       ▼
transports.py (+ CountryDistances.py) ──► public/data/transports.json
```

### 1. `compute_distances.py` -> `distances_raw.json`
Each country is represented by its centroid (`CountryInfo(code).latlng()`). For every pair
of countries (derived from `countries.json` via `country_set`), computes three
distances (km):
- **air**: geodesic distance * AIR_CIRCUITY_FACTOR (1.05)
- **sea**: via python package `searoute`
- **road**: If two countries are road connected : geodesic distance * ROAD_CIRCUITY_FACTOR (1.21) else `null`

### 2. `transports.py` (+ `CountryDistances.py`) -> `transports.json`
Reads `distances_raw.json`, adds self-distances, maps region codes to proxy
countries (`REE`-> `CZ`, `RAF`->ET, `ROC`->AU, `ROF`->MQ, …), removes the placeholder
proxies, validates against the official country list, and writes
`public/data/transports.json`.

## Regenerating

```bash
cd data
uv run common/distances/compute_distances.py          # road/sea/air -> distances_raw.json
just export-transports   # -> transports.json
```

The single source of truth for the country set is `public/data/countries.json`
(region codes mapped to a proxy country in `country_set.py`).
