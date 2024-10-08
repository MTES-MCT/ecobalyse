"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.conf import settings
from django.urls import include, path, re_path

from backend.admin import admin_site

from .views import serve_directory

urlpatterns = [
    path("admin/", admin_site.urls),
    path("accounts/", include("authentication.urls")),
    # Localhost only calls, url not mapped to the nginx proxy
    path("internal/", include("internal.urls")),
]

if settings.DEBUG:
    urlpatterns += [re_path(r"^(?P<path>.*)$", serve_directory)]
