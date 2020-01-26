# borg-windows-package

## Usage:
Install using Powershell to run `install.ps1`
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/nijave/borg-windows-package/releases/download/latest/install.ps1'))"
```