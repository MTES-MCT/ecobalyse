# Needed by pip even if we don't build the package
from setuptools import find_packages, setup

setup(
    name="ecobalyse",
    version="0.1",
    packages=find_packages(),
)
