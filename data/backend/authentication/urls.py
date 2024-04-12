from django.urls import include, path, re_path

from . import views
from .views import RegistrationRequestedView, profile, register

urlpatterns = [
    path("login/", views.LoginView.as_view(), name="login"),
    path("login.json/", views.LoginView.as_view(), name="login_json"),
    path("", include("mailauth.urls")),
    path(
        "register/success/",
        RegistrationRequestedView.as_view(),
        name="registration-requested",
    ),
    path("register/", register, name="register"),
    path("register.json/", register, name="register_json"),
    re_path(
        "register/(?P<token>.*)$",
        views.Activate.as_view(),
        name="register-activate",
    ),
    path("profile.json/", profile, name="profile"),
]
