import json
import logging
import sys
from contextlib import contextmanager
from datetime import datetime

import pandas as pd
from git import Repo
from sqlalchemy import create_engine, text



# Constants

SCORE_HISTORY_PATH = "./data/common/score_history/score_history.csv"

TODAY_DATETIME_STR = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
IMPACTS_ECOBALYSE_PATH = "./public/data/impacts.json"
EXAMPLES_PATH_DIC = {
    "textile": "./tests/textile-examples-score.json",
    "food": "./tests/food-examples-score.json",
}

# Helper functions

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("logger")


def get_current_branch_name():
    """Retrieve the current branch name of the repository."""
    repo = Repo(".")
    return repo.active_branch.name


def get_arguments():
    if len(sys.argv) < 4:
        print("Usage: python compute_score_history.py <BRANCH_NAME> <LAST_COMMIT_HASH> <SCALINGO_POSTGRESQL_SCORE_URL>")
        sys.exit(1)
    branch_name = sys.argv[1]
    last_commit_hash = sys.argv[2][:7]
    scalingo_postgresql_score_url = sys.argv[3]
    return branch_name, last_commit_hash, scalingo_postgresql_score_url


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
                domain,
                example,
                normalization_factors,
                last_commit,
            )
        elif domain == "textile":
            simulation_result = process_response_textile(
                current_branch, domain, example, normalization_factors, last_commit
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


def process_response_textile(
    branch_name, domain, example, normalization_factors, last_commit
):
    """
    Processes the simulation response for a given example, transforming it into a structured DataFrame.

    Parameters:
    - branch_name (str): The name of the branch for which the simulation was run.
    - domain (str): "textile" or "food"
    - example (dict): The example data used in the simulation request.
    - normalization_factors (dict): A dictionary of normalization factors for adjusting impact scores.

    Returns:
    - DataFrame: A pandas DataFrame containing the structured results of the simulation.
    """
    # Initial preparation for DataFrame creation
    response = example["response"]
    query = example["query"]
    df_list = []

    df_list.append(create_df_textile(
            branch_name,
            last_commit,
            domain,
            example,
            query,
            response,
            normalization_factors,
        ))

    # Process life cycle steps
    life_cycle_steps = response.get("lifeCycle", [])
    for step in life_cycle_steps:
        df_list.append(create_df_textile(
            branch_name,
            last_commit,
            domain,
            example,
            query,
            step,
            normalization_factors,
        ))

    # Process transport, if present in the response
    transport_info = response.get("transport", None)
    if transport_info:
        transport_df = create_df_textile(
            branch_name,
            last_commit,
            domain,
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
    domain,
    example,
    query,
    step,
    normalization_factors,
    is_transport=False,
):
    impacts = pd.Series(step["impacts"])
    # Process dataframe for total
    if "label" not in step and not is_transport:
        data = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": domain,
            "product_name": example["name"],
            "id": example["id"],
            "query": json.dumps(query),
            "mass": query["mass"],
            "elements": json.dumps(query["materials"]),
            "lifecyclestep": "Total",
            "lifecyclestepcountry": step.get("country", {}).get("code", ""),
            "impact": impacts.index.tolist(),
            "value": impacts.values.tolist(),
        }
        df = pd.DataFrame(data)
        df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)

    # Process response for lifecyle step or transport step
    else:
        data = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": domain,
            "product_name": example["name"],
            "id": example["id"],
            "query": json.dumps(query),
            "mass": query["mass"],
            "elements": json.dumps(query["materials"]),
            "lifecyclestep": "Transport" if is_transport else step["label"],
            "lifecyclestepcountry": step.get("country", {}).get("code", ""),
            "impact": impacts.index.tolist(),
            "value": impacts.values.tolist(),
        }
        df = pd.DataFrame(data)
        df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)

    # In the case of a non transport step we have to store the complements
    if not is_transport:
        complementsImpacts = pd.Series(step["complementsImpacts"])
        data_complements = {
            "datetime": TODAY_DATETIME_STR,
            "branch": branch,
            "commit": commit_id,
            "domain": domain,
            "product_name": example["name"],
            "id": example["id"],
            "query": json.dumps(query),
            "mass": query["mass"],
            "elements": json.dumps(query["materials"]),
            "lifecyclestep": step.get("label","Total"),
            "lifecyclestepcountry": step.get("country", {}).get("code", ""),
            "impact": complementsImpacts.index.tolist(),
            "norm_value_ecs": complementsImpacts.values.tolist(),
        }
        df_complements = pd.DataFrame(data_complements)
    else:
        df_complements = pd.DataFrame()
    return pd.concat([df,df_complements], axis=0, ignore_index=True)


