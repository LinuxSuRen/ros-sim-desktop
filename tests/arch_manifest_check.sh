#!/usr/bin/env bash
# Verify a published manifest list carries both amd64 and arm64.
# Usage: tests/arch_manifest_check.sh <image-ref>
set -euo pipefail

IMAGE="${1:?usage: arch_manifest_check.sh <image-ref>}"

platforms="$(docker manifest inspect "$IMAGE" 2>/dev/null \
  | grep -o '"architecture": *"[^"]*"' \
  | sed 's/.*"\([^"]*\)"$/\1/' | sort -u)"

echo "architectures found: $(echo "$platforms" | tr '\n' ' ')"

missing=0
for want in amd64 arm64; do
  if ! echo "$platforms" | grep -qx "$want"; then
    echo "FAIL: $want missing from manifest"
    missing=1
  fi
done

[ "$missing" = 0 ] && echo "ARCH MANIFEST OK: $IMAGE"
exit "$missing"
