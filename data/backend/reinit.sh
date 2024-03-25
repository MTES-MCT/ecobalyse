#!/bin/bash
rm -f db.sqlite3
rm -f backend/migrations/*
python manage.py makemigrations mailauth authentication textile
python manage.py migrate
echo "Creating initial data"
python manage.py shell -c "from textile.init import init; init()"
