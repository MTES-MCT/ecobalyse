from . import views
from .views import register, RegistrationRequestedView, profile, check_token
from django.urls import include, path, re_path


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
    path("check_token/", check_token, name="check_token"),
]
