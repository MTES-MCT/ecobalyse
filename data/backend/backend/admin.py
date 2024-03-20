from django.contrib import admin
from mailauth.contrib.admin.views import AdminLoginView


class MyAdminSite(admin.AdminSite):
    site_header = "Ecobalyse administration"
    site_title = "Ecobalyse backend"
    index_title = "Ecobalyse administration"


admin_site = MyAdminSite(name="myadmin")
admin_site.login = AdminLoginView.as_view(site=admin_site)
