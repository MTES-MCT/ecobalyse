class CountryDistances:
    def __init__(self, distances):
        self.distances = self._convert_distances(distances)
        self._all_countries = set()
        self._update_all_countries()

    self_distance = {
        "road": 500,
        "sea": None,
        "air": 500,
    }

    def _convert_distances(self, distances):
        """
        Converts the nested country distance dictionary into a flat dictionary with alphabetical keys.
        """
        flat_distances = {}
        for countryA, destinations in distances.items():
            for countryB, distance in destinations.items():
                key = "|".join(sorted([countryA, countryB]))
                flat_distances[key] = distance
        return flat_distances

    def _update_all_countries(self):
        """
        Returns a set of all countries for which distances are defined.
        """
        countries = set()
        for key in self.distances.keys():
            countries.update(key.split("|"))
        self._all_countries = countries

    def get(self, countryA, countryB):
        """
        Returns the distance between two countries.
        """
        key = "|".join(sorted([countryA, countryB]))
        return self.distances.get(key, None)

    def validate(self):
        """
        Validates that each country has a distance defined for all other countries in the dataset.
        Returns True if validation passes, otherwise raises a ValueError with details.
        """
        countries = self._all_countries

        missing_pairs = set()
        for countryA in countries:
            for countryB in countries:
                key = "|".join(sorted([countryA, countryB]))
                if key not in self.distances:
                    missing_pairs.add(key)

        if missing_pairs:
            raise ValueError(f"Missing distances for country pairs: {missing_pairs}")
        return True

    def extract_distances_for_country(self, country):
        """
        Extracts and returns a dictionary of distances involving the specified country.
        """
        country_distances = {}
        for key, distance in self.distances.items():
            if country in key:
                # Extract the other country's name and map the distance
                other_country = key.replace(country, "").replace("|", "")
                if other_country:
                    country_distances[other_country] = distance
        return country_distances

    def add_country(self, country, distances):
        """
        Adds a new country and its distances to other countries.
        """
        for countryB, distance in distances.items():
            self.distances["|".join(sorted([country, countryB]))] = distance

        self.validate()
        self._update_all_countries()

    def export_to_nested_dict(self):
        """
        Serializes the flat distance structure back into a nested dictionary format.
        """
        nested_dict = {}
        for key, distance in self.distances.items():
            countryA, countryB = key.split("|")
            if countryA not in nested_dict:
                nested_dict[countryA] = {}
            if countryB not in nested_dict:
                nested_dict[countryB] = {}
            nested_dict[countryA][countryB] = distance
        return nested_dict

    def add_region(self, new_region, corresponding_country):
        print(
            f"Adding region {new_region} with corresponding country {corresponding_country}"
        )
        new_region_distances = self.extract_distances_for_country(corresponding_country)
        # We have to add the distance from the new_region to its corresponding country manually
        new_region_distances[corresponding_country] = self.self_distance
        new_region_distances[new_region] = self.self_distance
        self.add_country(new_region, new_region_distances)
        self._update_all_countries()

    def delete_country(self, country):
        """
        Deletes a country and its associated distances from the object.
        """
        keys_to_delete = [key for key in self.distances if country in key.split("|")]
        for key in keys_to_delete:
            del self.distances[key]
        self._update_all_countries()

    def add_self_distances(self):
        """
        Adds a self-referential distance of 500 for each country.
        """
        for country in self._all_countries:
            self.distances[f"{country}|{country}"] = self.self_distance

        self._update_all_countries()
