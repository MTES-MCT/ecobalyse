from django import forms
from django.contrib.auth import get_user_model
from django.contrib.sites.shortcuts import get_current_site
from django.core.mail import EmailMultiAlternatives
from django.db import connection
from django.template import TemplateDoesNotExist, loader
from django.urls import reverse
from mailauth.forms import BaseLoginForm
import urllib.parse


class RegistrationForm(forms.ModelForm, BaseLoginForm):
    subject_template_name = "registration/registration_subject.txt"
    email_template_name = "registration/registration_email.txt"
    html_email_template_name = "registration/registration_email.html"
    from_email = None
    field_name = None

    first_name = forms.CharField(label="First Name", max_length=30)
    last_name = forms.CharField(label="Last Name", max_length=30)
    company = forms.CharField(label="Company", max_length=100)
    terms_of_use = forms.BooleanField(label="I accept the terms of use")

    class Meta:
        model = get_user_model()
        fields = ["email", "first_name", "last_name", "company", "terms_of_use"]

    def get_users(self, email=None):
        if connection.vendor == "postgresql":
            query = {"email": email}
        else:
            query = {"%s__iexact" % "email": email}
        return get_user_model()._default_manager.filter(**query).iterator()

    def get_login_url(self, request, token, next=None):
        """see mailauth.forms"""
        protocol = "https" if request.is_secure() else "http"
        current_site = get_current_site(request)
        url = "{protocol}://{domain}{path}".format(
            protocol=protocol,
            domain=current_site.domain,
            path=reverse("authentication:register-activate", kwargs={"token": token}),
        )
        if next is not None:
            url += "?next=%s" % urllib.parse.quote(next)
        return url

    def send_mail(self, to_email, context):
        """Send a django.core.mail.EmailMultiAlternatives to `to_email`."""
        subject = loader.render_to_string(self.subject_template_name, context)
        # Email subject *must not* contain newlines
        subject = "".join(subject.splitlines())
        body = loader.render_to_string(self.email_template_name, context)

        email_message = EmailMultiAlternatives(
            subject, body, self.from_email, [to_email]
        )
        try:
            template = loader.get_template(self.html_email_template_name)
        except TemplateDoesNotExist:
            pass
        else:
            html_email = template.render(context, self.request)
            email_message.attach_alternative(html_email, "text/html")

        # email_message.send()
        print(email_message.body)

    def save(self, commit=True):
        user = super().save(commit=False)
        user.username = self.cleaned_data["email"]
        user.first_name = self.cleaned_data["first_name"]
        user.last_name = self.cleaned_data["last_name"]
        user.company = self.cleaned_data["company"]
        user.is_active = False  # Set user as inactive until email verification
        if commit:
            user.save()
        email = self.cleaned_data["email"]
        for user in self.get_users(email):
            context = self.get_mail_context(self.request, user)
            self.send_mail(email, context)
        return user
