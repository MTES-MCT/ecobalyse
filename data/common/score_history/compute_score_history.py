import json
import logging
import subprocess
import time
from datetime import datetime

import numpy as np
import pandas as pd
import requests
from pandas.api.types import is_numeric_dtype

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


def get_impacts_weights(branch):
    return fetch_json(
        f"https://raw.githubusercontent.com/MTES-MCT/ecobalyse/{branch}/public/data/impacts.json"
    )


def compute_new_score(examples, current_branch, last_commit):
    simulations = []
    branch_url = BRANCH_URLS.get(current_branch, "")
    normalization_factors = compute_normalization_factors(current_branch)
    for example in examples:
        if example["name"] == "Produit vide":
            continue
        try:
            simulation_result = simulate_example(
                current_branch, branch_url, example, normalization_factors, last_commit
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


def fetch_json(url, method="GET", payload=None):
    try:
        if method.upper() == "POST":
            response = requests.post(url, json=payload)
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
        "query": json.dumps(query),
        "lifeCycleStep": "Transport" if is_transport else step["label"],
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


def get_last_commit():
    """
    Retrieve the last commit ID of the current branch without fetching remote branches.
    """
    # Command to get the current branch name
    current_branch_command = ["git", "branch", "--show-current"]
    try:
        # Get the current branch name
        current_branch_result = subprocess.run(
            current_branch_command, check=True, capture_output=True, text=True
        )
        current_branch = current_branch_result.stdout.strip()

        # Get the last commit ID on the current branch
        last_commit_id_command = ["git", "rev-parse", current_branch]
        last_commit_result = subprocess.run(
            last_commit_id_command, check=True, capture_output=True, text=True
        )
        last_commit = last_commit_result.stdout.strip()[:7]

        return current_branch, last_commit
    except subprocess.CalledProcessError as e:
        logging.error(f"Error in Git command: {e.stderr}")
        raise Exception(f"Git command failed: {e.stderr}")


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


if __name__ == "__main__":
    score_history_df = pd.read_csv(SCORE_HISTORY_PATH, sep=",")
    examples_textile = load_json(EXAMPLES_TEXTILE_PATH)
    current_branch, last_commit = get_last_commit()
    commit_is_new = is_new_commit(score_history_df, last_commit)

    if commit_is_new:
        logging.info(f"computing score for {current_branch}")
        new_score_df = compute_new_score(examples_textile, current_branch, last_commit)

        no_previou_score, previous_score_df = get_previous_score(
            score_history_df, current_branch
        )
        score_is_different = compare_scores_with_tolerance(
            previous_score_df, new_score_df
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
