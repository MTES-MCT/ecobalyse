import functools

import bw2data


@functools.cache
def cached_search_one(
    dbname,
    search_terms,
    location=None,
    excluded_term=None,
    code=None,
    categories=None,
    unit=None,
) -> dict:
    return search_one(
        dbname,
        search_terms,
        location=location,
        excluded_term=excluded_term,
        code=code,
        categories=categories,
        unit=unit,
    )


def search_one(
    dbname,
    search_terms,
    location=None,
    excluded_term=None,
    code=None,
    categories=None,
    unit=None,
) -> dict:
    """Search for a single activity in a Brightway database.

    Args:
        dbname (str): The name of the Brightway database to search in.
        search_terms (str): The search terms to use.
        location (str, optional): The location of the LCI (Country code like FR, BE, DE, or region like GLO, RoW, RER, etc.). Defaults to None.
        excluded_term (str, optional): The term to exclude from the search. Defaults to None.
        code (str, optional): The specific activity code. If provided, lookup by code directly. Defaults to None.
        unit (str, optional): The unit to filter by (e.g. 'kg', 'm3'). Defaults to None.

    Returns:
        Brightway activity if exactly one exact match by name is found, otherwise raises a ValueError.
    """
    # If code is provided, look up directly by code
    if code:
        try:
            activity = bw2data.get_activity((dbname, code))
            # Verify the name matches if search_terms provided
            if search_terms and activity["name"] != search_terms:
                raise ValueError(
                    f"Activity with code {code} found but name doesn't match. "
                    f"Expected: '{search_terms}', Got: '{activity.get('name')}'"
                )
            return activity
        except Exception as e:
            raise ValueError(
                f"Activity with code {code} not found in database '{dbname}': {e}"
            )

    search_query = search_terms
    if location:
        search_query = search_query + f" {location}"
    results = bw2data.Database(dbname).search(search_query, limit=None)

    if excluded_term:
        results = [res for res in results if excluded_term not in res["name"]]

    if not results:
        raise ValueError(f"Not found in brightway db `{dbname}`: '{search_query}'")

    exact_matches = []
    for result in results:
        # Check exact name match
        if result["name"] == search_terms:
            # If location specified, also check location match
            if location is None or result.get("location") == location:
                # If categories specified, also check categories match
                if categories is None or tuple(result.get("categories", ())) == tuple(
                    categories
                ):
                    if unit is None or result.get("unit") == unit:
                        exact_matches.append(result)

    if len(exact_matches) == 1:
        return exact_matches[0]
    else:
        results_string = "\n".join([str(result) for result in results])
        raise ValueError(
            (
                f"This 'search' doesn't return one perfect match (got {len(results)}) matches in database '{dbname}':\n'{search_terms}'\n"
                f" Please change your search terms or location so that it returns one perfect match.\nResults returned:\n{results_string}"
            )
        )
