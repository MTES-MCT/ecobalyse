from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from app.config import base

if TYPE_CHECKING:
    from pytest import MonkeyPatch


@pytest.fixture(scope="session")
def anyio_backend() -> str:
    return "asyncio"


@pytest.fixture(autouse=True)
def _patch_settings(monkeypatch: MonkeyPatch) -> None:
    """Patch the settings."""

    def get_settings(dotenv_filename: str = ".env.testing") -> base.Settings:
        settings = base.Settings.from_env(dotenv_filename)
        return settings

    monkeypatch.setattr(base, "get_settings", get_settings)
