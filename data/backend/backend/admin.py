from django.contrib import admin


class MyAdminSite(admin.AdminSite):
    site_header = "Ecobalyse administration"
    site_title = "Ecobalyse backend"
    index_title = "Ecobalyse administration"


admin_site = admin.site  # MyAdminSite(name="myadmin")
