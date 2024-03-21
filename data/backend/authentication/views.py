from django.shortcuts import render, redirect
from .forms import RegistrationForm
from django.views import generic


def register(request):
    if request.method == "POST":
        form = RegistrationForm(request.POST)
        form.request = request
        if form.is_valid():
            form.save()
            return redirect("registration-success")
    else:
        form = RegistrationForm()
    return render(request, "registration/register.html", {"form": form})


class RegistrationSuccessView(generic.TemplateView):
    template_name = "registration/registration_success.html"
