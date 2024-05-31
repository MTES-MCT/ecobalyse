from decouple import config  # python-decouple to read in .env
from django.contrib.auth import get_user_model


def init():
    # create initial admins given by an env var. Mails separated by comma, with optional token
    # So the env var can be in the form: user@example.com=ABCDEFGH,user2@example.com,user3@example.com
    # this allows a user to have a persistent token among all the deployments
    breakpoint()
    for admin in [
        m.strip().split("=") for m in config("BACKEND_ADMINS", "").split(",")
    ]:
        if len(admin) > 1:
            # we specified the mail and token
            (email, token) = admin
            if not get_user_model().objects.filter(email=email):
                # user not found by mail, create it
                get_user_model().objects.create_superuser(
                    email, terms_of_use=True, token=token
                )
            elif not get_user_model().objects.filter(email=email, token=token):
                # user found by mail but not by token, update the token
                user = get_user_model().objects.filter(email=email).first()
                if user:
                    user.token = token
                    user.save()
        else:
            # we specified only the mail
            (email,) = admin
            if not get_user_model().objects.filter(email=email):
                get_user_model().objects.create_superuser(email, terms_of_use=True)
