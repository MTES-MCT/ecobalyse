import os
from django.http import Http404
from django.views.static import serve


def serve_directory(request, path=""):
    document_root = "dist"
    if not os.path.exists(os.path.join(document_root, path)):
        raise Http404("File not found")
    return serve(
        request,
        "/index.html" if path in ("", "/") else path,
        document_root=document_root,
    )
