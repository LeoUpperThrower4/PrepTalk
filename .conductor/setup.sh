#!/usr/bin/env bash
# Conductor setup: runs once per new workspace, from the workspace directory.
set -euo pipefail

echo "==> Node $(node --version 2>/dev/null || echo 'MISSING') / npm $(npm --version 2>/dev/null || echo 'MISSING')"

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

# .env* files are copied into new workspaces by Conductor's Files to copy.
# If none landed here, try pulling from Vercel; otherwise tell the user.
if ! ls .env* >/dev/null 2>&1; then
  if command -v vercel >/dev/null 2>&1 && [ -d "${CONDUCTOR_ROOT_PATH:-.}/.vercel" ]; then
    cp -R "${CONDUCTOR_ROOT_PATH}/.vercel" .vercel
    vercel env pull .env.local --yes || echo "WARN: vercel env pull failed"
  fi
fi

if ! ls .env* >/dev/null 2>&1; then
  cat <<'MSG'
WARN: no .env file in this workspace.
App needs: MONGODB_URI, JWT_SECRET, ABLY_API_KEY, GEMINI_API, GEMINI_MODEL
Create .env.local in the repo root; new workspaces copy .env* automatically.
MSG
fi

echo "==> Setup done"
