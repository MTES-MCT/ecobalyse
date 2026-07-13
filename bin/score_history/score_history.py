#!/usr/bin/env python

import json
import logging
import os
import pathlib
import sys
from contextlib import contextmanager
from datetime import datetime
from enum import StrEnum

import pandas as pd
import requests
from sqlalchemy import create_engine, text

# Constants

CURRENT_FILE_DIR = pathlib.Path(__file__).parent.resolve()
PROJECT_ROOT_DIR = pathlib.Path(__file__).parent.parent.parent.resolve()
IMPACTS_ECOBALYSE_PATH = os.path.join(
    PROJECT_ROOT_DIR, "public", "data", "impacts.json"
)
PROCESSES_IMPACTS_PATH = os.path.join(
    PROJECT_ROOT_DIR, "public", "data", "processes_impacts.json"
)

TODAY_DATETIME_STR = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
TOKEN = "dummy"


class Domain(StrEnum):
    TEXTILE = "textile"
    FOOD = "food"


EXAMPLES_KEY = "examples"
API_ENDPOINT_KEY = "api_endpoint"

# @TODO: do the same for objects
DOMAIN_DATA = {
    Domain.TEXTILE: {
        EXAMPLES_KEY: os.path.join(
            PROJECT_ROOT_DIR, "public", "data", "textile", "examples.json"
        ),
        API_ENDPOINT_KEY: "/api/textile/simulator/detailed",
    },
    Domain.FOOD: {
        EXAMPLES_KEY: os.path.join(
            PROJECT_ROOT_DIR, "public", "data", "food", "examples.json"
        ),
        API_ENDPOINT_KEY: "/api/food/",
    },
}

# Helper functions

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("logger")


def get_arguments():
    dry_run = "--dry-run" in sys.argv
    if dry_run:
        sys.argv.remove("--dry-run")

    if len(sys.argv) < 4:
        print(
            "Usage: python score_history.py <API_URL> <BRANCH_NAME> <LAST_COMMIT_HASH> <SCALINGO_POSTGRESQL_SCORE_URL> [--dry-run]"
        )
        sys.exit(1)

    api_url = sys.argv[1]
    branch_name = sys.argv[2]
    last_commit_hash = sys.argv[3][:7]
    scalingo_postgresql_score_url = sys.argv[4]
    return (
        api_url,
        branch_name,
        last_commit_hash,
        scalingo_postgresql_score_url,
        dry_run,
    )


def load_json(file):
    with open(file, "r") as f:
        return json.load(f)


# API functions


def get_new_score(domain, examples, current_branch, last_commit):
    simulations = []
    normalization_factors = compute_normalization_factors()
    for example in examples:
        if domain == "food":
            simulation_result = process_response_food(
                current_branch,
                example,
                normalization_factors,
                last_commit,
            )
        elif domain == "textile":
            simulation_result = process_response_textile(
                current_branch, example, normalization_factors, last_commit
            )
        else:
            raise ValueError(
                f"Invalid domain {domain}. Please use 'textile' or 'food'."
            )

        simulations.append(simulation_result)
    return pd.concat(simulations, axis=0, ignore_index=True)


def compute_normalization_factors():
    impacts_ecobalyse = load_json(IMPACTS_ECOBALYSE_PATH)

    normalization_factors = {}
    for k, v in impacts_ecobalyse.items():
        if v["ecoscore"]:
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def process_response_textile(branch_name, example, normalization_factors, last_commit):
    """
    Processes the simulation response for a given example, transforming it into a structured DataFrame.

    Parameters:
    - branch_name (str): The name of the branch for which the simulation was run.
    - example (dict): The example data used in the simulation request.
    - normalization_factors (dict): A dictionary of normalization factors for adjusting impact scores.

    Returns:
    - DataFrame: A pandas DataFrame containing the structured results of the simulation.
    """
    # Initial preparation for DataFrame creation
    response = example["response"]
    query = example["query"]
    df_list = []

    df_list.append(
        create_df_textile(
            branch_name,
            last_commit,
            example,
            query,
            response,
            normalization_factors,
        )
    )

    # Process life cycle steps
    life_cycle_steps = response.get("lifeCycle", [])
    for step in life_cycle_steps:
        df_list.append(
            create_df_textile(
                branch_name,
                last_commit,
                example,
                query,
                step,
                normalization_factors,
            )
        )

    # Process transport, if present in the response
    transport_info = response.get("transport", None)
    if transport_info:
        transport_df = create_df_textile(
            branch_name,
            last_commit,
            example,
            query,
            transport_info,
            normalization_factors,
            is_transport=True,
        )
        df_list.append(transport_df)

    # Concatenate all DataFrames into a single DataFrame
    if df_list:
        return pd.concat(df_list, axis=0, ignore_index=True)
    else:
        # Return an empty DataFrame if there are no results to process
        return pd.DataFrame()


