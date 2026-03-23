#!/usr/bin/env bash
# Rebuild internal-ca-bundle.pem by concatenating the host's Caddy root (if present)
# with the PostgresCA shipped in this repo. This keeps Node TLS trust portable across hosts.

set -euo pipefail

bundle="$(cd "$(dirname "$0")" && pwd)/internal-ca-bundle.pem"
repo_ca="$(cd "$(dirname "$0")" && pwd)/ca-cert.pem"

declare -a candidates=(
  /opt/homebrew/var/lib/caddy/pki/authorities/local/root.crt  # macOS Homebrew
  /var/lib/caddy/pki/authorities/local/root.crt                # Linux defaults
  "$(cd "$(dirname "$0")" && pwd)/caddy-root.crt"              # optional checked-in copy
)

rm -f "$bundle"

found=0
for c in "${candidates[@]}"; do
  if [ -f "$c" ]; then
    cat "$c" >> "$bundle"
    found=1
    # Keep going to allow multiple roots if present, but typically only one will match.
  fi
done

# Always append the Postgres CA (canonical trust anchor)
cat "$repo_ca" >> "$bundle"

echo "Wrote bundle to $bundle"
if [ "$found" -eq 0 ]; then
  echo "Note: no Caddy root found; bundle contains only PostgresCA. If Caddy uses its own root on this host, add it at one of:"
  printf '  - %s\n' "${candidates[@]}"
fi
