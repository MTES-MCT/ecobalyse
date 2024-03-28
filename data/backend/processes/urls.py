from django.urls import path
from .views import processes

urlpatterns = [
    path("processes.json", processes),
]