def create_df_textile(
    branch,
    commit_id,
    example,
    query,
    step,
    normalization_factors,
    is_transport=False,
):
    impacts = pd.Series(step["impacts"])

    # The step is either a transport step, a lifecycle step in that case we use the "label" field
    # if it's not either one it's a "Total" step
    step_label = "Transport" if is_transport else step.get("label", "Total")

    data = {
        "datetime": TODAY_DATETIME_STR,
        "branch": branch,
        "commit": commit_id,
        "domain": "textile",
        "product_name": example["name"],
        "id": example["id"],
        "query": json.dumps(query),
        "mass": query["mass"],
        "elements": json.dumps(query["materials"]),
        "lifecycle_step": step_label,
        "lifecycle_step_country": step.get("country", {}).get("code", ""),
        "impact": impacts.index.tolist(),
        "value": impacts.values.tolist(),
    }
    df = pd.DataFrame(data)
    df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)

    # In the case of a non transport step we have to store the complements
    if not is_transport and "complementsImpacts" in step:
        complementsImpacts = pd.Series(step["complementsImpacts"])
        data_complements = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": "textile",
            "product_name": example["name"],
            "id": example["id"],
            "query": json.dumps(query),
            "mass": query["mass"],
            "elements": json.dumps(query["materials"]),
            "lifecycle_step": step_label,
            "lifecycle_step_country": step.get("country", {}).get("code", ""),
            "impact": complementsImpacts.index.tolist(),
            "value": 0,
            "norm_value_ecs": complementsImpacts.values.tolist(),
        }
        df_complements = pd.DataFrame(data_complements)
        df = pd.concat([df, df_complements], axis=0, ignore_index=True)

    return df


def process_response_food(branch_name, example, normalization_factors, last_commit):
    """
    Processes the simulation response for a given example, transforming it into a structured DataFrame.

    Parameters:
    - branch_name (str): The name of the branch for which the simulation was run.
    - example (dict): The example data used in the simulation request.
    - normalization_factors (dict): A dictionary of normalization factors for adjusting impact scores.

    Returns:
    - DataFrame: A pandas DataFrame containing the structured results of the simulation.
    """

    lifecycle_step_impact_paths = {
        "ingredients": ["recipe"],
        "transformation": ["recipe", "transform"],
        "packaging": ["packaging"],
        "preparation": ["preparation"],
        "transports": ["transports", "impacts"],
        "distribution": ["distribution", "total"],
    }

    results_per_life_cycle = []
    for lifecycle_step, path in lifecycle_step_impact_paths.items():
        impacts = get_nested_value(example["response"]["results"], path)
        results_per_life_cycle.append(
            create_df_food(
                branch_name,
                last_commit,
                example,
                lifecycle_step,
                impacts,
                normalization_factors,
            )
        )

    # Concatenate all DataFrames into a single DataFrame
    if results_per_life_cycle:
        return pd.concat(results_per_life_cycle, axis=0, ignore_index=True)
    else:
        # Return an empty DataFrame if there are no results to process
        return pd.DataFrame()


