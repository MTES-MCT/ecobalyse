from django.test import TestCase
from django.urls import reverse


class DjangoAuthenticationTests(TestCase):
    def test_display_register_form(self):
        response = self.client.get(reverse("register"))
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Veuillez vous inscrire")

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

    def test_registration_confirmation(self):
        response = self.client.get(reverse("registration-requested"))
        self.assertEqual(getattr(response, "status_code"), 200)
        self.assertContains(response, "Vérifiez votre boîte e-mail")
