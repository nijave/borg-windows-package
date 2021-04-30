# borg-windows-package

## Usage:
Use Command Prompt to download and run `install.ps1` via Powershell
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/nijave/borg-windows-package/releases/latest/download/install.ps1'))"
```

## Update
Update cygwin (from Windows)
```
C:\tools\cygwin\cygwinsetup.exe --no-desktop --no-shortcuts --no-startmenu --quiet-mode
```
Upgrade borgbackup
```
rm borgbackup*.whl
LATEST_WHL=$(curl -s https://api.github.com/repos/nijave/borg-windows-package/releases/latest | grep -E "https://.*?\.whl" | cut -d '"' -f 4)
curl -LO "$LATEST_WHL"
pip install -U borgbackup*.whl borgmatic
```
