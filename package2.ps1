(New-Object System.Net.WebClient).DownloadFile("https://cygwin.com/setup-x86_64.exe", (Join-Path -Path (pwd) -ChildPath "setup-x86_64.exe"))
Start-Process .\setup-x86_64.exe -Wait -Verb runAs `
    -ArgumentList "-n", "-q", "-W", `
    "-s", "http://cygwin.mirror.constant.com", `
    "-l", "$env:UserProfile\Downloads\cygwin_cache", `
    "-R", "C:\cygwin64", `
    "-P", "cygwin-devel,gcc-g++,libssl-devel,python36,python36-pip,[ython36-devel", `
    "-g", "-v"