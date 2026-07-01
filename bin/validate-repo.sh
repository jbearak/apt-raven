#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

if [ ! -f dists/stable/Release ]; then
  echo "apt repository is not populated yet; skipping generated metadata validation"
  exit 0
fi

for required in \
  raven-archive-keyring.gpg \
  dists/stable/InRelease \
  dists/stable/Release.gpg \
  dists/stable/main/binary-amd64/Packages \
  dists/stable/main/binary-amd64/Packages.gz \
  dists/stable/main/binary-arm64/Packages \
  dists/stable/main/binary-arm64/Packages.gz; do
  test -f "$required" || fail "missing $required"
done

gpgv --keyring ./raven-archive-keyring.gpg dists/stable/InRelease >/dev/null 2>&1 \
  || fail "InRelease signature verification failed"
gpgv --keyring ./raven-archive-keyring.gpg dists/stable/Release.gpg dists/stable/Release >/dev/null 2>&1 \
  || fail "Release.gpg signature verification failed"

gzip -t dists/stable/main/binary-amd64/Packages.gz
gzip -t dists/stable/main/binary-arm64/Packages.gz

grep -F "Architectures: amd64 arm64" dists/stable/Release >/dev/null \
  || fail "Release missing architectures"
grep -F "Components: main" dists/stable/Release >/dev/null \
  || fail "Release missing component"

shopt -s nullglob
for deb in pool/main/r/raven/*.deb; do
  package="$(dpkg-deb --field "$deb" Package)"
  arch="$(dpkg-deb --field "$deb" Architecture)"
  test "$package" = "raven" || fail "$deb Package field is $package"
  case "$arch" in
    amd64|arm64) ;;
    *) fail "$deb has unsupported Architecture: $arch" ;;
  esac
  basename="$(basename "$deb")"
  grep -F "Filename: pool/main/r/raven/$basename" "dists/stable/main/binary-$arch/Packages" >/dev/null \
    || fail "$basename missing from binary-$arch Packages index"
done

echo "apt repository validation passed"
