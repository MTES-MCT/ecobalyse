from . import views
from .views import register, RegistrationRequestedView, profile
from django.urls import include, path, re_path


urlpatterns = [
    # to override a path, put the original after the modified one
    path("", include("mailauth.urls")),
    path(
        "register/success/",
        RegistrationRequestedView.as_view(),
        name="registration-requested",
    ),
    path("register/", register, name="register"),
    re_path(
        "register/(?P<token>.*)$",
        views.Activate.as_view(),
        name="register-activate",
    ),
    path("profile.json/", profile, name="profile"),
]
