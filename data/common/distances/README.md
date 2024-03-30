This folder outputs the `public/data/transports.json`.
It calculates the distances between countries using various modes of transport, including road, sea, and air. It utilizes a series of Python scripts to facilitate the querying and processing of distance information between countries.

The main script `transports.py` that exports the necessary countryDistances data `transports.json` using the raw data `distances_raw.json`.

`distances_raw.json` is generated with `query_distance_api.py`that queries an external API to fetch distance data
