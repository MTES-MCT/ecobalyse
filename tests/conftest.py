from __future__ import annotations

import pytest

pytestmark = pytest.mark.anyio

pytest_plugins = [
    "backend.tests.data_fixtures",
    "pytest_databases.docker",
    "pytest_databases.docker.postgres",
]
