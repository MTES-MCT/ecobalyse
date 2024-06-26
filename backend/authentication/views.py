import json
import logging

from django.conf import settings
from django.core.exceptions import PermissionDenied
from django.http import Http404, JsonResponse, response
from django.utils.translation import gettext_lazy as _
from mailauth.views import (
    LoginTokenView as MailauthLoginTokenView,
)
from mailauth.views import (
    LoginView as MailauthLoginView,
)

from authentication.models import EcobalyseUser

from .forms import EmailLoginForm, RegistrationForm

logger = logging.getLogger(__name__)


def register(request):
    """render a form to provide an email to register"""
    if request.method == "POST":
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
    else:
        raise Http404("Only POST here")


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


def profile(request):
    if request.method == "GET":
        u = request.user
        if u.is_authenticated:
            return JsonResponse(
                {
                    "email": u.email,
                    "first_name": u.first_name,
                    "last_name": u.last_name,
                    "organization": u.organization,
                    "terms_of_use": u.terms_of_use,
                    "token": u.token,
                }
            )
        else:
            return JsonResponse(
                {"error": _("You must be authenticated to access this page")},
                status=401,
            )


def is_token_valid(token):
    return EcobalyseUser.objects.filter(token=token).count() > 0


class EcobalyseLoginTokenView(
    MailauthLoginTokenView,
):
    def get(self, request, *a, **kwargs):
        try:
            return super().get(request, *a, **kwargs)
        except PermissionDenied:
            return response.HttpResponseRedirect("/#/auth/")
