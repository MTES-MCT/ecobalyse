#!/bin/bash
rm db.sqlite3
rm backend/migrations/*
python manage.py makemigrations backend
python manage.py migrate
echo "Creating initial data"
python manage.py shell -c "from backend.init import init; init()"
