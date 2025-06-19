from __future__ import annotations

from typing import Any

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import JsonB
from app.domain.components.schemas import Scope
from sqlalchemy import Enum
from sqlalchemy.dialects import postgresql
from sqlalchemy.ext.mutable import MutableList
from sqlalchemy.orm import Mapped, mapped_column


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Component(UUIDAuditBase):
    __tablename__ = "component"
    elements: Mapped[dict[str, Any] | None] = mapped_column(JsonB)
    name: Mapped[str]

    # Note: when creating the migration Alembic will not detect the scope[] type
    # we need to create it manually in the generated migration
    # See https://stackoverflow.com/questions/37848815/sqlalchemy-postgresql-enum-does-not-create-type-on-db-migrate
    #
    # scope = postgresql.ENUM("food", "object", "textile", "veli", name="scope")
    # scope.create(batch_op.get_bind())
    #
    # And to drop it:
    # sa.Enum(name="scope").drop(op.get_bind(), checkfirst=False)

    scopes: Mapped[list[Scope]] = mapped_column(
        # See https://docs.sqlalchemy.org/en/20/dialects/postgresql.html#postgresql-data-types
        # For the mutable trick
        MutableList.as_mutable(
            postgresql.ARRAY(Enum(Scope, values_callable=get_enum_values), dimensions=1)
        ),
        default=[],
    )
