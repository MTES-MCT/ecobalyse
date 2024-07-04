from django.contrib.auth import get_user_model
from django.core import mail
from django.test import TestCase
from django.urls import reverse

from .models import EcobalyseUser


class DjangoAuthenticationTests(TestCase):
    def test_unauthenticated_user_should_not_access_profile(self):
        response = self.client.get(
            reverse("profile"),
            content_type="application/json",
        )

        assert response.status_code == 401

    def test_authenticated_user_should_access_profile(self):
        test_user = EcobalyseUser.objects.get_or_create(email="testuser@test.com")[0]
        self.client.force_login(test_user)
        response = self.client.get(
            reverse("profile"),
            content_type="application/json",
        )
        assert response.status_code == 200

        assert response.json() == {
            "email": "testuser@test.com",
            "first_name": "",
            "last_name": "",
            "organization": "",
            "terms_of_use": False,
            "token": str(test_user.token),
        }

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
        assert response.status_code == 200
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
        assert response.status_code == 200
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
        assert response.status_code == 200
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
        assert response.status_code == 200
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
        assert response.status_code == 200
        assert response.json().get("success")

        with self.assertLogs(logger="mailauth.backends", level="ERROR") as cm:
            # wrong json login url
            response = self.client.get("/accounts/login/invalid-token?next=/")
            assert response.status_code == 302

            assert "BadSignature" in " ".join(cm.output)

        # right json login url (it's transmitted through reading the outbox)
        assert len(mail.outbox) == 1
        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        assert response.status_code == 302
        assert response.url == "/"

        # try to login again
        response = self.client.post(
            reverse("login"),
            {
                "email": "test@example.com",
                "next": "/",
            },
            content_type="application/json",
        )
        assert response.status_code == 200
        assert response.json().get("success")

        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        assert response.status_code == 302
        assert response.url == "/"

        # get json profile
        response = self.client.get(reverse("profile"))
        created_user = EcobalyseUser.objects.get(email="test@example.com")

        assert response.json() == {
            "email": "test@example.com",
            "first_name": "John",
            "last_name": "Doe",
            "organization": "",
            "terms_of_use": True,
            "token": str(created_user.token),
        }

    def test_as_admin(self):
        # create an admin
        super_user = get_user_model().objects.create_superuser(
            "admin@example.com", terms_of_use=True
        )

        # login as admin
        response = self.client.post(
            reverse("login"),
            {
                "email": super_user.email,
                "next": "/",
            },
            content_type="application/json",
        )
        assert response.status_code == 200
        assert response.json().get("success")

        login_url = "/" + "/".join(
            [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[
                3:
            ]
        )
        response = self.client.get(login_url)
        # a successful login should redirect to the "next" url
        assert response.status_code == 302
        assert response.url == "/"

        # get json profile
        response = self.client.get(reverse("profile"))
        response = self.client.get(reverse("profile"))

        assert response.json() == {
            "email": super_user.email,
            "first_name": "",
            "last_name": "",
            "organization": "",
            "terms_of_use": True,
            "token": str(super_user.token),
        }
