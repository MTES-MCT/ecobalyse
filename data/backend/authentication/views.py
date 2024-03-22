from .forms import RegistrationForm
from django.conf import settings
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.core.exceptions import PermissionDenied
from django.http import response, JsonResponse
from django.shortcuts import render, redirect
from django.shortcuts import resolve_url
from django.views import generic
from mailauth import signing
from mailauth.views import LoginTokenView
import logging

logger = logging.getLogger(__name__)


def register(request):
    """render a form to provide an email to register"""
    if request.method == "POST":
        form = RegistrationForm(request.POST)
        setattr(form, "request", request)
        if form.is_valid():
            form.save()
            return redirect("authentication:registration-requested")
    else:
        form = RegistrationForm()
    return render(request, "registration/register.html", {"form": form})


class RegistrationRequestedView(generic.TemplateView):
    """confirmation that the email has beed stored"""

    template_name = "registration/registration_requested.html"


class Activate(LoginTokenView):
    """login and activate the disabled account"""

    signer = signing.UserSigner()
    max_age = getattr(settings, "LOGIN_URL_TIMEOUT", 60 * 15)
    single_use = getattr(settings, "LOGIN_TOKEN_SINGLE_USE", True)
    success_url = getattr(settings, "LOGIN_REDIRECT_URL", "authentication:profile")

    def get_success_url(self):
        return "/"
        # TODO redirect to profile instead, to give the occasion to fill in more details:
        return resolve_url(self.success_url)

    def get(self, request, *_, **kwargs):
        token = kwargs["token"]

        try:
            user = self.signer.unsign(
                token, max_age=self.max_age, single_use=self.single_use
            )
            user.is_active = True
            user.save()
        except:
            logger.warning("Token has expired.", exc_info=True)
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
            return JsonResponse({"error": "Not authenticated"}, status=401)
