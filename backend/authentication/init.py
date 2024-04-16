from decouple import config  # python-decouple to read in .env
from django.contrib.auth import get_user_model


def init():
    # create initial admins given by an env var. Mails separated by comma
    for email in [m.strip() for m in str(config("BACKEND_ADMINS")).split(",")]:
        if not get_user_model().objects.filter(email=email):
            get_user_model().objects.create_superuser(email)
