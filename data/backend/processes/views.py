import json
import logging
import os
from os.path import dirname, join

from authentication.views import is_token_valid
from django.conf import settings
from django.contrib.auth import authenticate, login
from django.core.exceptions import PermissionDenied
from django.http import JsonResponse, response
from django.shortcuts import redirect, render

# from django.shortcuts import resolve_url
from django.utils.translation import gettext_lazy as _

# logger = logging.getLogger(__name__)

PUBLIC_FOLDER = join(settings.GITROOT, "public", "data")


# Pre-load processes files.
with open(join(PUBLIC_FOLDER, "food", "processes.json"), "r") as f:
    food_processes = f.read()

with open(join(PUBLIC_FOLDER, "textile", "processes.json"), "r") as f:
    textile_processes = f.read()

with open(join(PUBLIC_FOLDER, "food", "processes_impacts.json"), "r") as f:
    food_processes_detailed = f.read()

with open(join(PUBLIC_FOLDER, "textile", "processes_impacts.json"), "r") as f:
    textile_processes_detailed = f.read()

with open(join(PUBLIC_FOLDER, "food", "processes_impacts_fake.json"), "r") as f:
    food_processes_detailed_fake = f.read()

with open(join(PUBLIC_FOLDER, "textile", "processes_impacts_fake.json"), "r") as f:
    textile_processes_detailed_fake = f.read()

processes_not_detailed = {
    "foodProcesses": food_processes,
    "textileProcesses": textile_processes,
}

processes_detailed = {
    "foodProcesses": food_processes_detailed,
    "textileProcesses": textile_processes_detailed,
}

processes_detailed_fake = {
    "foodProcesses": food_processes_detailed_fake,
    "textileProcesses": textile_processes_detailed_fake,
}


def processes(request):
    token = request.headers.get("token")
    fakeDetails = request.headers.get("fakeDetails")
    if token:
        # Token auth
        if is_token_valid(token):
            return JsonResponse(processes_detailed)
        else:
            return JsonResponse(
                {"error": _("This token isn't valid")},
                status=401,
            )
    else:
        u = request.user
        if u.is_authenticated:
            # Cookie auth
            return JsonResponse(processes_detailed)
        elif fakeDetails:
            return JsonResponse(processes_detailed_fake)
        else:
            # No auth
            return JsonResponse(processes_not_detailed)
