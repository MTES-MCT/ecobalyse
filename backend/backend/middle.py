class DisableCSRFMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if not request.path.startswith("/admin"):
            setattr(request, "_dont_enforce_csrf_checks", True)
        return self.get_response(request)
