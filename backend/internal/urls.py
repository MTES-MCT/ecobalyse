from django.urls import path

from .views import check_token

urlpatterns = [path("check_token", check_token)]
