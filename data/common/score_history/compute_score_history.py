import json
import logging
import pandas as pd
import requests
import subprocess
import time
from datetime import datetime

# Constants
SCORE_HISTORY_PATH = "./data/common/score_history/score_history.csv"
TEST_BRANCH = {"name": "backend-authentication", "pr_number": 531}

BRANCHES = ["master", TEST_BRANCH["name"]]
BRANCH_URL_DIC = {
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


def compute_score_new(examples, branches):
    simulations = []
    for branch_name in branches:
        branch_url = BRANCH_URL_DIC.get(branch_name, "")
        normalization_factors = compute_normalization_factors(branch_name)
        for example in examples:
            if example["name"] == "Produit vide":
                continue
            try:
                simulation_result = simulate_example(
                    branch_name, branch_url, example, normalization_factors
                )
                simulations.append(simulation_result)
            except Exception as e:
                logging.error(
                    f"Error simulating example {example['name']} on branch {branch_name}: {e}"
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


def get_branch_commits():
    """Retrieve the last commit IDs for the current and master branches."""
    current_branch_command = ["git", "branch", "--show-current"]
    branches_last_commit = {}
    try:
        current_branch_result = subprocess.run(
            current_branch_command, check=True, capture_output=True, text=True
        )
        current_branch = current_branch_result.stdout.strip()
        branches_last_commit[current_branch] = get_last_commit_id(
            current_branch, fetch=True
        )
    except subprocess.CalledProcessError as e:
        logging.error(f"Error determining the current branch: {e.stderr}")
        raise
    return branches_last_commit


def compute_branches_to_score(score_history_df, branches_last_commit):
    """Determine which branches need their scores computed."""
    branches_to_compute = []
    for branch, last_commit in branches_last_commit.items():
        if score_history_df["commit"].isin([last_commit]).any():
            branches_to_compute.append(branch)
    return branches_to_compute


if __name__ == "__main__":

    score_history_df = pd.read_csv(SCORE_HISTORY_PATH, sep=",")
    examples_textile = load_json(EXAMPLES_TEXTILE_PATH)
    branches_last_commit = get_branch_commits()
    branches_to_compute = compute_branches_to_score(
        score_history_df, branches_last_commit
    )

    score_new_df = compute_score_new(examples_textile, branches_to_compute)
    score_history_updated_df = pd.concat(
        [score_history_df, score_new_df], ignore_index=True
    )
    score_history_updated_df.to_csv(
        SCORE_HISTORY_PATH, index=False, encoding="utf-8-sig"
    )
