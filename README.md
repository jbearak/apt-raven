# apt-raven

Static apt repository for [Raven](https://github.com/jbearak/raven), served by
GitHub Pages.

This repository is updated automatically by Raven's release workflow. It stores
signed Debian repository metadata and `.deb` packages for Ubuntu and Debian-like
CI environments.

## Install

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://jbearak.github.io/apt-raven/raven-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/raven-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/raven-archive-keyring.gpg] https://jbearak.github.io/apt-raven stable main" \
  | sudo tee /etc/apt/sources.list.d/raven.list >/dev/null
sudo apt-get update
sudo apt-get install -y raven
```

Pin a release for reproducible CI:

```bash
sudo apt-get install -y raven=0.12.0-1
```

## Repository Layout

Raven's release workflow writes:

```text
raven-archive-keyring.gpg
dists/stable/InRelease
dists/stable/Release
dists/stable/Release.gpg
dists/stable/main/binary-amd64/Packages.gz
dists/stable/main/binary-arm64/Packages.gz
pool/main/r/raven/*.deb
```

## Maintenance

Do not hand-edit generated repository metadata. Raven's release workflow opens a
PR here after each stable Raven release; CI validates signatures and package
indexes before merge.
