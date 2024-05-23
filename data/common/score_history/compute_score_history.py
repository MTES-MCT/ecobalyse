import json
import logging
import os
import sys
from contextlib import contextmanager
from datetime import datetime

import numpy as np
import pandas as pd
import requests
from dotenv import load_dotenv
from git import Repo
from pandas.api.types import is_numeric_dtype
from sqlalchemy import create_engine, text

load_dotenv()


# Constants

SCORE_HISTORY_PATH = "./data/common/score_history/score_history.csv"

TODAY_DATETIME_STR = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
IMPACTS_JSON_PATH = "./public/data/impacts.json"
EXAMPLES_TEXTILE_PATH = "./public/data/textile/examples.json"

DATABASE_URL = os.getenv("SCORE_DATABASE_URL")
HEADER = {"token": os.getenv("API_TOKEN")}


# Helper functions

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("logger")


def get_current_branch_name():
    """Retrieve the current branch name of the repository."""
    repo = Repo(".")
    return repo.active_branch.name


def get_arguments():
    if len(sys.argv) < 4:
        print(
            "Usage: python compute_score_history.py <PR_NUMBER> <BRANCH_NAME> <LAST_COMMIT_HASH>"
        )
        sys.exit(1)
    pr_number = sys.argv[1]
    branch_name = sys.argv[2]
    last_commit_hash = sys.argv[3][:7]
    return pr_number, branch_name, last_commit_hash


def load_json(file):
    with open(file, "r") as f:
        return json.load(f)


def get_impacts_weights(branch):
    return fetch_json(
        f"https://raw.githubusercontent.com/MTES-MCT/ecobalyse/{branch}/public/data/impacts.json"
    )


# API functions


def compute_new_score(examples, current_branch, last_commit):
    simulations = []
    branch_url = BRANCH_URLS.get(current_branch, "")
    normalization_factors = compute_normalization_factors(current_branch)
    for example in examples:
        if example["name"] == "Produit vide":
            continue

        simulation_result = simulate_example(
            current_branch, branch_url, example, normalization_factors, last_commit
        )
        simulations.append(simulation_result)
    return pd.concat(simulations, axis=0, ignore_index=True)


def compute_normalization_factors(branch):
    impacts_ecobalyse = get_impacts_weights(branch)

    normalization_factors = {}
    for k, v in impacts_ecobalyse.items():
        if v["ecoscore"]:
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def fetch_json(url, method="GET", payload=None):
    try:
        if method.upper() == "POST":
            response = requests.post(url, json=payload, headers=HEADER)
        else:
            response = requests.get(url)
        response.raise_for_status()  # Raises HTTPError for bad responses
        return response.json()
    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTP error occurred during {method} request to {url}: {e}")
        raise


def simulate_example(
    branch_name, branch_url, example, normalization_factors, last_commit
):
    response = fetch_json(branch_url, payload=example["query"], method="POST")
    return process_simulation_response(
        branch_name, example, response, normalization_factors, last_commit
    )


def process_simulation_response(
    branch_name, example, response, normalization_factors, last_commit
):
    """
    Processes the simulation response for a given example, transforming it into a structured DataFrame.

    Parameters:
    - branch_name (str): The name of the branch for which the simulation was run.
    - example (dict): The example data used in the simulation request.
    - response (dict): The response data from the simulation request.
    - normalization_factors (dict): A dictionary of normalization factors for adjusting impact scores.

    Returns:
    - DataFrame: A pandas DataFrame containing the structured results of the simulation.
    """
    # Initial preparation for DataFrame creation

    query = example["query"]
    domain = "textile"  # This can be dynamic based on the simulation type

    # Process life cycle steps
    life_cycle_steps = response.get("lifeCycle", [])
    results_per_life_cycle = [
        create_df(
            branch_name,
            last_commit,
            domain,
            example,
            query,
            step,
            normalization_factors,
        )
        for step in life_cycle_steps
    ]

    # Process transport, if present in the response
    transport_info = response.get("transport", None)
    if transport_info:
        transport_df = create_df(
            branch_name,
            last_commit,
            domain,
            example,
            query,
            transport_info,
            normalization_factors,
            is_transport=True,
        )
        results_per_life_cycle.append(transport_df)

    # Concatenate all DataFrames into a single DataFrame
    if results_per_life_cycle:
        return pd.concat(results_per_life_cycle, axis=0, ignore_index=True)
    else:
        # Return an empty DataFrame if there are no results to process
        return pd.DataFrame()


