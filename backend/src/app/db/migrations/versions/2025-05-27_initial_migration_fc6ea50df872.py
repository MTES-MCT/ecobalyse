# type: ignore
"""Initial migration

Revision ID: fc6ea50df872
Revises:
Create Date: 2025-05-27 14:40:24.575062

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
revision = "fc6ea50df872"
down_revision = None
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
    op.create_table(
        "component",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column(
            "elements",
            sa.JSON()
            .with_variant(postgresql.JSONB(astext_type=Text()), "cockroachdb")
            .with_variant(sa.ORA_JSONB(), "oracle")
            .with_variant(postgresql.JSONB(astext_type=Text()), "postgresql"),
            nullable=True,
        ),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_component")),
    )
    op.create_table(
        "process",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("display", sa.String(), nullable=True),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_process")),
    )
    op.create_table(
        "role",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=True),
        sa.Column("slug", sa.String(length=100), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_role")),
        sa.UniqueConstraint("name"),
        sa.UniqueConstraint("name", name=op.f("uq_role_name")),
        sa.UniqueConstraint("slug", name="uq_role_slug"),
    )
    with op.batch_alter_table("role", schema=None) as batch_op:
        batch_op.create_index("ix_role_slug_unique", ["slug"], unique=True)

    op.create_table(
        "user_account",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("email", sa.String(), nullable=False),
        sa.Column("magic_link_hashed_token", sa.String(length=255), nullable=True),
        sa.Column("magic_link_sent_at", sa.DateTimeUTC(timezone=True), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("is_superuser", sa.Boolean(), nullable=False),
        sa.Column("is_verified", sa.Boolean(), nullable=False),
        sa.Column("verified_at", sa.Date(), nullable=True),
        sa.Column("joined_at", sa.Date(), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_account")),
    )
    with op.batch_alter_table("user_account", schema=None) as batch_op:
        batch_op.create_index(
            batch_op.f("ix_user_account_email"), ["email"], unique=True
        )

    op.create_table(
        "token",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("user_id", sa.GUID(length=16), nullable=False),
        sa.Column("hashed_token", sa.String(length=255), nullable=True),
        sa.Column("last_accessed_at", sa.DateTimeUTC(timezone=True), nullable=True),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["user_account.id"],
            name=op.f("fk_token_user_id_user_account"),
            ondelete="cascade",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_token")),
    )
    op.create_table(
        "user_account_profile",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("user_id", sa.GUID(length=16), nullable=False),
        sa.Column("first_name", sa.String(), nullable=True),
        sa.Column("last_name", sa.String(), nullable=True),
        sa.Column("organization_type", sa.String(), nullable=False),
        sa.Column("organization_name", sa.String(), nullable=True),
        sa.Column("organization_siren", sa.String(), nullable=True),
        sa.Column("terms_accepted", sa.Boolean(), nullable=False),
        sa.Column("email_optin", sa.Boolean(), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["user_account.id"],
            name=op.f("fk_user_account_profile_user_id_user_account"),
            ondelete="cascade",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_account_profile")),
    )
    op.create_table(
        "user_account_role",
        sa.Column("id", sa.GUID(length=16), nullable=False),
        sa.Column("user_id", sa.GUID(length=16), nullable=False),
        sa.Column("role_id", sa.GUID(length=16), nullable=False),
        sa.Column("assigned_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("sa_orm_sentinel", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTimeUTC(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(
            ["role_id"],
            ["role.id"],
            name=op.f("fk_user_account_role_role_id_role"),
            ondelete="cascade",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["user_account.id"],
            name=op.f("fk_user_account_role_user_id_user_account"),
            ondelete="cascade",
        ),
        sa.PrimaryKeyConstraint("id", name=op.f("pk_user_account_role")),
    )
    # ### end Alembic commands ###


def schema_downgrades() -> None:
    """schema downgrade migrations go here."""
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table("user_account_role")
    op.drop_table("user_account_profile")
    op.drop_table("token")
    with op.batch_alter_table("user_account", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_user_account_email"))

    op.drop_table("user_account")
    with op.batch_alter_table("role", schema=None) as batch_op:
        batch_op.drop_index("ix_role_slug_unique")

    op.drop_table("role")
    op.drop_table("process")
    op.drop_table("component")
    # ### end Alembic commands ###


def data_upgrades() -> None:
    """Add any optional data upgrade migrations here!"""


def data_downgrades() -> None:
    """Add any optional data downgrade migrations here!"""
