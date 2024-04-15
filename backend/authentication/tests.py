import json
import os

from django.test import TestCase
from django.urls import reverse


class DjangoAuthenticationTests(TestCase):
    def test_register_post(self):
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
            content_type="application/json",
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
            content_type="application/json",
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
            content_type="application/json",
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
            content_type="application/json",
        )
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertEqual(json.loads(getattr(response, "content")).get("success"), True)

        # wrong json login url
        response = self.client.get(
            "/accounts/login/1::1ru4fl:Z3XQ1tyORtolai5tycqK99BjUgzefc7o-mfui0DQFa0?next=/"
        )
        self.assertEqual(getattr(response, "status_code"), 404)

        # right json login url
        login_url = "/" + "/".join(os.environ["login_url"].split("/")[3:])
        response = self.client.get(login_url)
        self.assertEqual(getattr(response, "status_code"), 302)
        self.assertEqual(getattr(response, "url"), "/")
