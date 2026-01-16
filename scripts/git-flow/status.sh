#!/bin/bash
# Apuntafy - Git Flow Status
# Muestra el estado actual del flujo de trabajo

echo "📊 Apuntafy Git Flow Status"
echo "==========================="
echo ""

# Branch actual
CURRENT=$(git branch --show-current)
echo "🌿 Branch actual: $CURRENT"
echo ""

# Verificar configuración de remotes
echo "📡 Remotes:"
git remote -v | head -4
echo ""

# Branches permanentes
echo "📌 Branches permanentes:"
echo -n "   main:    "
if git show-ref --verify --quiet refs/heads/main; then
    MAIN_COMMIT=$(git rev-parse --short main)
    echo "✅ ($MAIN_COMMIT)"
else
    echo "❌ No existe localmente"
fi

echo -n "   develop: "
if git show-ref --verify --quiet refs/heads/develop; then
    DEV_COMMIT=$(git rev-parse --short develop)
    echo "✅ ($DEV_COMMIT)"
else
    echo "❌ No existe localmente"
fi
echo ""

# Branches temporales
echo "🌿 Branches temporales:"
FEATURES=$(git branch --list 'feature/*' 2>/dev/null)
FIXES=$(git branch --list 'fix/*' 2>/dev/null)
SYNCS=$(git branch --list 'upstream-sync/*' 2>/dev/null)

if [ -n "$FEATURES" ]; then
    echo "   Features:"
    echo "$FEATURES" | sed 's/^/      /'
fi

if [ -n "$FIXES" ]; then
    echo "   Fixes:"
    echo "$FIXES" | sed 's/^/      /'
fi

if [ -n "$SYNCS" ]; then
    echo "   Upstream syncs:"
    echo "$SYNCS" | sed 's/^/      /'
fi

if [ -z "$FEATURES" ] && [ -z "$FIXES" ] && [ -z "$SYNCS" ]; then
    echo "   (ninguna)"
fi
echo ""

# Diferencia entre branches
if git show-ref --verify --quiet refs/heads/main && git show-ref --verify --quiet refs/heads/develop; then
    AHEAD=$(git rev-list --count main..develop)
    BEHIND=$(git rev-list --count develop..main)
    echo "📈 develop vs main:"
    echo "   Ahead: $AHEAD commits"
    echo "   Behind: $BEHIND commits"
    echo ""
fi

# Tags recientes
echo "🏷️  Tags recientes:"
TAGS=$(git tag --sort=-creatordate | head -5)
if [ -n "$TAGS" ]; then
    echo "$TAGS" | sed 's/^/   /'
else
    echo "   (ninguno)"
fi
echo ""

# Estado del working directory
CHANGES=$(git status --porcelain | wc -l | tr -d ' ')
if [ "$CHANGES" -gt 0 ]; then
    echo "⚠️  Cambios pendientes: $CHANGES archivos"
else
    echo "✅ Working directory limpio"
fi
echo ""
