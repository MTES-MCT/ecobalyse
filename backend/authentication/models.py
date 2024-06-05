import uuid

from django.db.models import BooleanField, CharField
from django.utils.translation import gettext_lazy as _
from mailauth.contrib.user.models import AbstractEmailUser


class EcobalyseUser(AbstractEmailUser):
    organization = CharField(_("Organization"), max_length=150, blank=True, default="")
    terms_of_use = BooleanField(default=False)
    token = CharField(
        _("TOKEN"), max_length=36, default=uuid.uuid4, editable=False, db_index=True
    )
