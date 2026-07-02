# type: ignore
"""elec_mj => elec_kwh

Revision ID: e93537b074f9
Revises: 21f0598992ca
Create Date: 2026-06-22 22:47:13.569434
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
revision = "e93537b074f9"
down_revision = "06e520393a50"
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
    op.alter_column("process", "elec_mj", new_column_name="elec_kwh")


def schema_downgrades() -> None:
    op.alter_column("process", "elec_kwh", new_column_name="elec_mj")


def data_upgrades() -> None:
    # Converting from MJ to kWh
    # The field was already renamed (see the `upgrade` function)
    op.execute("""
      UPDATE process
      SET elec_kwh=elec_kwh/3.6
      WHERE elec_kwh is not NULL
      """)


def data_downgrades() -> None:
    # Converting from kWh to MJ
    # The field will be renamed afterwards (see the `downgrade` function)
    op.execute("""
      UPDATE process
      SET elec_kwh=elec_kwh * 3.6
      WHERE elec_kwh is not NULL
      """)
