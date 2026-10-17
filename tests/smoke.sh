#!/usr/bin/env bash
# Smoke test: run an image, wait for noVNC, verify the graphics stack is alive.
# Usage: tests/smoke.sh <image-ref> [mode]
set -euo pipefail

IMAGE="${1:?usage: smoke.sh <image-ref> [mode]}"
MODE="${2:-rviz-vnc}"
NAME="sim-desktop-smoke-$$"

cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker run -d --name "$NAME" -p 16080:6080 "$IMAGE" "$MODE" >/dev/null

ok=0
for _ in $(seq 1 40); do
  if curl -fsS -o /dev/null "http://127.0.0.1:16080/vnc.html" ; then ok=1; break; fi
  sleep 1
done
if [ "$ok" != 1 ]; then
  echo "FAIL: noVNC did not come up on :16080"
  docker logs "$NAME" | tail -40 || true
  exit 1
fi
echo "PASS: noVNC reachable"

if ! docker exec "$NAME" bash -c 'pgrep -x Xvfb' >/dev/null 2>&1; then
  echo "FAIL: Xvfb not running"
  docker logs "$NAME" | tail -40 || true
  exit 1
fi
echo "PASS: Xvfb alive"

if ! docker exec "$NAME" bash -c 'pgrep -f x11vnc' >/dev/null 2>&1; then
  echo "FAIL: x11vnc not running"
  docker logs "$NAME" | tail -40 || true
  exit 1
fi
echo "PASS: x11vnc alive"

echo "SMOKE OK: $IMAGE ($MODE)"
