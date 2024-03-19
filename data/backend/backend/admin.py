from django.contrib import admin
from django.contrib.auth.admin import UserAdmin, GroupAdmin
from django.contrib.auth.models import Group, User


class MyAdminSite(admin.AdminSite):
    site_header = "Ecobalyse administration"
    site_title = "Ecobalyse backend"
    index_title = "Ecobalyse administration"


admin_site = MyAdminSite(name="myadmin")
admin_site.register(Group, GroupAdmin)
admin_site.register(User, UserAdmin)
