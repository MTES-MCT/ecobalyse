from __future__ import annotations

from typing import TYPE_CHECKING

from advanced_alchemy.base import UUIDAuditBase
from app.domain.components.schemas import Scope
from sqlalchemy import Enum
from sqlalchemy.dialects import postgresql
from sqlalchemy.ext.mutable import MutableList
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .element import Element


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Component(UUIDAuditBase):
    __tablename__ = "component"
    name: Mapped[str]
    comment: Mapped[str | None]

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

    elements: Mapped[list[Element]] = relationship(
        back_populates="component",
        lazy="selectin",
        uselist=True,
        cascade="all, delete-orphan",
    )

    def __repr__(self) -> str:
        return f"Component(id={self.id!r}, name={self.name!r}, comment={self.comment!r}, scopes={self.scopes!r}, elements={self.elements!r})"
