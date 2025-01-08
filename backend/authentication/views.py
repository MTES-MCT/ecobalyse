import json
import logging

from django.conf import settings
from django.core.exceptions import PermissionDenied
from django.http import JsonResponse, response
from django.utils.translation import gettext_lazy as _
from django.views.decorators.http import require_http_methods
from mailauth.views import (
    LoginTokenView as MailauthLoginTokenView,
)
from mailauth.views import (
    LoginView as MailauthLoginView,
)

from .forms import EmailLoginForm, RegistrationForm

logger = logging.getLogger(__name__)


def authenticated_user(view_func):
    def wrapper_func(request, *args, **kwargs):
        if request.user.is_authenticated:
            return view_func(request, *args, **kwargs)

        else:
            return JsonResponse(
                {"error": _("You must be authenticated to access this page")},
                status=401,
            )

    return wrapper_func


@require_http_methods(["POST"])
def register(request):
    """render a form to provide an email to register"""
    try:
        form = RegistrationForm(
            request=request, data=json.loads(request.body.decode("utf-8"))
        )
    except json.JSONDecodeError:
        return JsonResponse(
            {"success": False, "msg": _("Invalid json in the POST request")}
        )
    if form.is_valid():
        form.save()
        timeout = settings.LOGIN_URL_TIMEOUT
        return JsonResponse(
            {
                "success": True,
                "msg": _("The link is valid for %d min") % (timeout / 60)
                if timeout is not None
                else _("The link does not expire"),
            }
        )
    else:
        errors = {
            k: " ".join(v) for k, v in (form.errors.items() if form.errors else [])
        }
        if (
            errors.get("email")
            == "Un objet Utilisateur avec ce champ Adresse électronique existe déjà."
        ):
            errors["email"] = _(
                "You seem already registered. Try using the connection tab."
            )
        return JsonResponse(
            {
                "success": False,
                "msg": _("Your form has errors: ")
                + " ".join([f"{k}: {v}" for k, v in errors.items()]),
                "errors": errors,
            }
        )


class LoginView(MailauthLoginView):
    extra_context = {
        "site_header": "Ecobalyse",
        "site_title": "Ecobalyse",
        "title": _("Login"),
    }

    def post(self, request, *a, **kw):
        form = EmailLoginForm(
            request=request, data=json.loads(request.body.decode("utf-8"))
        )
        if form.is_valid():
            form.save()
            timeout = settings.LOGIN_URL_TIMEOUT
            return JsonResponse(
                {
                    "success": True,
                    "msg": (_("The link is valid for %d min") % (timeout / 60))
                    if timeout is not None
                    else _("The link does not expire"),
                }
            )
        else:
            return JsonResponse({"success": False, "msg": _("Invalid form data")})


@require_http_methods(["GET"])
@authenticated_user
def profile(request):
    u = request.user
    return JsonResponse(
        {
            "email": u.email,
            "first_name": u.first_name,
            "last_name": u.last_name,
            "organization": u.organization,
            "staff": u.is_staff,
            "terms_of_use": u.terms_of_use,
            "token": u.token,
        }
    )


class EcobalyseLoginTokenView(
    MailauthLoginTokenView,
):
    def get(self, request, *a, **kwargs):
        try:
            return super().get(request, *a, **kwargs)
        except PermissionDenied:
            return response.HttpResponseRedirect("/#/auth/")
