from django.test import TestCase
from django.urls import reverse
import json
import os


class DjangoAuthenticationTests(TestCase):
    def test_display_register_form(self):
        response = self.client.get(reverse("register"))
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Veuillez vous inscrire")

    def test_register_login_on_standard_form(self):
        # invalid mail
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Saisissez une adresse de courriel valide")

        # missing first name
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@example.com",
                "first_name": "",
                "last_name": "Doe",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Ce champ est obligatoire")

        # missing last name
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Ce champ est obligatoire")

        # missing organization is OK
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "organization": "",
                "terms_of_use": True,
                "next": "/",
            },
        )
        self.assertEqual(getattr(response, "status_code"), 302)
        self.assertEqual(
            getattr(response, "headers")["Location"], reverse("registration-requested")
        )

        # wrong standard login url
        response = self.client.get(
            "/accounts/login/1::1ru4fl:Z3XQ1tyORtolai5tycqK99BjUgzefc7o-mfui0DQFa0?next=/"
        )
        self.assertEqual(getattr(response, "status_code"), 403)

        # right standard login url
        login_url = "/" + "/".join(os.environ["login_url"].split("/")[3:])
        response = self.client.get(login_url)
        self.assertEqual(getattr(response, "status_code"), 302)
        self.assertEqual(getattr(response, "url"), "/")

    def test_registration_confirmation(self):
        response = self.client.get(reverse("registration-requested"))
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Vérifiez votre boîte e-mail")

    def test_register_post_on_json_view(self):
        # invalid mail
        response = self.client.post(
            reverse("register_json"),
            {
                "email": "test@@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Saisissez une adresse de courriel valide")

        # missing first name
        response = self.client.post(
            reverse("register_json"),
            {
                "email": "test@example.com",
                "first_name": "",
                "last_name": "Doe",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Ce champ est obligatoire")

        # missing last name
        response = self.client.post(
            reverse("register_json"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "",
                "organization": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Ce champ est obligatoire")

        # missing organization is OK
        response = self.client.post(
            reverse("register_json"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "organization": "",
                "terms_of_use": True,
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertEqual(json.loads(getattr(response, "content")).get("success"), True)

        # wrong json login url
        response = self.client.get(
            "/accounts/login.json/1::1ru4fl:Z3XQ1tyORtolai5tycqK99BjUgzefc7o-mfui0DQFa0?next=/"
        )
        self.assertEqual(getattr(response, "status_code"), 404)

        # right json login url
        login_url = "/" + "/".join(os.environ["login_url"].split("/")[3:])
        response = self.client.get(login_url)
        self.assertEqual(getattr(response, "status_code"), 302)
        self.assertEqual(getattr(response, "url"), "/")
