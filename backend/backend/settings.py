"""
Django settings for backend project.

Generated by 'django-admin startproject' using Django 5.0.3.

For more information on this file, see
https://docs.djangoproject.com/en/5.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.0/ref/settings/
"""

import re
from os.path import dirname, join
from pathlib import Path

from decouple import config  # python-decouple to read in .env
from django.utils.translation import gettext_lazy as _

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
GITROOT = dirname(BASE_DIR)

SITE_NAME = "Ecobalyse"
HOSTNAME = "ecobalyse.beta.gouv.fr"

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/5.0/howto/deployment/checklist/

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config("DJANGO_DEBUG", cast=bool, default=False)

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config("DJANGO_SECRET_KEY", "dev_not_so_secret_key")

ALLOWED_HOSTS = config(
    "ALLOWED_HOSTS",
    f"{HOSTNAME},localhost,127.0.0.1",
    cast=lambda v: [s.strip() for s in v.split(",")],
)


# Application definition

INSTALLED_APPS = [
    "mailauth",
    "mailauth.contrib.admin",
    # # don't use the provided mailauth user, it's redefined in the authentication module
    # "mailauth.contrib.user",
    "authentication.apps.AuthenticationConfig",
    # "textile.apps.TextileConfig", # TODO disable textile for now
    # #  the original admin config is replaced by custom AdminConfig
    # "django.contrib.admin",
    "backend.apps.AdminConfig",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    # "django.middleware.csrf.CsrfViewMiddleware",
    "backend.middle.DisableCSRFMiddleware",
    "django.middleware.locale.LocaleMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "backend.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [join(BASE_DIR, "templates")],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "backend.wsgi.application"


# Database
# https://docs.djangoproject.com/en/5.0/ref/settings/#databases

pattern: re.Pattern = re.compile(
    r"postgres://"
    r"(?P<user>[^:]+):"
    r"(?P<password>[^@]+)@"
    r"(?P<host>[^:]+):"
    r"(?P<port>\d+)/"
    r"(?P<database>[^\?]+)"
)
if match := pattern.search(config("SCALINGO_POSTGRESQL_URL", "")):
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "HOST": match.group("host"),
            "NAME": match.group("database"),
            "USER": match.group("user"),
            "PASSWORD": match.group("password"),
            "PORT": match.group("port"),
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": join(BASE_DIR, "db.sqlite3"),
        }
    }


# Password validation
# https://docs.djangoproject.com/en/5.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

AUTHENTICATION_BACKENDS = (
    # "django.contrib.auth.backends.ModelBackend",
    # The new access token based authentication backend
    "mailauth.backends.MailAuthBackend",
)
AUTH_USER_MODEL = "authentication.EcobalyseUser"
LOGIN_TOKEN_SINGLE_USE = False
LOGIN_URL_TIMEOUT = None

# Internationalization
# https://docs.djangoproject.com/en/5.0/topics/i18n/

LANGUAGE_CODE = "fr"

TIME_ZONE = "Europe/Paris"

USE_I18N = True

USE_TZ = True

LANGUAGES = [
    ("fr", _("Français")),
    ("en", _("English")),
    # Add more languages here
]
LOCALE_PATHS = (
    join(BASE_DIR, "locale"),
    join("authentication", "locale"),
    join("backend", "locale"),
    join("textile", "locale"),
)

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.0/howto/static-files/

STATIC_URL = "/static/"
# the location where collectstatic will write assets
STATIC_ROOT = "/app/static/"
# STATICFILES_DIRS = (os.path.join(BASE_DIR, "static"),)

# Default primary key field type
# https://docs.djangoproject.com/en/5.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

EMAIL_BACKEND = (
    "django.core.mail.backends.console.EmailBackend"
    if DEBUG
    else "django.core.mail.backends.smtp.EmailBackend"
)

EMAIL_HOST = config("EMAIL_HOST", "smtp-relay.brevo.com")
EMAIL_HOST_USER = config("EMAIL_HOST_USER", "test@example.com")
EMAIL_PORT = 587
EMAIL_HOST_PASSWORD = config("EMAIL_HOST_PASSWORD", "xxx")
EMAIL_USE_TLS = True
DEFAULT_FROM_EMAIL = config("DEFAULT_FROM_EMAIL", "ecobalyse@beta.gouv.fr")
