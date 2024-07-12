from authentication.models import EcobalyseUser
from django.http import JsonResponse


def is_token_valid(token):
    return EcobalyseUser.objects.filter(token=token).count() > 0


def check_token(request):
    token = request.headers.get("token")
    if is_token_valid(token):
        return JsonResponse({})
    else:
        return JsonResponse(
            {"error": "This token isn't valid."},
            status=401,
        )
