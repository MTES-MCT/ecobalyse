import json
import logging
import pandas as pd
import numpy as np
from pandas.api.types import is_numeric_dtype

import requests
import subprocess
import time
from datetime import datetime


SCORE_HISTORY_PATH = "./data/common/score_history/score_history.csv"

# TODO : find a way to retrieve this automatically
TEST_BRANCH = {"name": "score-evolution-tracking", "pr_number": 566}

BRANCHES = ["master", TEST_BRANCH["name"]]
BRANCH_URLS = {
    "master": "https://ecobalyse.beta.gouv.fr/api/textile/simulator/detailed",
    TEST_BRANCH[
        "name"
    ]: f"https://ecobalyse-pr{TEST_BRANCH['pr_number']}.osc-fr1.scalingo.io/api/textile/simulator/detailed",
}

TODAY_DATETIME_STR = datetime.now().strftime("%Y-%m-%d %H:%M")
IMPACTS_JSON_PATH = "./public/data/impacts.json"
EXAMPLES_TEXTILE_PATH = "./public/data/textile/examples.json"


def load_json(file):
    with open(file, "r") as f:
        return json.load(f)


def fetch_remote_branches(retries=3, delay=2):
    """Fetch all Git branches, retrying with exponential backoff on failure."""
    command = ["git", "fetch", "--all"]
    attempt = 0
    while attempt < retries:
        try:
            result = subprocess.run(command, check=True, capture_output=True, text=True)
            logging.info(f"Successfully fetched remote branches: {result.stdout}")
            return
        except subprocess.CalledProcessError as e:
            logging.warning(f"Attempt {attempt + 1} failed: {e.stderr}")
            time.sleep(delay)
            delay *= 2  # Exponential backoff
        attempt += 1
    logging.error(f"Failed to fetch remote branches after {retries} attempts.")
    raise Exception("Failed to fetch remote branches.")


def get_last_commit_id(branch_name, fetch=False):
    if fetch:
        fetch_remote_branches()

    subprocess_options = {"capture_output": True, "text": True}

    # Check if the branch exists locally or remotely
    check_branch = subprocess.run(
        ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch_name}"],
        **subprocess_options,
    )
    if check_branch.returncode != 0:
        # Branch not found locally; let's try fetching and checking again if fetch was true
        if not fetch:
            raise Exception(
                f"Branch '{branch_name}' not found. Consider setting fetch=True to fetch remote branches."
            )
        else:
            # Branch still not found after fetching; it may not exist
            raise Exception(
                f"Branch '{branch_name}' not found even after fetching. Ensure the branch exists."
            )

    # Get the last commit ID
    result = subprocess.run(["git", "rev-parse", branch_name], **subprocess_options)
    if result.returncode == 0:
        return result.stdout.strip()[:7]
    else:
        raise Exception(f"Error getting last commit ID: {result.stderr}")


def get_impacts_weights(branch):
    return fetch_json(
        f"https://raw.githubusercontent.com/MTES-MCT/ecobalyse/{branch}/public/data/impacts.json"
    )


def compute_new_score(examples, current_branch):
    simulations = []
    branch_url = BRANCH_URLS.get(current_branch, "")
    normalization_factors = compute_normalization_factors(current_branch)
    for example in examples:
        if example["name"] == "Produit vide":
            continue
        try:
            simulation_result = simulate_example(
                current_branch, branch_url, example, normalization_factors
            )
            simulations.append(simulation_result)
        except Exception as e:
            logging.error(
                f"Error simulating example {example['name']} on branch {current_branch}: {e}"
            )
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


def fetch_json(url, method="GET", json=None):
    try:
        if method.upper() == "POST":
            response = requests.post(url, json=json)
        else:
            response = requests.get(url)
        response.raise_for_status()  # Raises HTTPError for bad responses
        return response.json()
    except requests.exceptions.HTTPError as e:
        logging.error(f"HTTP error occurred during {method} request to {url}: {e}")
        raise


def simulate_example(branch_name, branch_url, example, normalization_factors):
    response = fetch_json(branch_url, json=example["query"], method="POST")
    return process_simulation_response(
        branch_name, example, response, normalization_factors
    )


def process_simulation_response(branch_name, example, response, normalization_factors):
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
    last_commit_id = get_last_commit_id(branch_name, fetch=True)[:7]
    query = example["query"]
    domain = "textile"  # This can be dynamic based on the simulation type

    # Process life cycle steps
    life_cycle_steps = response.get("lifeCycle", [])
    results_per_life_cycle = [
        create_df(
            branch_name,
            last_commit_id,
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
            last_commit_id,
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
        "query": json.dumps(query),
        "lifeCycleStep": "Transport" if is_transport else step["label"],
        "impact": impacts.index.tolist(),
        "value": impacts.values.tolist(),
    }
    df = pd.DataFrame(data)
    df["norm_value_ecs"] = 1e6 * df["value"] * df["impact"].map(normalization_factors)
    return df


def get_last_commit():
    """Retrieve the last commit IDs for the current branch"""
    current_branch_command = ["git", "branch", "--show-current"]
    last_commit = {}
    try:
        current_branch_result = subprocess.run(
            current_branch_command, check=True, capture_output=True, text=True
        )
        current_branch = current_branch_result.stdout.strip()
        last_commit = get_last_commit_id(current_branch, fetch=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Error determining the current branch: {e.stderr}")
        raise
    return current_branch, last_commit


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


if __name__ == "__main__":

    score_history_df = pd.read_csv(SCORE_HISTORY_PATH, sep=",")
    examples_textile = load_json(EXAMPLES_TEXTILE_PATH)
    current_branch, last_commit = get_last_commit()
    commit_is_new = is_new_commit(score_history_df, last_commit)

    if commit_is_new:
        logging.info(f"computing score for {current_branch}")
        new_score_df = compute_new_score(examples_textile, commit_is_new)

        score_previous_df = score_history_df[score_history_df["commit"] == last_commit]
        score_is_different = compare_scores_with_tolerance(
            score_previous_df, new_score_df
        )

        if score_is_different:
            score_history_updated_df = pd.concat(
                [score_history_df, new_score_df], ignore_index=True
            )
            score_history_updated_df.to_csv(
                SCORE_HISTORY_PATH, index=False, encoding="utf-8-sig"
            )
        else:
            print(
                "New score is the identical to old score. Nothing was added to score history"
            )
