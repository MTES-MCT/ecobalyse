from django.conf import settings
from django.contrib.auth import authenticate, login
from django.core.exceptions import PermissionDenied
from django.http import response, JsonResponse
from django.shortcuts import render, redirect
from os.path import join, dirname

# from django.shortcuts import resolve_url
from django.utils.translation import gettext_lazy as _
from authentication.views import is_token_valid
import json
import logging
import os

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

processes = {
    "foodProcesses": food_processes,
    "textileProcesses": textile_processes,
}

processes_detailed = {
    "foodProcesses": food_processes_detailed,
    "textileProcesses": textile_processes_detailed,
}


def processes(request):
    token = request.headers.get("token")
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
        else:
            # No auth
            return JsonResponse(processes)
