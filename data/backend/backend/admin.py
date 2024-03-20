from django.contrib import admin
from django.contrib.auth.admin import GroupAdmin
from django.contrib.auth.models import Group
from django.contrib.auth import get_user_model
from mailauth.contrib.admin.views import AdminLoginView


class MyAdminSite(admin.AdminSite):
    site_header = "Ecobalyse administration"
    site_title = "Ecobalyse backend"
    index_title = "Ecobalyse administration"


admin_site = MyAdminSite(name="myadmin")
User = get_user_model()
UserAdmin = admin.site._registry[User].__class__
admin_site.login = AdminLoginView.as_view(site=admin_site)

admin_site.register(User, UserAdmin)
admin_site.register(Group, GroupAdmin)
