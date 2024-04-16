#!/bin/bash
pushd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# this script is used at startup on scalingo (see start.sh)

# update the l10n and DB
django-admin compilemessages
python manage.py makemigrations mailauth authentication #textile
python manage.py migrate

# Populate the DB
python manage.py shell -c "from authentication.init import init; init()"
#python manage.py shell -c "from textile.init import init; init()"