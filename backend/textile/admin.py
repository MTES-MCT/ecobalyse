import json

from django import forms
from django.contrib import admin, messages
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.urls import path
from django.utils.translation import gettext_lazy as _

from backend.admin import admin_site
from textile.models import Example, Material, Process, Product


class ProductAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]


class MaterialsInline(admin.TabularInline):
    model = Example.materials.through


class MaterialAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]
    # inlines = [MaterialsInline]


class ProcessAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]


class ExampleJSONForm(forms.ModelForm):
    class Meta:
        model = Example
        fields = ["id", "name"]

    query = forms.JSONField()


class ExampleAdmin(admin.ModelAdmin):
    search_fields = ["name"]
    inlines = [MaterialsInline]
    change_list_template = "admin/textile/example/change_list.html"
    save_on_top = True

    def get_urls(self):
        return [
            path(
                "from-json/",
                self.admin_site.admin_view(self.from_json),
                name="from-json",
            )
        ] + super().get_urls()

    def from_json(self, request):
        """/admin/textile/example/from-json/ form"""
        if request.method == "POST":
            form = ExampleJSONForm(request.POST)
            if form.is_valid():
                json_example = {
                    "id": request.POST["id"],
                    "name": request.POST["name"],
                    "category": request.POST["category"],
                    "query": json.loads(request.POST["query"]),
                }
                try:
                    example = Example._fromJSON(json_example)
                    example.save()

                    for share in json_example["query"]["materials"]:
                        example.add_material(share)
                    self.message_user(request, _("Your Example has been recorded"))
                    return HttpResponseRedirect("..")
                except TypeError:
                    self.message_user(
                        request,
                        _("Your JSON doesn't look like a valid example"),
                        level=messages.ERROR,
                    )
        else:
            form = ExampleJSONForm()
        context = dict(self.admin_site.each_context(request), form=form)
        return render(request, "admin/textile/example/from_json.html", context)


admin_site.register(Product, ProductAdmin)
admin_site.register(Material, MaterialAdmin)
admin_site.register(Process, ProcessAdmin)
admin_site.register(Example, ExampleAdmin)
