from hashlib import file_digest
from pathlib import Path, PurePosixPath

import boto3.session

from config import settings
from ecobalyse_data.logging import logger

DB_CACHE_PATH = Path(settings.DB_CACHE_DIR)
DB_CACHE_PATH.mkdir(parents=True, exist_ok=True)


class S3Client(object):
    _client = None

    @classmethod
    def get_client(cls):
        if cls._client is None:
            session = boto3.session.Session(
                aws_access_key_id=settings.S3_ACCESS_KEY_ID,
                aws_secret_access_key=settings.S3_SECRET_ACCESS_KEY,
                region_name=settings.S3_REGION,
            )
            cls._client = session.client("s3", endpoint_url=settings.S3_ENDPOINT)
        return cls._client


def get_file(path: str, md5_checksum: str) -> Path:
    local_filepath = DB_CACHE_PATH / path
    if not local_filepath.exists():
        key = str(PurePosixPath(settings.S3_DB_PREFIX) / path)
        logger.debug(f"Downloading s3://{settings.S3_BUCKET}/{key} to {local_filepath}")
        S3Client.get_client().download_file(
            settings.S3_BUCKET,
            key,
            local_filepath,
        )
        assert local_filepath.exists()

    # Check that the cached file has the expected checksum
    with open(local_filepath, "rb") as f:
        md5_on_disk = file_digest(f, "md5").hexdigest()
        assert md5_on_disk == md5_checksum, (
            f"the md5 for {local_filepath} is {md5_on_disk}, which is "
            f"different than the expected one ({md5_checksum}).\n"
            f"⛔ This should not happen! ⛔ \n"
            "You can remove your local copy to solve this, "
            f"but you might want to check if the remote file was modified "
            f"(which should not happen either!)"
        )
    return local_filepath.absolute()
