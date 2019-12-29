# borg-windows-package

## Package using podman
`mkdir -p dist/ && chcon -Rt fusefs_t dist/`
`podman run --rm -v ./dist:/borg-windows-package/dist borg-windows-package`

## Cygwin setup
```
bin\bash.exe --login -i build.sh
```