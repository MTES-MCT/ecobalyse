import json

from django.contrib.auth import get_user_model
from django.core import mail
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
        self.assertEqual(response.status_code, 200)
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
        self.assertEqual(response.status_code, 200)
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
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Ce champ est obligatoire")

        # don't accept terms of use
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "Doe",
                "organization": "ACME",
                "terms_of_use": False,
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(response.status_code, 200)
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
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content).get("success"), True)

        # wrong json login url
        response = self.client.get(
            "/accounts/login/1::1ru4fl:Z3XQ1tyORtolai5tycqK99BjUgzefc7o-mfui0DQFa0?next=/"
        )
        self.assertEqual(response.status_code, 403)

        # right json login url (it's transmitted through environ in test mode)
        self.assertEqual(len(mail.outbox), 1)
        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        self.assertEqual(response.status_code, 302)
        self.assertEqual(response.url, "/")

        # try to login again
        response = self.client.post(
            reverse("login"),
            {
                "email": "test@example.com",
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content).get("success"), True)
        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        self.assertEqual(response.status_code, 302)
        self.assertEqual(response.url, "/")
        # get json profile
        response = self.client.get(reverse("profile"))
        jsonresp = json.loads(response.content)
        self.assertEqual(
            list(jsonresp.keys()),
            [
                "email",
                "first_name",
                "last_name",
                "organization",
                "terms_of_use",
                "token",
            ],
        )
        self.assertEqual(
            list(jsonresp.values())[:5], ["test@example.com", "John", "Doe", "", True]
        )

    def test_as_admin(self):
        # create an admin
        get_user_model().objects.create_superuser(
            "admin@example.com", terms_of_use=True
        )

        # login as admin
        response = self.client.post(
            reverse("login"),
            {
                "email": "admin@example.com",
                "next": "/",
            },
            content_type="application/json",
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content).get("success"), True)
        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        self.assertEqual(response.status_code, 302)
        self.assertEqual(response.url, "/")
        # get json profile
        response = self.client.get(reverse("profile"))
        jsonresp = json.loads(response.content)
        self.assertEqual(
            list(jsonresp.keys()),
            [
                "email",
                "first_name",
                "last_name",
                "organization",
                "terms_of_use",
                "token",
            ],
        )
        self.assertEqual(
            list(jsonresp.values())[:5], ["admin@example.com", "", "", "", True]
        )
