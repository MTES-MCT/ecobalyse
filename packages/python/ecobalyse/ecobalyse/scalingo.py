import logging

import requests
from requests.auth import HTTPBasicAuth

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config

logger = logging.getLogger(__name__)


def get_bearer_token(api_token: str) -> str:
    logging.info("-> Getting Bearer token")
    basic = HTTPBasicAuth("", api_token)
    endpoint = "https://auth.scalingo.com/v1/tokens/exchange"
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    response = requests.post(endpoint, auth=basic, headers=headers)

    return response.json()["token"]


def list_logs_archives(bearer_token: str, application: str = "ecobalyse") -> dict:
    logging.info("-> Listing log archives")

    endpoint = f"https://api.osc-fr1.scalingo.com/v1/apps/{application}/logs_archives"
    headers = {
        "Accept": "application/json",
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json",
    }
    response = requests.get(endpoint, headers=headers)
    return response.json()
