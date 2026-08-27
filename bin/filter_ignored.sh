#!/usr/bin/env bash
# Prend une liste de fichiers en arguments, et affiche ceux qui ne sont PAS
# ignorés par .jsonignore un par ligne.
# On optimise la recherche avec rg lui évitant de chercher à la racine du rep à chaque fois
# en lui spécifiant les répertoires des fichiers passés en paramètre
set -euo pipefail

dirs=$(printf '%s\n' "$@" | xargs -n1 dirname | sort -u)
allowed=$(rg --files --ignore-file .jsonformatignore --hidden -t json -- $dirs | sed 's#^\./##')
comm -12 <(printf '%s\n' "$@" | sort) <(printf '%s\n' "$allowed" | sort)
