from django.test import TestCase
from django.urls import reverse
from authentication.views import register
from django.test import Client


class DjangoAuthenticationTests(TestCase):
    def test_display_register_form(self):
        response = self.client.get(reverse("register"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Veuillez vous inscrire")

    def test_register_post(self):
        response = self.client.post(
            reverse("register"),
            {
                "email": "test@example.com",
                "first_name": "John",
                "last_name": "doe",
                "company": "ACME",
                "terms_of_use": True,
                "next": "/",
            },
        )
        # check we redirect to the confirmation page
        self.assertEqual(response.status_code, 302)
        self.assertEqual(
            response.headers["Location"], reverse("registration-requested")
        )

    def test_registration_confirmation(self):
        response = self.client.get(reverse("registration-requested"))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Vérifiez votre boîte e-mail")
