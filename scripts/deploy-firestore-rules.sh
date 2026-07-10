#!/bin/bash
set -euo pipefail
# Publica regras do Firestore no banco "istock" (obrigatório para o app iOS ler/escrever).
# Uso: ./scripts/deploy-firestore-rules.sh
cd "$(dirname "$0")/.."
echo "→ Publicando regras Firestore (banco: istock, projeto: istock-4771d)"
echo "  Requer login: npx firebase-tools login"
npx --yes firebase-tools@latest deploy --only firestore:istock --project istock-4771d
