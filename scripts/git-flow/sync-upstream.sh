#!/bin/bash
# Apuntafy - Upstream Sync Script
# Sincroniza cambios del upstream (cal.com) de forma aislada
#
# Uso: ./scripts/git-flow/sync-upstream.sh [version]
# Ejemplo: ./scripts/git-flow/sync-upstream.sh v4.6.0

set -e

VERSION=${1:-$(date +%Y-%m-%d)}
SYNC_BRANCH="upstream-sync/$VERSION"

echo "🔄 Apuntafy Upstream Sync"
echo "========================="
echo ""

# Verificar que estamos en develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "⚠️  Debes estar en la branch 'develop' para sincronizar upstream."
    echo "   Ejecuta: git checkout develop"
    exit 1
fi

# Verificar que no hay cambios sin commitear
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Tienes cambios sin commitear. Commitea o stashea antes de continuar."
    exit 1
fi

# Verificar que upstream está configurado
if ! git remote get-url upstream > /dev/null 2>&1; then
    echo "⚠️  Remote 'upstream' no está configurado."
    echo "   Ejecuta: git remote add upstream https://github.com/calcom/cal.com.git"
    exit 1
fi

echo "📦 Creando branch de sync: $SYNC_BRANCH"
git checkout -b "$SYNC_BRANCH"

echo ""
echo "📥 Fetching upstream..."
git fetch upstream

echo ""
echo "🔀 Merging upstream/main..."
echo ""

if git merge upstream/main --no-edit; then
    echo ""
    echo "✅ Merge exitoso sin conflictos!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "   1. Correr tests: yarn test"
    echo "   2. Verificar build: yarn build"
    echo "   3. Si todo está bien, ejecuta:"
    echo "      git checkout develop"
    echo "      git merge --no-ff $SYNC_BRANCH"
    echo "      git branch -d $SYNC_BRANCH"
    echo ""
else
    echo ""
    echo "⚠️  Hay conflictos que resolver manualmente."
    echo ""
    echo "📋 Pasos para resolver:"
    echo "   1. Resolver conflictos en los archivos marcados"
    echo "   2. git add <archivos>"
    echo "   3. git commit"
    echo "   4. Correr tests: yarn test"
    echo "   5. Verificar build: yarn build"
    echo "   6. Cuando esté listo:"
    echo "      git checkout develop"
    echo "      git merge --no-ff $SYNC_BRANCH"
    echo "      git branch -d $SYNC_BRANCH"
    echo ""
fi
