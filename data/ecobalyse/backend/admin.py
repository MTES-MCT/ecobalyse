from django.contrib import admin
from .models import Process, Material, Product, Exemple


class ProductAdmin(admin.ModelAdmin):
    pass


class MaterialAdmin(admin.ModelAdmin):
    pass


class ProcessAdmin(admin.ModelAdmin):
    pass


class ExempleAdmin(admin.ModelAdmin):
    pass


admin.site.register(Product, ProductAdmin)
admin.site.register(Material, MaterialAdmin)
admin.site.register(Process, ProcessAdmin)
admin.site.register(Exemple, ExempleAdmin)
