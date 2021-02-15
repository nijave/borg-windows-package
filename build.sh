#!/usr/bin/env bash

set -xe

# export PATH=/usr/bin:$PATH
export PYTHON=$(ls /usr/bin | grep -P "^python3\.[0-9]+m?\.exe$" | sort -r | head -n 1)
export PYTHON_VERSION=$($PYTHON --version | awk '{print $2}')
export CYGWIN_VERSION=$(cygcheck -V | head -n 1 | grep -Po "[0-9.]+")

# $PYTHON -m ensurepip
$PYTHON -m pip install -U pip wheel
$PYTHON -m pip download borgbackup
tar xf borgbackup*.tar.*
cd $(find . -maxdepth 1 -name "borgbackup*" -type d | tail -n 1 | xargs basename)
export BORG_VERSION=$($PYTHON setup.py --version)
$PYTHON setup.py bdist_wheel

RELEASE_TAG="cyg${CYGWIN_VERSION}-py${PYTHON_VERSION}-borg${BORG_VERSION}"
WHL=$(find . -name "*.whl" | head -n 1)

cat << EOF > install.ps1
Start-Process -Verb runAs -Wait powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "AllSigned",
    "-Command", "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

\$env:PATH = "\$env:PATH;\$env:ALLUSERSPROFILE\chocolatey\bin"

Start-Process -Verb runAs -Wait "c:\ProgramData\chocolatey\bin\choco.exe" -ArgumentList "install", "cygwin"

Start-Process -Verb runAs -Wait "C:\tools\cygwin\cygwinsetup.exe" -ArgumentList "-nqWgv",
    "-s", "http://mirrors.kernel.org/sourceware/cygwin/",
    "-R", "C:\tools\cygwin",
    "-P", "${CYGWIN_PYTHON_PACKAGE}-pip,gcc-core,openssh,zstd" | Out-String

@'
    PYTHON=\$(find /usr/bin -name "python*.exe" | head -n 1)
    PIP=\$(find /usr/bin -name "pip*.*" | head -n 1)
    ln -s "\$PYTHON" /usr/bin/python
    ln -s "\$PYTHON" /usr/bin/python3
    ln -s "\$PIP" /usr/bin/pip
    ln -s "\$PIP" /usr/bin/pip3
    pip3 install https://github.com/nijave/borg-windows-package/releases/download/${RELEASE_TAG}/$(basename ${WHL}) borgmatic
'@ | & "c:\tools\cygwin\bin\bash.exe" --login -i
EOF

echo "::set-output name=borg_version::${BORG_VERSION}"
echo "::set-output name=version::${RELEASE_TAG}"
echo "::set-output name=whl_name::$(basename ${WHL})"
echo "::set-output name=whl_path::$(cygpath -w $(readlink -f ${WHL}))"
echo "::set-output name=script_path::$(cygpath -w $(readlink -f install.ps1))"

exit 0