def get_nested_value(nested_dict, keys):
    """
    Retrieves a value from a nested dictionary using a tuple or list of keys.
    :param nested_dict: Dict, the nested dictionary from which to retrieve the value.
    :param keys: Iterable (tuple or list), sequence of keys to navigate the nested dictionary.
    :return: The value found using the provided keys, or None if any key is missing.
    """
    current_level = nested_dict
    for key in keys:
        if key in current_level:
            current_level = current_level[key]
        else:
            return None
    return current_level


def create_df_food(
    branch, commit_id, example, lifecycle_step, impacts, normalization_factors
):
    """
    Create a pandas DataFrame with detailed information about food products based on various inputs.

    Parameters:
    - branch (str): The branch of the repository being queried.
    - commit_id (str): The specific commit ID in the repository.
    - example (dict): A dictionary containing details about the food product, such as name, id, and query details.
    - lifecycle_step (str): The lifecycle step of the food product.
    - impacts (pd.DataFrame): A DataFrame containing the impact indices and their respective values.
    - normalization_factors (dict): A dictionary mapping impact indices to normalization factors.

    Returns:
    - pd.DataFrame: A DataFrame with columns for datetime, branch, commit, domain, product name, product ID,
                    query, mass, elements, lifecycle step and country, impact indices, values,
                    and normalized impact values expressed in 'ecs' units.
    """
    if lifecycle_step == "ingredients":
        impacts_sr = pd.Series(impacts["ingredientsTotal"], dtype="float64")
    else:
        impacts_sr = pd.Series(impacts, dtype="float64")

    data = {
        "datetime": TODAY_DATETIME_STR,
        "branch": branch,
        "commit": commit_id,
        "domain": "food",
        "product_name": example["name"],
        "id": example["id"],
        "query": json.dumps(example["query"]),
        "mass": example["response"]["results"]["preparedMass"],
        "elements": json.dumps(example["query"]["ingredients"]),
        "lifecycle_step": lifecycle_step,
        "lifecycle_step_country": "",
        "impact": impacts_sr.index.tolist(),
        "value": impacts_sr.values.tolist(),
    }
    df = pd.DataFrame(data)
    df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)

    # For the ingredients we have to store the complements
    if lifecycle_step == "ingredients":
        complementsImpacts = pd.Series(impacts["totalBonusImpact"])
        data_complements = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": "food",
            "product_name": example["name"],
            "id": example["id"],
            "query": json.dumps(example["query"]),
            "mass": example["response"]["results"]["preparedMass"],
            "elements": json.dumps(example["query"]["ingredients"]),
            "lifecycle_step": lifecycle_step,
            "lifecycle_step_country": "",
            "impact": complementsImpacts.index.tolist(),
            "value": 0,
            "norm_value_ecs": complementsImpacts.values.tolist(),
        }
        df_complements = pd.DataFrame(data_complements)
        df = pd.concat([df, df_complements], axis=0, ignore_index=True)
    return df


def get_ingredient_scores_from_file(current_branch, last_commit):
    """
    Get the ingredient scores not from the API but directly from the impacts file.
    We won't have the transport/distribution impact but it's a lot faster
    """
    normalization_factors = compute_normalization_factors()
    processes = load_json(PROCESSES_IMPACTS_PATH)
    visible_ingredient_processes = [
        process
        for process in processes
        if process.get("metadata")
        and process["metadata"].get("ingredient")
        and process["visible"]
    ]

    ingredient_dfs = [
        create_df_ingredient(
            current_branch, last_commit, process, normalization_factors
        )
        for process in visible_ingredient_processes
    ]
    return pd.concat(ingredient_dfs, axis=0, ignore_index=True)


