# If $SOURCE_VERSION is set, we are building on Scalingo with npm
# so we should not decrypt the file.
# On scalingo, we don't have a git repo, so decrypting is handled
# differently in `buildpack-run.sh`
#
# If we set the first parameter to "force", don't take into account the
# $SOURCE_VERSION variable
if [ -z "$SOURCE_VERSION" ] || [ "$1" == "force" ]
then

  if [ -z "$TRANSCRYPT_KEY" ]
  then
    echo "🚨 Error: the TRANSCRYPT_KEY env variable need to be set to decode encrypted files."
    echo "-> Exiting"
    exit 1
  fi
  transcrypt -y -c aes-256-cbc -p "$TRANSCRYPT_KEY"
fi
