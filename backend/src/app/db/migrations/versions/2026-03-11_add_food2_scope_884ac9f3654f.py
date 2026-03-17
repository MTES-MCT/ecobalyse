# type: ignore
"""add food2 scope

Revision ID: 884ac9f3654f
Revises: af8f29751a13
Create Date: 2026-03-11 16:30:14.130973

"""

import warnings

import sqlalchemy as sa
from advanced_alchemy.types import (
    GUID,
    ORA_JSONB,
    DateTimeUTC,
    EncryptedString,
    EncryptedText,
)
from alembic import op
from sqlalchemy import Text  # noqa: F401

__all__ = [
    "downgrade",
    "upgrade",
    "schema_upgrades",
    "schema_downgrades",
    "data_upgrades",
    "data_downgrades",
]

sa.GUID = GUID
sa.DateTimeUTC = DateTimeUTC
sa.ORA_JSONB = ORA_JSONB
sa.EncryptedString = EncryptedString
sa.EncryptedText = EncryptedText

# revision identifiers, used by Alembic.
revision = "884ac9f3654f"
down_revision = "af8f29751a13"
branch_labels = None
depends_on = None


def upgrade() -> None:
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=UserWarning)
        with op.get_context().autocommit_block():
            schema_upgrades()
            data_upgrades()


def downgrade() -> None:
    with warnings.catch_warnings():
        warnings.filterwarnings("ignore", category=UserWarning)
        with op.get_context().autocommit_block():
            data_downgrades()
            schema_downgrades()


def schema_upgrades() -> None:
    """schema upgrade migrations go here."""

    # As the new value can’t be easily removed while downgrading, just ignore it
    # in case the upgrade was already applied.
    op.execute("ALTER TYPE scope ADD VALUE IF NOT EXISTS 'food2' AFTER 'food'")


def schema_downgrades() -> None:
    """schema downgrade migrations go here."""
    # Droping enum values is not supported
    # https://www.postgresql.org/docs/current/datatype-enum.html#DATATYPE-ENUM-IMPLEMENTATION-DETAILS
    pass


def data_upgrades() -> None:
    """Add any optional data upgrade migrations here!"""


def data_downgrades() -> None:
    """Add any optional data downgrade migrations here!"""