def create_df_ingredient(branch, commit_id, process, normalization_factors):
    """
    Create a DataFrame of score rows for a single raw ingredient from its
    process entry in processes_impacts.json

    """
    ingredient_query = {"ingredients": [{"id": process["id"], "mass": 1000}]}
    impacts_sr = pd.Series(process["impacts"], dtype="float64")

    data = {
        "datetime": TODAY_DATETIME_STR,
        "branch": branch,
        "commit": commit_id,
        "domain": "food",
        "product_name": process["alias"],
        "id": process["id"],
        "query": json.dumps(ingredient_query),
        "mass": 1000,
        "elements": json.dumps(ingredient_query["ingredients"]),
        "lifecycle_step": "ingredients",
        "lifecycle_step_country": "",
        "impact": impacts_sr.index.tolist(),
        "value": impacts_sr.values.tolist(),
    }
    df = pd.DataFrame(data)
    df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)

    complements = {
        key: value
        for key, value in process["metadata"].get("complements", {}).items()
        if value is not None
    }

    # Match the API-based rows: the ecs value includes the complements
    df.loc[df["impact"] == "ecs", "value"] += sum(complements.values())

    if complements:
        data_complements = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": "food",
            "product_name": process["alias"],
            "id": process["id"],
            "query": json.dumps(ingredient_query),
            "mass": 1000,
            "elements": json.dumps(ingredient_query["ingredients"]),
            "lifecycle_step": "ingredients",
            "lifecycle_step_country": "",
            "impact": list(complements.keys()),
            "value": 0,
            "norm_value_ecs": list(complements.values()),
        }
        df_complements = pd.DataFrame(data_complements)
        df = pd.concat([df, df_complements], axis=0, ignore_index=True)

    return df


def is_new_commit(engine, last_commit):
    """Check if the commit is already in score_history"""
    query = text("SELECT 1 FROM score_history WHERE commit = :commit LIMIT 1")
    with get_database_connection(engine) as conn:
        existing_commit_row = conn.execute(query, {"commit": last_commit}).first()
    return existing_commit_row is None


def are_df_different(df1, df2, tolerance=0.0001):
    """
    Compare two dataframes with a tolerance for numerical values.

    Args:
    - df1 (pd.DataFrame): First dataframe to compare.
    - df2 (pd.DataFrame): Second dataframe to compare.
    - tolerance (float): Relative tolerance for numerical comparison, default is 0.01%.

    Returns:
    - bool: True if dataframes are different, False if dataframes are identical or within the tolerance.
    """

    df1 = df1.drop(["datetime", "commit"], axis=1)
    df2 = df2.drop(["datetime", "commit"], axis=1)

    df1 = df1.reset_index(drop=True)
    df2 = df2.reset_index(drop=True)

    key_columns = [
        "domain",
        "product_name",
        "query",
        "lifecycle_step",
        "lifecycle_step_country",
        "impact",
    ]

    value_columns = ["value", "norm_value_ecs"]

    dict1 = dataframe_to_dict(df1, key_columns, value_columns)
    dict2 = dataframe_to_dict(df2, key_columns, value_columns)

    for key, (value1, norm_value1) in dict1.items():
        if key in dict2:
            (value2, norm_value2) = dict2[key]
            if (
                abs(value1 - value2) > tolerance
                or abs(norm_value1 - norm_value2) > tolerance
            ):
                return True
        else:
            return True
    return False


def dataframe_to_dict(df, key_cols, value_cols):
    """
    Transform a DataFrame into a dictionary by concatenating multiple columns to form the key
    and using a tuple of columns as the dictionary values.

    Args:
    df (pd.DataFrame): The source DataFrame.
    key_cols (list): List of column names to concatenate for the key.
    value_cols (list): List of column names to combine into a tuple for the values.

    Returns:
    dict: Dictionary with concatenated keys and tuple values.
    """
    # Concatenate the specified columns to form a single key column
    df["master_key"] = df[key_cols].apply(
        lambda row: "_".join(row.values.astype(str)), axis=1
    )
    df["master_value"] = df[value_cols].apply(lambda row: tuple(row), axis=1)

    # Create a dictionary with the new key column and the specified value column
    result_dict = df.set_index("master_key")["master_value"].to_dict()
    return result_dict


