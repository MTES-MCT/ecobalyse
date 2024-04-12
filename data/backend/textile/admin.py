from backend.admin import admin_site
from django.contrib import admin

from textile.models import Example, Material, Process, Product


class ProductAdmin(admin.ModelAdmin):
    search_fields = ["name"]


class MaterialsInline(admin.TabularInline):
    model = Example.materials.through


class MaterialAdmin(admin.ModelAdmin):
    search_fields = ["name"]
    # inlines = [MaterialsInline]


class ProcessAdmin(admin.ModelAdmin):
    search_fields = ["name"]


class ExempleAdmin(admin.ModelAdmin):
    search_fields = ["name"]
    inlines = [MaterialsInline]


admin_site.register(Product, ProductAdmin)
admin_site.register(Material, MaterialAdmin)
admin_site.register(Process, ProcessAdmin)
admin_site.register(Example, ExempleAdmin)
