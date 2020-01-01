#!/usr/bin/env bash

set -e

export PYTHON=$(ls /usr/bin | grep -P "^python3\.[0-9]+$" | sort -r | head -n 1)
export PYTHON_VERSION=$($PYTHON --version | awk '{print $2}')
export PATH=/usr/bin:$PATH
$PYTHON -m ensurepip
$PYTHON -m pip install -U pip wheel
$PYTHON -m pip download borgbackup
tar xf borgbackup*.tar.*
cd $(find . -maxdepth 1 -name "borgbackup*" -type d | tail -n 1 | xargs basename)
$PYTHON setup.py bdist_wheel

whl=$(find . -name "*.whl" | head -n 1)
echo "::set-output name=version::python-v${PYTHON_VERSION}-borg-v$($PYTHON setup.py --version)"
echo "::set-output name=whl::$(cygpath -w $(readlink -f ${whl}))"

exit 0