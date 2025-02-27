import json

from django import forms
from django.contrib import admin, messages
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.urls import path, reverse
from django.utils.html import format_html
from django.utils.translation import gettext_lazy as _

from backend.admin import admin_site
from textile.models import Example, Material, Process, Product


class ProductAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]
    list_display = ("name", "id", "mass", "volume")
    fieldsets = [
        (None, {"fields": ("name", "id", "mass", "surfaceMass", "yarnSize", "fabric")}),
        (
            _("Economics"),
            {
                "fields": (
                    "business",
                    "marketingDuration",
                    "numberOfReferences",
                    "price",
                    "repairCost",
                    "traceability",
                )
            },
        ),
        (_("Dyeing"), {"fields": ("defaultMedium",)}),
        (_("Making"), {"fields": ("pcrWaste", "complexity")}),
        (
            _("Use"),
            {
                "fields": (
                    "ironingElecInMJ",
                    "nonIroningProcessUuid",
                    "daysOfWear",
                    "defaultNbCycles",
                    "ratioDryer",
                    "ratioIroning",
                    "timeIroning",
                    "wearsPerCycle",
                )
            },
        ),
        (_("End Of Life"), {"fields": ("volume",)}),
    ]


class MaterialsInline(admin.TabularInline):
    model = Example.materials.through


class MaterialAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]
    list_display = ("name", "shortName", "id", "related_process")

    def related_process(self, obj):
        url = reverse(
            "admin:textile_process_change", args=(obj.materialProcessUuid.pk,)
        )
        return format_html(f'<a href="{url}">{obj.materialProcessUuid.name}</a>')

    related_process.allow_tags = True
    fieldsets = [
        (None, {"fields": ("name", "shortName", "origin", "priority")}),
        (
            _("Processes"),
            {"fields": ("materialProcessUuid", "recycledProcessUuid", "recycledFrom")},
        ),
        (_("Geography"), {"fields": ("geographicOrigin", "defaultCountry")}),
        (_("Other"), {"fields": ("manufacturerAllocation", "recycledQualityRatio")}),
    ]


class ProcessAdmin(admin.ModelAdmin):
    save_on_top = True
    search_fields = ["name"]
    list_display = ("name", "source", "uuid", "step_usage")
    fieldsets = [
        (
            None,
            {
                "fields": (
                    "name",
                    "uuid",
                    "source",
                    "search",
                    "info",
                    "unit",
                    "step_usage",
                    "correctif",
                )
            },
        ),
        (_("Energy"), {"fields": ("heatMJ", "elec_pppm", "elecMJ")}),
        (_("Scores"), {"fields": ("pef", "ecs")}),
        (
            _("Impacts"),
            {
                "fields": (
                    "acd",
                    "cch",
                    "etf",
                    "etfc",
                    "fru",
                    "fwe",
                    "htc",
                    "htcc",
                    "htn",
                    "htnc",
                    "ior",
                    "ldu",
                    "mru",
                    "ozd",
                    "pco",
                    "pma",
                    "swe",
                    "tre",
                    "wtu",
                )
            },
        ),
    ]


class ExampleJSONForm(forms.ModelForm):
    class Meta:
        model = Example
        fields = ["id", "name", "product"]

    query = forms.JSONField()


class ExampleAdmin(admin.ModelAdmin):
    search_fields = ["name"]
    inlines = [MaterialsInline]
    change_list_template = "admin/textile/example/change_list.html"
    save_on_top = True
    list_display = ("name", "id", "product")
    fieldsets = [
        (None, {"fields": ["id", "name", "mass"]}),
        (
            "Durabilité non-physique",
            {
                "fields": [
                    "product",
                    "numberOfReferences",
                    "price",
                    "marketingDuration",
                    "business",
                    "traceability",
                    "repairCost",
                ],
                "description": "Paramètres de durabilité non-physique. Voir la <a href='https://fabrique-numerique.gitbook.io/ecobalyse/textile/durabilite'>Documentation</a>",
            },
        ),
        (
            "Filature",
            {
                "fields": [
                    "countrySpinning",
                ],
                "description": "<a href='https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new'>Documentation</a>",
            },
        ),
        (
            "Fabrication",
            {
                "fields": [
                    "fabricProcess",
                    "countryFabric",
                ],
                "description": "<a href='https://fabrique-numerique.gitbook.io/ecobalyse/textile/cycle-de-vie-des-produits-textiles/etape-2-fabrication-du-fil'>Documentation</a>",
            },
        ),
        (
            "Confection",
            {
                "fields": [
                    "airTransportRatio",
                    "countryMaking",
                ],
                "description": "<a href='https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/confection'>Documentation</a>",
            },
        ),
        (
            "Ennoblissement",
            {
                "fields": [
                    "countryDyeing",
                ],
                "description": "<a href='https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/ennoblissement'>Documentation</a>",
            },
        ),
    ]

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
                    "product": request.POST["product"],
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
