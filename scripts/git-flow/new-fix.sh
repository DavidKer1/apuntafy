#!/bin/bash
# Apuntafy - New Fix Script
# Crea una nueva branch de fix desde develop
#
# Uso: ./scripts/git-flow/new-fix.sh <nombre>
# Ejemplo: ./scripts/git-flow/new-fix.sh calendar-overlap

set -e

NAME=$1

if [ -z "$NAME" ]; then
    echo "❌ Error: Debes especificar un nombre para el fix."
    echo "   Uso: ./scripts/git-flow/new-fix.sh <nombre>"
    echo "   Ejemplo: ./scripts/git-flow/new-fix.sh calendar-overlap"
    exit 1
fi

# Limpiar nombre (reemplazar espacios con guiones, lowercase)
NAME=$(echo "$NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
BRANCH="fix/$NAME"

echo "🔧 Apuntafy New Fix"
echo "==================="
echo "Branch: $BRANCH"
echo ""

# Verificar que estamos en develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "⚠️  Debes estar en la branch 'develop' para crear un fix."
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
echo "✅ Fix branch creada!"
echo ""
echo "📋 Cuando termines, ejecuta:"
echo "   git checkout develop"
echo "   git merge --no-ff $BRANCH"
echo "   git branch -d $BRANCH"
echo "   git push origin develop"
echo ""
