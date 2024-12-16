# If $SOURCE_VERSION is set, we are building on Scalingo with npm
# so we should not decrypt the file.
# On scalingo, we don't have a git repo, so decrypting is handled
# differently in `buildpack-run.sh`
#
# If we set the first parameter to "force", don't take into account the
# $SOURCE_VERSION variable
if [ -z "$SOURCE_VERSION" ] || [ "$1" == "force" ]
then
  transcrypt -y -c aes-256-cbc -p "$TRANSCRYPT_KEY"
fi
