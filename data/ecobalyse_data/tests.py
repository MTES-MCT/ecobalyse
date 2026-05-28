import shutil

from bw2data.project import projects


def restore_archived_project(archive_path):
    base_data_dir, _ = projects._get_base_directories()
    shutil.unpack_archive(archive_path, base_data_dir)
