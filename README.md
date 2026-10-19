# flaresolverr

[FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) as the estate runs
it: the upstream image, run as `deploy` (1000:1000) under a read-only root
filesystem. This repository publishes the image only. A Project that needs
Cloudflare challenges solved runs it as a light sidecar, behind its own exit
address (prowlarr does, behind the VPN), and locks it from here.

## What the image changes

- names `USER 1000:1000` and clears every setuid and setgid bit;
- sets `HOME=/tmp`, the one path a Process's pod writes, for Chrome's profile;
- ships the driver as `/app/chromedriver.dist`, with `/app/chromedriver` a link
  into `/tmp`: undetected-chromedriver patches the driver in place, so each
  start copies the original there first.

The sidecar's Process declares `/tmp` writable; its sidecars mount it too.

## Versions

This repository's version is FlareSolverr's: release `v3.5.2` runs FlareSolverr
3.5.2. Renovate opens a pull request for each FlareSolverr release. A minor or
patch release merges itself once `Pipeline Complete` passes; a major release
waits for approval on the Dependency Dashboard. When the `FROM` tag changes on
`main`, `release.yml` releases that version and publishes the image.

`scripts/smoke-test.sh` starts the image restricted, waits until it serves and
solves one page; CI runs it on every change.

## Licence

This repository's own files are MIT: see [LICENSE](LICENSE). FlareSolverr is
MIT.