def process_response_food(
    branch_name, domain, example, normalization_factors, last_commit
):
    """
    Processes the simulation response for a given example, transforming it into a structured DataFrame.

    Parameters:
    - branch_name (str): The name of the branch for which the simulation was run.
    - domain (str): "textile" or "food"
    - example (dict): The example data used in the simulation request.
    - normalization_factors (dict): A dictionary of normalization factors for adjusting impact scores.

    Returns:
    - DataFrame: A pandas DataFrame containing the structured results of the simulation.
    """

    lifecyclestep_impact_paths = {
        "ingredients": ["recipe", "ingredientsTotal"],
        "transformation":["recipe", "transform"],
        "packaging": ["packaging"],
        "preparation": ["preparation"],
        "transports": ["transports", "impacts"],
        "distribution": ["distribution","total"],
    }

    results_per_life_cycle = []
    for lifecyclestep, path in lifecyclestep_impact_paths.items():
        impacts = get_nested_value(example["response"]["results"], path)
        results_per_life_cycle.append(
            create_df_food(
                branch_name,
                last_commit,
                domain,
                example,
                lifecyclestep,
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
    branch, commit_id, domain, example, lifecyclestep, impacts, normalization_factors
):
    """
    Create a pandas DataFrame with detailed information about food products based on various inputs.

    Parameters:
    - branch (str): The branch of the repository being queried.
    - commit_id (str): The specific commit ID in the repository.
    - domain (str): 'food' or 'textile'
    - example (dict): A dictionary containing details about the food product, such as name, id, and query details.
    - lifecyclestep (str): The lifecycle step of the food product.
    - impacts (pd.DataFrame): A DataFrame containing the impact indices and their respective values.
    - normalization_factors (dict): A dictionary mapping impact indices to normalization factors.

    Returns:
    - pd.DataFrame: A DataFrame with columns for datetime, branch, commit, domain, product name, product ID,
                    query JSON, mass, elements JSON, lifecycle step and country, impact indices, values,
                    and normalized impact values expressed in 'ecs' units.
    """
    impacts_sr = pd.Series(impacts, dtype="float64")
    data = {
        "datetime": TODAY_DATETIME_STR,
        "branch": branch,
        "commit": commit_id,
        "domain": domain,
        "product_name": example["name"],
        "id": example["id"],
        "query": json.dumps(example["query"]),
        "mass": example["response"]["results"]["preparedMass"],
        "elements": json.dumps(example["query"]["ingredients"]),
        "lifecyclestep": lifecyclestep,
        "lifecyclestepcountry": "",
        "impact": impacts_sr.index.tolist(),
        "value": impacts_sr.values.tolist(),
    }
    df = pd.DataFrame(data)
    df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)
    return df


def is_new_commit(score_history_df, last_commit):
    """if the last commit is not in the score history, we add this to the"""
    if not score_history_df["commit"].isin([last_commit]).any():
        return True
    else:
        return False


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
        "lifecyclestep",
        "lifecyclestepcountry",
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


def get_previous_score(domain, score_history_df, current_branch):
    """
    Retrieves the most recent score from the score history dataframe for a specific branch.

    Args:
    domain (str) : textile or food
    score_history_df (DataFrame): The DataFrame containing the score history with 'datetime' and 'branch' columns.
    current_branch (str): The branch for which to retrieve the most recent score.

    Returns:
    tuple:
        - bool indicating if there is no previous score on the branch.
        - DataFrame with the most recent score details for the branch.
    """
    # Convert 'datetime' to datetime format only if it's not already converted
    if not pd.api.types.is_datetime64_any_dtype(score_history_df["datetime"]):
        score_history_df["datetime"] = pd.to_datetime(score_history_df["datetime"])

    # Filter DataFrame for the current branch and current domain
    previous_score_df = score_history_df[
        (score_history_df["branch"] == current_branch)
        & (score_history_df["domain"] == domain)
    ]

    # Get the most recent datetime and filter the DataFrame to this datetime
    latest_datetime = previous_score_df["datetime"].max()
    previous_score_df = previous_score_df[
        previous_score_df["datetime"] == latest_datetime
    ]

    return previous_score_df


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


def get_score_history(engine):
    query = text("SELECT * FROM score_history")
    with get_database_connection(engine) as conn:
        df = pd.read_sql(query, conn)
        return df


def get_row_count(engine):
    query = text("SELECT COUNT(*) FROM score_history")
    with get_database_connection(engine) as conn:
        result = conn.execute(query).scalar()
        return result


def insert_new_score(df, engine, table_name):
    with get_database_connection(engine) as conn:
        df.to_sql(table_name, con=conn, if_exists="append", index=False)


if __name__ == "__main__":
    current_branch, last_commit, scalingo_postgresql_score_url = get_arguments()

    engine = create_engine(
        scalingo_postgresql_score_url, connect_args={"connect_timeout": 10}
    )

    score_history_df = get_score_history(engine)

    commit_is_new = is_new_commit(score_history_df, last_commit)

    if commit_is_new:
        logger.info(
            f"Score from commit {last_commit} hasn't been stored before. Computing score for {current_branch} and storing them if they are different"
        )

        for domain in ["textile", "food"]:
            example_path = EXAMPLES_PATH_DIC[domain]
            examples = load_json(example_path)
            new_score_df = get_new_score(domain, examples, current_branch, last_commit)
            previous_score_df = get_previous_score(
                domain, score_history_df, current_branch
            )
            if not previous_score_df.empty:
                score_is_different = are_df_different(new_score_df, previous_score_df)

            if score_is_different or previous_score_df.empty:
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
