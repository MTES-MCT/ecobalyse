from django import forms
from django.contrib.auth import get_user_model
from django.forms import ModelForm
from django.utils.translation import gettext_lazy as _
from mailauth.backends import MailAuthBackend
from mailauth.forms import EmailLoginForm as MailauthEmailLoginForm
import json
import os
import sys


class EmailLoginForm(MailauthEmailLoginForm):
    def get_login_url(self, request, token, next=None):
        return super(EmailLoginForm, self).get_login_url(
            request, token, next=next or "/#/auth/loggedIn"
        )


class RegistrationForm(ModelForm):
    subject_template_name = "registration/registration_subject.txt"
    email_template_name = "registration/registration_email.txt"
    html_email_template_name = "registration/registration_email.html"
    from_email = None
    field_name = "email"

    email = forms.CharField(label=_("E-mail"), max_length=30)
    first_name = forms.CharField(label=_("First Name"), max_length=30)
    last_name = forms.CharField(label=_("Last Name"), max_length=30)
    organization = forms.CharField(label=_("Company"), max_length=100, required=False)
    terms_of_use = forms.BooleanField(
        label=_("I undertake not to use the data for commercial use")
    )
    next = forms.CharField(label=_("Next url"), max_length=100)

    class Meta:
        model = get_user_model()
        fields = [
            "email",
            "first_name",
            "last_name",
            "organization",
            "terms_of_use",
            "next",
        ]

    def __init__(self, request=None, *a, **kw):
        if request:
            super().__init__(request.body, *a, *kw)
            self.data = (
                request.POST
                if request.POST
                else json.loads(request.body.decode("utf-8"))
            )
            self.request = request
        else:
            super().__init__(*a, *kw)

    def get_login_url(self, request, token, next=None):
        return MailauthEmailLoginForm.get_login_url(
            self, request, token, next=next or "/#/auth/loggedIn"
        )

    def get_token(self, user):
        """Return the access token."""
        return MailAuthBackend.get_token(user=user)

    def save(self, commit=True):
        super().save(commit)
        email = self.cleaned_data["email"]
        for user in EmailLoginForm.get_users(self, email):
            context = EmailLoginForm.get_mail_context(self, self.request, user)
            EmailLoginForm.send_mail(self, email, context)
            if "test" in sys.argv:
                # hack to pass the login url to the test suite
                os.environ["login_url"] = context["login_url"]
        return user
