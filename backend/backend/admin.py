from django.contrib import admin
from django.utils.translation import gettext_lazy as _
from mailauth.contrib.admin.views import AdminLoginView


class AdminSite(admin.AdminSite):
    site_header = _("Ecobalyse administration")
    site_title = _("Ecobalyse backend")
    index_title = _("Ecobalyse administration")


admin_site = AdminSite(name="admin")
admin_site.login = AdminLoginView.as_view(site=admin_site)
