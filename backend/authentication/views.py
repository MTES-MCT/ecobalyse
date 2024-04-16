import json
import logging

from django.conf import settings
from django.contrib.auth import authenticate, login
from django.core.exceptions import PermissionDenied
from django.http import Http404, JsonResponse, response
from django.utils.translation import gettext_lazy as _
from django.views import generic
from mailauth import signing
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
            return JsonResponse(
                {
                    "success": True,
                    "msg": _("The link is valid for %d min")
                    % (getattr(settings, "LOGIN_URL_TIMEOUT", 900) / 60),
                }
            )
        else:
            errors = {
                k: " ".join(v) for k, v in (form.errors.items() if form.errors else [])
            }
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
            return JsonResponse(
                {
                    "success": True,
                    "msg": _("The link is valid for %d min")
                    % (getattr(settings, "LOGIN_URL_TIMEOUT", 900) / 60),
                }
            )
        else:
            return JsonResponse({"success": False, "msg": _("Invalid form data")})


class RegistrationRequestedView(generic.TemplateView):
    """confirmation that the email has beed stored"""

    template_name = "registration/registration_requested.html"


class Activate(MailauthLoginTokenView):
    """login and activate the disabled account"""

    signer = signing.UserSigner()
    max_age = getattr(settings, "LOGIN_URL_TIMEOUT", 60 * 15)
    single_use = getattr(settings, "LOGIN_TOKEN_SINGLE_USE", True)
    success_url = getattr(settings, "LOGIN_REDIRECT_URL", "authentication:profile")

    def get_success_url(self):
        return "/"

    def get(self, request, *__, **kwargs):
        token = kwargs["token"]

        try:
            user = self.signer.unsign(
                token, max_age=self.max_age, single_use=self.single_use
            )
            user.is_active = True
            user.save()
        except:
            msg = _("The token has expired")
            logger.warning(msg, exc_info=True)
            raise PermissionDenied

        user = authenticate(request, token=token)
        if user is None:
            raise PermissionDenied
        else:
            login(self.request, user=user)
            # Remove token from the HTTP Referer header
            self.request.path.replace(token, "login-token")

        return response.HttpResponseRedirect(self.get_success_url())


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
    return EcobalyseUser.objects.filter(token=token)
