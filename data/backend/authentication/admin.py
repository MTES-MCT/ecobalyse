from django.contrib import admin
from django.contrib.auth.admin import GroupAdmin
from django.contrib.auth.models import Group, Permission
from django.utils.translation import gettext_lazy as _
from backend.admin import admin_site
from authentication.models import EcobalyseUser
from mailauth.contrib.user.admin import AnonymizableAdminMixin


class EcobalyseUserAdmin(AnonymizableAdminMixin, admin.ModelAdmin):
    list_display = ("email", "first_name", "last_name", "is_staff")
    list_filter = ("is_staff", "is_superuser", "is_active", "groups")
    search_fields = ("first_name", "last_name", "email")
    ordering = ("email",)
    filter_horizontal = (
        "groups",
        "user_permissions",
    )

    fieldsets = (
        (
            None,
            {
                "fields": (
                    ("email", "is_active"),
                    ("first_name", "last_name"),
                    ("company", "terms_of_use"),
                    ("token"),
                )
            },
        ),
        (
            Group._meta.verbose_name_plural,
            {
                "fields": ("groups",),
            },
        ),
        (
            Permission._meta.verbose_name_plural,
            {
                "classes": ("collapse",),
                "fields": (("is_staff", "is_superuser"), "user_permissions"),
            },
        ),
    )

    readonly_fields = ("token",)


admin_site.register(EcobalyseUser, EcobalyseUserAdmin)
admin_site.register(Group, GroupAdmin)