def create_df(
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
    return df


def is_new_commit(score_history_df, last_commit):
    """if the last commit is not in the score history, we add this to the"""
    if not score_history_df["commit"].isin([last_commit]).any():
        return True
    else:
        return False


def compare_scores_with_tolerance(df1, df2, tolerance=0.0001):
    """
    Compare two dataframes with a tolerance for numerical values.

    Args:
    - df1 (pd.DataFrame): First dataframe to compare.
    - df2 (pd.DataFrame): Second dataframe to compare.
    - tolerance (float): Relative tolerance for numerical comparison, default is 0.01%.

    Returns:
    - bool: True if dataframes are identical within the tolerance, False otherwise.
    """

    df1 = df1.drop(["datetime", "commit"], axis=1)
    df2 = df2.drop(["datetime", "commit"], axis=1)

    df1 = df1.reset_index(drop=True)
    df2 = df2.reset_index(drop=True)

    # Initial comparison using pandas compare
    diff = df1.compare(df2)
    if diff.empty:
        return False  # DataFrames are identical

    # Check for numerical differences within the tolerance
    for column in diff.columns.get_level_values(0).unique():
        if is_numeric_dtype(df1[column]):
            # Check only the differences in the numerical columns
            diff_subset = diff[column].dropna()
            # Extracting the 'self' and 'other' parts of the differences
            self_values = diff_subset["self"]
            other_values = diff_subset["other"]
            # Check if the differences are within the tolerance
            if not np.all(np.isclose(self_values, other_values, rtol=tolerance)):
                return True
    return False


def get_previous_score(score_history_df, current_branch):
    """
    Retrieves the most recent score from the score history dataframe for a specific branch.

    Args:
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

    # Filter DataFrame for the current branch
    previous_score_df = score_history_df[score_history_df["branch"] == current_branch]

    # Check if there are any scores for the branch
    if previous_score_df.empty:
        return True, previous_score_df

    # Get the most recent datetime and filter the DataFrame to this datetime
    latest_datetime = previous_score_df["datetime"].max()
    previous_score_df = previous_score_df[
        previous_score_df["datetime"] == latest_datetime
    ]

    return False, previous_score_df


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


def setup_variables():
    pr_number, current_branch, last_commit = get_arguments()
    TEST_BRANCH = {"name": current_branch, "pr_number": pr_number}
    BRANCHES = ["master", TEST_BRANCH["name"]]
    BRANCH_URLS = {
        "master": "https://ecobalyse.beta.gouv.fr/api/textile/simulator/detailed",
        TEST_BRANCH[
            "name"
        ]: f"https://ecobalyse-pr{TEST_BRANCH['pr_number']}.osc-fr1.scalingo.io/api/textile/simulator/detailed",
    }
    return pr_number, current_branch, last_commit, BRANCHES, BRANCH_URLS


if __name__ == "__main__":
    pr_number, current_branch, last_commit, BRANCHES, BRANCH_URLS = setup_variables()

    engine = create_engine(
        DATABASE_URL, connect_args={"connect_timeout": 10}, echo=True
    )

    score_history_df = get_score_history(engine)
    examples_textile = load_json(EXAMPLES_TEXTILE_PATH)
    commit_is_new = is_new_commit(score_history_df, last_commit)

    if commit_is_new:
        logger.info(
            f"Score from commit {last_commit} hasn't been stored before. Computing score for {current_branch}"
        )
        new_score_df = compute_new_score(examples_textile, current_branch, last_commit)
        no_previous_score, previous_score_df = get_previous_score(
            score_history_df, current_branch
        )
        score_is_different = compare_scores_with_tolerance(
            previous_score_df, new_score_df
        )

        if score_is_different or no_previous_score:
            logger.info(
                f"Number of rows in the score_history table before update: {get_row_count(engine)}"
            )
            insert_new_score(new_score_df, engine, "score_history")
            logger.info(
                f"Successfully appended new score ({new_score_df.shape[0]} rows) to score_history postgresql table"
            )
            logger.info(
                f"Number of rows in the score_history table after update: {get_row_count(engine)}"
            )
        else:
            logger.info(
                "New score is identical to old score. Nothing was added to score history."
            )
    else:
        logger.info(f"Commit {last_commit} isn't new. Nothing added")
