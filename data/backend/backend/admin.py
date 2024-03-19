from django.contrib import admin
from django.contrib.auth.admin import GroupAdmin
from django.contrib.auth.models import Group
from django.contrib.auth import get_user_model


class MyAdminSite(admin.AdminSite):
    site_header = "Ecobalyse administration"
    site_title = "Ecobalyse backend"
    index_title = "Ecobalyse administration"


admin_site = MyAdminSite(name="myadmin")
admin_site.register(Group, GroupAdmin)
user_model = get_user_model()
useradmin_model = admin.site._registry[user_model].__class__
admin_site.register(user_model, useradmin_model)
