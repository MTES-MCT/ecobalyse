# type: ignore
"""Add scopes

Revision ID: f3596fc1e583
Revises: fc6ea50df872
Create Date: 2025-06-18 15:22:25.677495

"""

import warnings
from typing import TYPE_CHECKING

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
from sqlalchemy.dialects import postgresql

if TYPE_CHECKING:
    pass

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
revision = "f3596fc1e583"
down_revision = "fc6ea50df872"
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
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table("component", schema=None) as batch_op:
        scope = postgresql.ENUM("food", "object", "textile", "veli", name="scope")
        scope.create(batch_op.get_bind())

        batch_op.add_column(
            sa.Column(
                "scopes",
                postgresql.ARRAY(
                    sa.Enum("food", "object", "textile", "veli", name="scope"),
                    dimensions=1,
                ),
                nullable=False,
            )
        )

    with op.batch_alter_table("token", schema=None) as batch_op:
        batch_op.create_table_comment("Tokens for API access", existing_comment=None)

    with op.batch_alter_table("user_account", schema=None) as batch_op:
        batch_op.create_table_comment(
            "User accounts for application access", existing_comment=None
        )

    with op.batch_alter_table("user_account_profile", schema=None) as batch_op:
        batch_op.create_table_comment(
            "Profile details for a specific user.", existing_comment=None
        )

    with op.batch_alter_table("user_account_role", schema=None) as batch_op:
        batch_op.create_table_comment(
            "Links a user to a specific role.", existing_comment=None
        )

    # ### end Alembic commands ###


def schema_downgrades() -> None:
    """schema downgrade migrations go here."""
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table("user_account_role", schema=None) as batch_op:
        batch_op.drop_table_comment(existing_comment="Links a user to a specific role.")

    with op.batch_alter_table("user_account_profile", schema=None) as batch_op:
        batch_op.drop_table_comment(
            existing_comment="Profile details for a specific user."
        )

    with op.batch_alter_table("user_account", schema=None) as batch_op:
        batch_op.drop_table_comment(
            existing_comment="User accounts for application access"
        )

    with op.batch_alter_table("token", schema=None) as batch_op:
        batch_op.drop_table_comment(existing_comment="Tokens for API access")

    with op.batch_alter_table("component", schema=None) as batch_op:
        batch_op.drop_column("scopes")

    sa.Enum(name="scope").drop(op.get_bind(), checkfirst=False)

    # ### end Alembic commands ###


def data_upgrades() -> None:
    """Add any optional data upgrade migrations here!"""


def data_downgrades() -> None:
    """Add any optional data downgrade migrations here!"""
