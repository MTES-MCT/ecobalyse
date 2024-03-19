#!/bin/bash
rm -f db.sqlite3
rm -f backend/migrations/*
python manage.py makemigrations mailauth textile
###python manage.py makemigrations mailauth mailauth_user textile
python manage.py migrate
#python manage.py createsuperuser
echo "Creating initial data"
python manage.py shell -c "from textile.init import init; init()"
