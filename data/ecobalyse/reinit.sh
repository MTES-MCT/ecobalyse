#!/bin/bash
rm -f db.sqlite3
rm -f backend/migrations/*
python manage.py makemigrations backend
python manage.py migrate
echo "Creating initial data"
python manage.py shell -c "from backend.init import init; init()"
