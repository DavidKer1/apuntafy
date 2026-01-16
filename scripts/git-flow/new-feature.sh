#!/bin/bash
# Apuntafy - New Feature Script
# Crea una nueva branch de feature desde develop
#
# Uso: ./scripts/git-flow/new-feature.sh <nombre>
# Ejemplo: ./scripts/git-flow/new-feature.sh whatsapp-booking

set -e

NAME=$1

if [ -z "$NAME" ]; then
    echo "❌ Error: Debes especificar un nombre para la feature."
    echo "   Uso: ./scripts/git-flow/new-feature.sh <nombre>"
    echo "   Ejemplo: ./scripts/git-flow/new-feature.sh whatsapp-booking"
    exit 1
fi

# Limpiar nombre (reemplazar espacios con guiones, lowercase)
NAME=$(echo "$NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
BRANCH="feature/$NAME"

echo "🌟 Apuntafy New Feature"
echo "======================="
echo "Branch: $BRANCH"
echo ""

# Verificar que estamos en develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "⚠️  Debes estar en la branch 'develop' para crear una feature."
    echo "   Ejecuta: git checkout develop"
    exit 1
fi

# Verificar que no hay cambios sin commitear
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Tienes cambios sin commitear. Commitea o stashea antes de continuar."
    exit 1
fi

# Actualizar develop
echo "📥 Actualizando develop..."
git pull origin develop

echo ""
echo "🌿 Creando branch $BRANCH..."
git checkout -b "$BRANCH"

echo ""
echo "✅ Feature branch creada!"
echo ""
echo "📋 Cuando termines, ejecuta:"
echo "   git checkout develop"
echo "   git merge --no-ff $BRANCH"
echo "   git branch -d $BRANCH"
echo "   git push origin develop"
echo ""
