#!/bin/bash
# Apuntafy - Release Script
# Crea un release desde develop hacia main
#
# Uso: ./scripts/git-flow/release.sh <version>
# Ejemplo: ./scripts/git-flow/release.sh 1.0.0

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Error: Debes especificar una versión."
    echo "   Uso: ./scripts/git-flow/release.sh <version>"
    echo "   Ejemplo: ./scripts/git-flow/release.sh 1.0.0"
    exit 1
fi

# Validar formato de versión (semver básico)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo "❌ Error: La versión debe seguir formato semver (X.Y.Z o X.Y.Z-tag)"
    exit 1
fi

TAG="v$VERSION"

echo "🚀 Apuntafy Release"
echo "==================="
echo "Versión: $VERSION"
echo "Tag: $TAG"
echo ""

# Verificar que estamos en develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "⚠️  Debes estar en la branch 'develop' para crear un release."
    echo "   Ejecuta: git checkout develop"
    exit 1
fi

# Verificar que no hay cambios sin commitear
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Tienes cambios sin commitear. Commitea o stashea antes de continuar."
    exit 1
fi

# Verificar que develop está actualizado con origin
echo "📥 Actualizando develop..."
git fetch origin develop
LOCAL=$(git rev-parse develop)
REMOTE=$(git rev-parse origin/develop)
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "⚠️  Tu branch develop no está sincronizada con origin."
    echo "   Ejecuta: git pull origin develop"
    exit 1
fi

# Verificar que el tag no existe
if git rev-parse "$TAG" > /dev/null 2>&1; then
    echo "❌ Error: El tag $TAG ya existe."
    exit 1
fi

echo ""
read -p "¿Continuar con el release $TAG? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelado."
    exit 0
fi

echo ""
echo "🔀 Cambiando a main..."
git checkout main

echo "📥 Actualizando main..."
git pull origin main

echo "🔀 Merging develop into main..."
git merge --no-ff develop -m "release: $TAG"

echo "🏷️  Creando tag $TAG..."
git tag -a "$TAG" -m "Release $VERSION"

echo ""
echo "✅ Release preparado localmente!"
echo ""
echo "📋 Para completar el release, ejecuta:"
echo "   git push origin main --tags"
echo ""
echo "⚠️  Después del push, vuelve a develop:"
echo "   git checkout develop"
echo ""
