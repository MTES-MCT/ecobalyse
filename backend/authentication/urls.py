from django.urls import include, path

from . import views
from .views import profile, register

urlpatterns = [
    path("login/", views.LoginView.as_view(), name="login"),
    path("", include("mailauth.urls")),
    path("register/", register, name="register"),
    path("profile/", profile, name="profile"),
]
