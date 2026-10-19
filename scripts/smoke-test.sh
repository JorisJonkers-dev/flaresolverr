#!/usr/bin/env bash
# Starts the image restricted (uid 1000, a read-only root, every capability dropped), with only /tmp
# writable as a pod's emptyDir is (exec allowed), waits until it serves, and solves one page.
# Usage: scripts/smoke-test.sh <flaresolverr-image>
set -euo pipefail

cleanup() { docker rm -f smoke-flaresolverr >/dev/null 2>&1 || true; }
trap cleanup EXIT
cleanup

docker run -d --name smoke-flaresolverr --read-only --cap-drop ALL \
  --tmpfs '/tmp:exec,uid=1000,gid=1000,mode=1777' -p 127.0.0.1:18191:8191 "$1" >/dev/null

served=false
for _ in $(seq 1 60); do
  if curl -fsS -m 3 http://127.0.0.1:18191/health >/dev/null 2>&1; then served=true; break; fi
  if [ "$(docker inspect -f '{{.State.Running}}' smoke-flaresolverr)" != true ]; then
    docker logs smoke-flaresolverr 2>&1 | tail -30
    echo "flaresolverr exited before it served" >&2
    exit 1
  fi
  sleep 3
done
[ "$served" = true ] || { docker logs smoke-flaresolverr 2>&1 | tail -30; echo "flaresolverr never served" >&2; exit 1; }

solved=$(curl -fsS -m 120 -X POST http://127.0.0.1:18191/v1 -H 'Content-Type: application/json' \
  -d '{"cmd":"request.get","url":"https://example.com","maxTimeout":60000}')
echo "$solved" | grep -q '"status": "ok"' || { echo "$solved" >&2; docker logs smoke-flaresolverr 2>&1 | tail -30; exit 1; }
others=$(docker top smoke-flaresolverr -eo pid,uid | tail -n +2 | awk '$2 != 1000')
[ -z "$others" ] || { echo "flaresolverr runs a process as another uid: $others" >&2; exit 1; }
echo "flaresolverr solves a page as uid 1000"
echo "smoke test passed"
