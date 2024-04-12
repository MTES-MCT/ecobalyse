#!/bin/bash
# this script is used at startup on scalingo (see start.sh)

# Create the DB structure
python manage.py makemigrations mailauth authentication textile
python manage.py migrate

# Populate the DB (if empty or is sqlite3)
# TODO to be removed after switching to prod
python manage.py shell -c "from textile.init import init; init()"
