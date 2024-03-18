from django.contrib import admin
from .models import Process, Material, Product, Example


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


admin.site.register(Product, ProductAdmin)
admin.site.register(Material, MaterialAdmin)
admin.site.register(Process, ProcessAdmin)
admin.site.register(Example, ExempleAdmin)
