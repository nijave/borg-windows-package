#!/usr/bin/env python3

import pathlib
import typing
import subprocess
from subprocess import check_output

def run(*args):
    return subprocess.check_output(args, text=True).strip()

def delete_all(s: str, removals: typing.List[str]) -> str:
    for r in removals:
        s = s.replace(r, '')
    return s

DIR_STACK = []
def pushd(dir, stack=DIR_STACK):
    last_dir = os.getcwd()
    os.chdir(dir)
    DIR_STACK.append(last_dir)

def popd(stack=DIR_STACK):
    os.chdir(DIR_STACK.pop())

REPO_BASE = "https://github.com/nijave/borg-windows-package/releases/download"
BUILD_TARGETS = ["borgbackup", "ruamel.yaml.clib"]

python = next(pathlib.Path("/usr/bin").glob("python3*.*.exe"))
python_version = run(python, "--version").split()[-1]
cygwin_version = run("cygcheck", "-V").splitlines()[0].split()[-1]

# Build tools
run(python, "-m", "pip", "install", "-U", "pip", "setuptools", "wheel")


def build_wheel(module: str) -> typing.Tuple[str, str]:
    download_output = run("pip", "download", module)
    save_prefixes = ("Saved ", "File was already downloaded")
    archive = [
        delete_all(line.strip(), save_prefixes) for line in download_output.splitlines()
        if any(line.strip().startswith(prefix) for prefix in save_prefixes)
    ][0].strip()
    run("tar", "xf", archive)
    with tarfile.open(archive, "r") as tf:
        module_dir = tf.getnames()[0]
    pushd(module_dir)
    if (
        subprocess.run(
            [python, "setup.py", "bdist_wheel"],
            text=True
        ).returncode != 0
    ):
        raise RuntimeError(f"{module} build failed")
    whl_file = module_dir / next(pathlib.Path(".").glob("**/*.whl"))
    # capture some build info
    # set outputs
    # return name, path


build_info = {
    output[0]: output[1]
    for output in (
        build_wheel(package) for package in BUILD_TARGETS
    )
}

install_script = open("install.ps1", "w")
install_script.write(f"""
Start-Process -Verb runAs -Wait powershell -ArgumentList "-NoProfile", "-ExecutionPolicy", "AllSigned",
    "-Command", "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

$env:PATH = "$env:PATH;$env:ALLUSERSPROFILE\chocolatey\bin"

Start-Process -Verb runAs -Wait "c:\ProgramData\chocolatey\bin\choco.exe" -ArgumentList "install", "-y", "cygwin"

Start-Process -Verb runAs -Wait "C:\tools\cygwin\cygwinsetup.exe" -ArgumentList "-nqWgv",
    "-s", "http://mirrors.kernel.org/sourceware/cygwin/",
    "-R", "C:\tools\cygwin",
    "-P", "{CYGWIN_PYTHON_PACKAGE}-pip,gcc-core,openssh,zstd" | Out-String

@'
    PYTHON=\$(find /usr/bin -name "python*.exe" | head -n 1)
    PIP=\$(find /usr/bin -name "pip*.*" | head -n 1)
    ln -s "\$PYTHON" /usr/bin/python
    ln -s "\$PYTHON" /usr/bin/python3
    ln -s "\$PIP" /usr/bin/pip
    ln -s "\$PIP" /usr/bin/pip3
    pip3 install \
        {REPO_BASE}/{RELEASE_TAG}/$(basename {BORGBACKUP_WHL}) borgmatic
'@ | & "c:\tools\cygwin\bin\bash.exe" --login -i
""".strip())