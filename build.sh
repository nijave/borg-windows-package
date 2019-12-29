#!/usr/bin/env bash

export PYTHON=python3.6
export PATH=/usr/bin:$PATH
$PYTHON -m ensurepip
$PYTHON -m pip install -U pip wheel
pip download borgbackup
tar xf borgbackup*.tar.*
cd borgbackup*
$PYTHON setup.py bdist_wheel