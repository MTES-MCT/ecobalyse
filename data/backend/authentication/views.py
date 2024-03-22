from .forms import RegistrationForm
from django.conf import settings
from django.contrib.auth import authenticate, login
from django.core.exceptions import PermissionDenied
from django.http import response, JsonResponse
from django.shortcuts import render, redirect
from django.shortcuts import resolve_url
from django.utils.translation import gettext_lazy as _
from django.views import generic
from mailauth import signing
from mailauth.forms import EmailLoginForm
from mailauth.views import (
    LoginTokenView as MailauthLoginTokenView,
    LoginView as MailauthLoginView,
)
import json
import logging

logger = logging.getLogger(__name__)


def register(request):
    """render a form to provide an email to register"""
    if request.method == "POST":
        if request.path.endswith(".json/"):
            try:
                form = RegistrationForm(json.loads(request.body.decode("utf-8")))
                if form.is_valid():
                    form.save()
                    return JsonResponse(
                        {"success": True, "msg": "You now need to validate your email"}
                    )
            except json.JSONDecodeError:
                return JsonResponse(
                    {"success": False, "msg": "Invalid json in the POST request"}
                )
        else:
            form = RegistrationForm(request.POST)
            setattr(form, "request", request)
            if form.is_valid():
                form.save()
                return redirect("registration-requested")
    else:
        form = RegistrationForm()
    return render(
        request,
        "registration/register.html",
        {
            "form": form,
            "site_header": "Ecobalyse",
            "site_title": "Ecobalyse",
            "title": _("Register"),
        },
    )


class LoginView(MailauthLoginView):
    extra_context = {
        "site_header": "Ecobalyse",
        "site_title": "Ecobalyse",
        "title": _("Login"),
    }

    def post(self, request, *args, **kwargs):
        if request.path.endswith(".json/"):
            form = EmailLoginForm(
                request=request, data=json.loads(request.body.decode("utf-8"))
            )
            if form.is_valid():
                form.save()
                return JsonResponse(
                    {"success": True, "msg": _("You now need to validate your email")}
                )
            else:
                return JsonResponse(
                    {"success": False, "msg": _("You now need to validate your email")}
                )
        else:
            form = self.get_form()
            if form.is_valid():
                return self.form_valid(form)
            else:
                return self.form_invalid(form)


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
        # TODO redirect to profile instead, to give the occasion to fill in more details:
        return resolve_url(self.success_url)

    def get(self, request, *__, **kwargs):
        token = kwargs["token"]

        try:
            user = self.signer.unsign(
                token, max_age=self.max_age, single_use=self.single_use
            )
            user.is_active = True
            user.save()
        except:
            msg = _("Token has expired")
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
                    "company": u.company,
                    "terms_of_use": u.terms_of_use,
                }
            )
        else:
            return JsonResponse(
                {"error": _("You must be authenticated to access this page")},
                status=401,
            )
