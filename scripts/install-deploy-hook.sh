#!/usr/bin/env bash
# Instala o hook post-commit para fazer deploy automático no Netlify após cada commit.
# Execute uma vez: ./scripts/install-deploy-hook.sh

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK_FILE="$REPO_ROOT/.git/hooks/post-commit"

cat > "$HOOK_FILE" << 'HOOK'
#!/usr/bin/env bash
# Deploy automático no Netlify após cada commit
cd "$(git rev-parse --show-toplevel)"
npm run deploy
HOOK

chmod +x "$HOOK_FILE"
echo "Hook instalado: cada 'git commit' vai disparar deploy no Netlify."
echo "Para remover: rm .git/hooks/post-commit"
