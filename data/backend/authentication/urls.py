from django.urls import path, include
from .views import register, RegistrationSuccessView

urlpatterns = [
    path("accounts/", include("mailauth.urls")),
    path("accounts/register/", register, name="register"),
    path(
        "accounts/register/success",
        RegistrationSuccessView.as_view(),
        name="registration-success",
    ),
]
