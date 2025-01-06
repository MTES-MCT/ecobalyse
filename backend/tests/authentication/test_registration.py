import logging

import pytest
from authentication.models import EcobalyseUser
from django.contrib.auth import get_user_model
from django.core import mail
from django.urls import reverse
from pytest_django.asserts import assertContains


@pytest.mark.django_db
def test_register_post(client, caplog):
    url = reverse("register")
    response = client.post(
        url,
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
    assertContains(response, "Saisissez une adresse de courriel valide")

    # missing first name
    response = client.post(
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
    assertContains(response, "Ce champ est obligatoire")

    # missing last name
    response = client.post(
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
    assertContains(response, "Ce champ est obligatoire")

    # don't accept terms of use
    response = client.post(
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
    assertContains(response, "Ce champ est obligatoire")

    # missing organization is OK
    response = client.post(
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

    with caplog.at_level(logging.ERROR):
        response = client.get("/accounts/login/invalid-token?next=/")
        assert response.status_code == 302

        assert "BadSignature" in caplog.text

    # right json login url (it's transmitted through reading the outbox)
    assert len(mail.outbox) == 1
    login_url = "/" + "/".join(
        [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[3:]
    )
    response = client.get(login_url)
    # a successful login should redirect to the "next" url
    assert response.status_code == 302
    assert response.url == "/"

    # try to login again
    response = client.post(
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
        [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[3:]
    )
    response = client.get(login_url)
    # a successful login should redirect to the "next" url
    assert response.status_code == 302
    assert response.url == "/"
    # get json profile
    response = client.get(reverse("profile"))
    created_user = EcobalyseUser.objects.get(email="test@example.com")

    assert response.json() == {
        "email": "test@example.com",
        "first_name": "John",
        "last_name": "Doe",
        "organization": "",
        "staff": False,
        "terms_of_use": True,
        "token": str(created_user.token),
    }


@pytest.mark.django_db
def test_as_admin(client):
    # create an admin
    super_user = get_user_model().objects.create_superuser(
        "admin@example.com", terms_of_use=True
    )

    # login as admin
    response = client.post(
        reverse("login"),
        {
            "email": "admin@example.com",
            "next": "/",
        },
        content_type="application/json",
    )
    assert response.status_code == 200
    assert response.json().get("success")

    login_url = "/" + "/".join(
        [x for x in mail.outbox[0].body.split("\n") if "http" in x][0].split("/")[3:]
    )
    response = client.get(login_url)
    # a successful login should redirect to the "next" url
    assert response.status_code == 302
    assert response.url == "/"
    # get json profile
    response = client.get(reverse("profile"))
    assert response.json() == {
        "email": super_user.email,
        "first_name": "",
        "last_name": "",
        "organization": "",
        "staff": True,
        "terms_of_use": True,
        "token": str(super_user.token),
    }
