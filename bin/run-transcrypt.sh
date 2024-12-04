# In $SOURCE_VERSION is set, we are deploying on Scalingo
# On scalingo, we don't have a git repo, so decrypting is handled
# differently in `buildpack-run.sh`
if [ -z "$SOURCE_VERSION" ]
then
  transcrypt -y -c aes-256-cbc -p "$TRANSCRYPT_KEY"
fi
