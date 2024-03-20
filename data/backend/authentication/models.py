from django.db import models
from django.utils.translation import gettext_lazy as _
from mailauth.contrib.user.models import AbstractEmailUser


class EcobalyseUser(AbstractEmailUser):
    company = models.CharField(_("Company"), max_length=150, blank=True)
    terms_of_use = models.BooleanField(default=False)