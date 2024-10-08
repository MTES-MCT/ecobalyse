import json

from django import forms
from django.contrib.auth import get_user_model
from django.forms import ModelForm
from django.utils.translation import gettext_lazy as _
from mailauth.backends import MailAuthBackend
from mailauth.forms import EmailLoginForm as MailauthEmailLoginForm


class EmailLoginForm(MailauthEmailLoginForm):
    def get_login_url(self, request, token, next=None):
        referrer = request.META.get("HTTP_REFERER")

        if referrer is None:
            referrer = "/"

        return super(EmailLoginForm, self).get_login_url(
            request, token, next=next or f"{referrer}#/auth/authenticated"
        )

    def save(self):
        """redefine just to transmit the login_url in test mode"""
        email = self.cleaned_data["email"]
        for user in self.get_users(email):
            context = self.get_mail_context(self.request, user)
            self.send_mail(email, context)


class RegistrationForm(ModelForm):
    subject_template_name = "registration/registration_subject.txt"
    email_template_name = "registration/registration_email.txt"
    html_email_template_name = "registration/registration_email.html"
    from_email = None
    field_name = "email"

    email = forms.EmailField(label=_("E-mail"))
    first_name = forms.CharField(label=_("First Name"))
    last_name = forms.CharField(label=_("Last Name"))
    organization = forms.CharField(label=_("Company"), required=False)
    terms_of_use = forms.BooleanField(label=_("I agree to the terms of use"))
    next = forms.CharField(label=_("Next url"))

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
        referrer = request.META.get("HTTP_REFERER")

        # If referrer is provided always use it to be compatible with multiple versions
        # that are served using relative urls (available in the referrer variable)
        # using / will redirect to the home and not to the appropriate version
        if referrer is None:
            next = next or "/#/auth/authenticated"
        else:
            next = f"{referrer}#/auth/authenticated"

        return MailauthEmailLoginForm.get_login_url(self, request, token, next=next)

    def get_token(self, user):
        """Return the access token."""
        return MailAuthBackend.get_token(user=user)

    def save(self, commit=True):
        """redefine just to transmit the login_url in test mode"""
        super().save(commit)
        email = self.cleaned_data["email"]
        for user in MailauthEmailLoginForm.get_users(self, email):
            context = MailauthEmailLoginForm.get_mail_context(self, self.request, user)
            MailauthEmailLoginForm.send_mail(self, email, context)
            return user
