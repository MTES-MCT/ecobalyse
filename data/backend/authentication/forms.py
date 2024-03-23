from django import forms
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from mailauth.forms import EmailLoginForm as MailauthEmailLoginForm


class EmailLoginForm(MailauthEmailLoginForm):
    def get_login_url(self, request, token, next=None):
        return super(EmailLoginForm, self).get_login_url(
            request, token, next=next or "/#/auth/loggedIn"
        )


class RegistrationForm(MailauthEmailLoginForm, forms.ModelForm):
    subject_template_name = "registration/registration_subject.txt"
    email_template_name = "registration/registration_email.txt"
    html_email_template_name = "registration/registration_email.html"
    from_email = None
    field_name = None

    first_name = forms.CharField(label=_("First Name"), max_length=30)
    last_name = forms.CharField(label=_("Last Name"), max_length=30)
    company = forms.CharField(label=_("Company"), max_length=100)
    terms_of_use = forms.BooleanField(
        label=_("I undertake not to use the data for commercial use")
    )

    class Meta:
        model = get_user_model()
        fields = ["email", "first_name", "last_name", "company", "terms_of_use"]

    def __init__(self, request, *a, **kw):
        MailauthEmailLoginForm.__init__(self, request)
        forms.ModelForm.__init__(self, *a, **kw)

    def get_login_url(self, request, token, next=None):
        return super(MailauthEmailLoginForm, self).get_login_url(
            request, token, next=next or "/#/auth/loggedIn"
        )

    def save(self, commit=True):
        breakpoint()
        user = forms.ModelForm.save(self, commit)
        MailauthEmailLoginForm.save(self)
        return user
