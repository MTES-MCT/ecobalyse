#!/usr/bin/env bash

set -eo pipefail

HOST_UID=$(ls -lnd /cache/brightway|awk '{print $3}')
HOST_GID=$(ls -lnd /cache/brightway|awk '{print $4}')


CONT_UID=$(id -u eb)
CONT_GID=$(id -g eb)
if ([ $HOST_UID -ne $CONT_UID ] || [ $HOST_GID -ne $CONT_GID ]) && [ $HOST_UID -ne 0 ]; then
  usermod -u $HOST_UID -g $HOST_GID eb
  chown -R $HOST_UID:$HOST_GID /app
fi


if [ $# -eq 0 ]; then
  echo "Run 'just' followed by one of those commands:"
  exec gosu eb just
else
  exec gosu eb "$@"
fi