def get_previous_score(engine, domain, current_branch):
    """
    Retrieves the rows of the most recent score for a specific branch and domain.

    Args:
    engine: SQLAlchemy engine
    domain (str) : textile or food
    current_branch (str): The branch for which to retrieve the most recent score.

    Returns:
    DataFrame with the most recent score details for the branch and domain,
    empty if the branch and domain have no score yet.
    """
    query = text(
        """
        SELECT * FROM score_history
        WHERE branch = :branch
          AND domain = :domain
          AND datetime = (
              SELECT MAX(datetime) FROM score_history
              WHERE branch = :branch AND domain = :domain
          )
        """
    )
    query_params = {"branch": current_branch, "domain": str(domain)}
    with get_database_connection(engine) as conn:
        return pd.read_sql(query, conn, params=query_params)


# Database Operations


@contextmanager
def get_database_connection(engine):
    """
    Context manager for database connections that correctly implements the context management protocol.
    Ensures that the connection is properly managed with commit or rollback and closure.
    """
    connection = engine.connect()
    transaction = connection.begin()
    try:
        yield connection
        transaction.commit()  # Commit the transaction if all operations were successful
    except Exception as e:
        transaction.rollback()  # Roll back the transaction in case of an error
        raise e
    finally:
        connection.close()  # Ensure the connection is closed


def get_row_count(engine):
    query = text("SELECT COUNT(*) FROM score_history")
    with get_database_connection(engine) as conn:
        result = conn.execute(query).scalar()
        return result


def insert_new_score(df, engine, table_name):
    with get_database_connection(engine) as conn:
        df.to_sql(table_name, con=conn, if_exists="append", index=False)


def compute_product_scores(product_params, api_url, token):
    r = requests.post(api_url, json=product_params["query"])
    return r.json()


def compute_products_scores_for_examples(examples, api_url, token):
    computed_scores = []

    for example in examples:
        product_scores = compute_product_scores(example, api_url, token)
        example["response"] = product_scores
        computed_scores.append(example)

    return computed_scores


if __name__ == "__main__":
    api_url, current_branch, last_commit, scalingo_postgresql_score_url, dry_run = (
        get_arguments()
    )
    engine = create_engine(
        scalingo_postgresql_score_url, connect_args={"connect_timeout": 10}
    )
    commit_is_new = is_new_commit(engine, last_commit)

    if commit_is_new:
        logger.info(
            f"Score from commit {last_commit} hasn't been stored before. Computing score for {current_branch} and storing them if they are different"
        )

        for domain in Domain:
            example_path = DOMAIN_DATA[domain][EXAMPLES_KEY]
            api_endpoint = DOMAIN_DATA[domain][API_ENDPOINT_KEY]

            examples_input = load_json(example_path)

            examples = compute_products_scores_for_examples(
                examples_input, f"{api_url}{api_endpoint}", TOKEN
            )

            new_score_df = get_new_score(domain, examples, current_branch, last_commit)

            if domain == Domain.FOOD:
                ingredient_scores_df = get_ingredient_scores_from_file(
                    current_branch, last_commit
                )
                new_score_df = pd.concat(
                    [new_score_df, ingredient_scores_df], axis=0, ignore_index=True
                )
            logger.info(
                f"Fetching previous score for branch {current_branch} and domain {domain}"
            )
            previous_score_df = get_previous_score(engine, domain, current_branch)
            if previous_score_df.empty or are_df_different(
                new_score_df, previous_score_df
            ):
                if dry_run:
                    logger.info(
                        f"[dry-run] Score is different for domain {domain}. Would have appended {new_score_df.shape[0]} rows to score_history. Nothing was inserted."
                    )
                    continue
                logger.info(
                    f"Score is different for domain {domain}. Storing new score in the db. Number of rows in the score_history table before update: {get_row_count(engine)}"
                )
                insert_new_score(new_score_df, engine, "score_history")
                logger.info(
                    f"Successfully appended new score ({new_score_df.shape[0]} rows) to score_history postgresql table for domain {domain}."
                )
                logger.info(
                    f"Number of rows in the score_history table after update: {get_row_count(engine)}"
                )
            else:
                logger.info(
                    f"New score is identical to old score for domain {domain}.. Nothing was added to score history."
                )

    else:
        logger.info(f"Commit {last_commit} isn't new. Nothing added to the db.")
