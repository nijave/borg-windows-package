#!/usr/bin/env bash

set -e

# export PATH=/usr/bin:$PATH
export PYTHON=$(ls /usr/bin | grep -P "^python3\.[0-9]+m?\.exe$" | sort -r | head -n 1)
export PYTHON_VERSION=$($PYTHON --version | awk '{print $2}')
export CYGWIN_VERSION=$(cygcheck -V | head -n 1 | grep -Po "[0-9.]+")

$PYTHON -m ensurepip
$PYTHON -m pip install -U pip wheel
$PYTHON -m pip download borgbackup
tar xf borgbackup*.tar.*
cd $(find . -maxdepth 1 -name "borgbackup*" -type d | tail -n 1 | xargs basename)
export BORG_VERSION=$($PYTHON setup.py --version)
$PYTHON setup.py bdist_wheel

whl=$(find . -name "*.whl" | head -n 1)
echo "::set-output name=borg_version::${BORG_VERSION}"
echo "::set-output name=version::cyg${CYGWIN_VERSION}-py${PYTHON_VERSION}-borg${BORG_VERSION}"
echo "::set-output name=whl_name::$(basename ${whl})"
echo "::set-output name=whl_path::$(cygpath -w $(readlink -f ${whl}))"

exit 0