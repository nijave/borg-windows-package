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

cat << EOF > install.ps1
#TODO Install choco
Start-Process -Verb runAs powershell -ArgumentList "-Command" "& $(Invoke-WebRequest -UseBasicParsing -Uri https://choco-install-url).Content"

Start-Process -Verb runAs "c:\ProgramData\chocolatey\bin\choco.exe" -ArgumentList "install", "cygwin"

Start-Process -Verb -runAs "C:\tools\cygwin\cygwinsetup.exe" -ArgumentList "-nqWgv",
    "-s", "http://mirrors.kernel.org/sourceware/cygwin/",
    "-R", "C:\tools\cygwin",
    "-P", "${PYTHON_VERSION}-pip" | Out-String

# TODO release path
Start-Process "c:\tools\cygwin\bin\bash.exe" -ArgumentList "--login", 
    "-c", "pip install -y https://github.com/nijave/borg-windows-package/releases/${whl} borgmatic"
EOF

echo "::set-output name=borg_version::${BORG_VERSION}"
echo "::set-output name=version::cyg${CYGWIN_VERSION}-py${PYTHON_VERSION}-borg${BORG_VERSION}"
echo "::set-output name=whl_name::$(basename ${whl})"
echo "::set-output name=whl_path::$(cygpath -w $(readlink -f ${whl}))"
echo "::set-output name=script_path::$(cygpath -w $(readlink -f install.ps1))"

exit 0