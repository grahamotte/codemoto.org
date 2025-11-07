#!/usr/bin/env bash
set -Eeuo pipefail

# --- Fixed values ---
DEPLOY_USER="deploy"
DEPLOY_PASSWORD="$(openssl rand -hex 16)"   # 32-char random hex password

# --- Safe temp dir (macOS + Linux) ---
mktemp_dir() { mktemp -d 2>/dev/null || mktemp -d -t sshkeygen; }
TMPDIR="$(mktemp_dir)"
cleanup() { [[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] && rm -rf -- "$TMPDIR"; }
trap cleanup EXIT

umask 077
PRIV="$TMPDIR/id_rsa"
PUB="$PRIV.pub"
COMMENT="${DEPLOY_USER}@$(hostname -s || echo host)"

# --- Generate RSA key (PEM format, 4096 bits, no passphrase) ---
ssh-keygen -t rsa -b 4096 -m PEM -N "" -C "$COMMENT" -f "$PRIV" -q

# --- Read key data ---
PUBKEY="$(cat "$PUB")"
PRIVATE_KEY_CONTENT="$(cat "$PRIV")"

# --- Compute fingerprint in MD5 colon-separated format ---
if FP_LINE="$(ssh-keygen -lf "$PUB" -E md5 2>/dev/null)"; then
  DEPLOY_SSH_KEY_FINGERPRINT="$(echo "$FP_LINE" | awk '{print $2}' | sed 's/^MD5://')"
else
  BODY="$(echo "$PUBKEY" | awk '{print $2}')"
  if command -v openssl >/dev/null 2>&1; then
    HEX="$(printf '%s' "$BODY" | base64 --decode 2>/dev/null | openssl md5 -r | awk '{print $1}')"
  else
    HEX="$(printf '%s' "$BODY" | base64 --decode 2>/dev/null | md5 | awk '{print $NF}')"
  fi
  DEPLOY_SSH_KEY_FINGERPRINT="$(echo "$HEX" | sed 's/../&:/g;s/:$//')"
fi

# --- Output environment variables in expected format ---
printf 'DEPLOY_USER="%s"\n' "$DEPLOY_USER"
printf 'DEPLOY_PASSWORD="%s"\n' "$DEPLOY_PASSWORD"
printf 'DEPLOY_SSH_KEY_PUB="%s"\n' "$PUBKEY"
printf 'DEPLOY_SSH_KEY_FINGERPRINT="%s"\n' "$DEPLOY_SSH_KEY_FINGERPRINT"
printf 'DEPLOY_SSH_KEY="%s"\n' "$PRIVATE_KEY_CONTENT"

# --- Secure deletion of temporary files ---
if command -v shred >/dev/null 2>&1; then
  shred -u -z "$PRIV" "$PUB" || rm -f "$PRIV" "$PUB"
else
  case "$(uname -s)" in
    Darwin) rm -P "$PRIV" "$PUB" 2>/dev/null || rm -f "$PRIV" "$PUB" ;;
    *)      rm -f "$PRIV" "$PUB" ;;
  esac
fi
