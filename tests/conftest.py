from __future__ import annotations

import pytest

pytestmark = pytest.mark.anyio

pytest_plugins = [
    "tests.backend.data_fixtures",
    "pytest_databases.docker",
    "pytest_databases.docker.postgres",
]
