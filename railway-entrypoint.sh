#!/bin/sh
# Railway entrypoint for the Docker registry: port, password login, storage cleanup.
set -eu

CONFIG=/etc/distribution/config.yml
DATA=/var/lib/registry
mkdir -p "$DATA"

export REGISTRY_HTTP_ADDR="0.0.0.0:${PORT:-5000}"
export REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY="$DATA"
# Railway's proxy ends TLS. Relative Location headers keep upload URLs on the
# client's https address instead of the registry's own http one.
export REGISTRY_HTTP_RELATIVEURLS=true

# Login. Without a password the registry would accept anyone's pushes, so with an
# empty REGISTRY_PASSWORD make one, keep it on the volume, and print it once.
USER_NAME="${REGISTRY_USERNAME:-admin}"
if [ -z "${REGISTRY_PASSWORD:-}" ]; then
  f="$DATA/.railway-password"
  [ -s "$f" ] || { head -c 18 /dev/urandom | base64 | tr -d '/+=' > "$f"; chmod 600 "$f"; }
  REGISTRY_PASSWORD="$(cat "$f")"
  echo "REGISTRY_PASSWORD is empty, so the registry uses a generated one for $USER_NAME: $REGISTRY_PASSWORD"
  echo "(saved on the volume; set REGISTRY_PASSWORD to choose your own)"
fi
mkdir -p /etc/distribution/auth
htpasswd -Bbn "$USER_NAME" "$REGISTRY_PASSWORD" > /etc/distribution/auth/htpasswd
unset REGISTRY_PASSWORD
export REGISTRY_AUTH=htpasswd
export REGISTRY_AUTH_HTPASSWD_REALM="${REGISTRY_REALM:-Registry}"
export REGISTRY_AUTH_HTPASSWD_PATH=/etc/distribution/auth/htpasswd

# Deleting a tag or manifest only unlinks it; the layers stay on disk until a
# garbage collection. It's only safe while nothing is pushing, so run it here,
# before the registry starts. Only blobs no manifest refers to are removed.
if [ "${GC_ON_START:-true}" = "true" ] && [ -d "$DATA/docker" ]; then
  echo "Garbage collection: removing layers no image uses"
  registry garbage-collect "$CONFIG" 2>&1 | grep -vE 'marking (manifest|blob)' | tail -5 || echo "garbage collection failed; starting anyway"
fi

echo "Registry on port ${PORT:-5000}, user $USER_NAME, storage $DATA ($(df -h "$DATA" | awk 'NR==2{print $4" free of "$2}'))"
exec registry serve "$CONFIG"
