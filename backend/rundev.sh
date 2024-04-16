#!/bin/bash
pushd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pipenv run ./manage.py runserver
