from django.urls import include, path, re_path

from . import views
from .views import profile, register

urlpatterns = [
    path("login/", views.LoginView.as_view(), name="login"),
    re_path(
        "login/(?P<token>.*)$",
        views.EcobalyseLoginTokenView.as_view(),
        name="login-token",
    ),
    path("", include("mailauth.urls")),
    path("register/", register, name="register"),
    path("profile/", profile, name="profile"),
]
