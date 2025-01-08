import pytest
from authentication.models import EcobalyseUser
from django.urls import reverse


@pytest.mark.django_db
def test_unauthenticated_user_should_not_access_profile(client):
    response = client.get(
        reverse("profile"),
        content_type="application/json",
    )

    assert response.status_code == 401


@pytest.mark.django_db
def test_authenticated_user_should_access_profile(client):
    test_user = EcobalyseUser.objects.get_or_create(email="testuser@test.com")[0]
    client.force_login(test_user)
    response = client.get(
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
        "staff": False,
        "token": str(test_user.token),
    }
