import uuid
from django.db import models
from django.utils.translation import gettext_lazy as _
from mailauth.contrib.user.models import AbstractEmailUser


class EcobalyseUser(AbstractEmailUser):
    organization = models.CharField(_("Company"), max_length=150, blank=True, null=True)
    terms_of_use = models.BooleanField(default=False)
    token = models.CharField(
        _("TOKEN"), max_length=36, default=uuid.uuid4, editable=False
    )
