# Apuntafy Git Flow Scripts

Scripts de utilidad para manejar el flujo de trabajo de branching de Apuntafy.

## Requisitos

- Bash
- Git configurado con remotes `origin` y `upstream`

## Scripts disponibles

### `status.sh`

Muestra el estado actual del flujo de trabajo:
- Branch actual
- Estado de branches permanentes (`main`, `develop`)
- Branches temporales activas
- Diferencia entre `develop` y `main`
- Tags recientes

```bash
./scripts/git-flow/status.sh
```

### `new-feature.sh`

Crea una nueva branch de feature desde `develop`:

```bash
./scripts/git-flow/new-feature.sh whatsapp-booking
# Crea: feature/whatsapp-booking
```

### `new-fix.sh`

Crea una nueva branch de fix desde `develop`:

```bash
./scripts/git-flow/new-fix.sh calendar-overlap
# Crea: fix/calendar-overlap
```

### `sync-upstream.sh`

Sincroniza cambios del upstream (cal.com) de forma aislada:

```bash
# Con versión específica
./scripts/git-flow/sync-upstream.sh v4.6.0

# Sin versión (usa fecha actual)
./scripts/git-flow/sync-upstream.sh
```

### `release.sh`

Crea un release desde `develop` hacia `main`:

```bash
./scripts/git-flow/release.sh 1.0.0
# Crea tag: v1.0.0
```

## Flujo típico de trabajo

### Desarrollo diario

```bash
# Ver estado actual
./scripts/git-flow/status.sh

# Crear nueva feature
./scripts/git-flow/new-feature.sh mi-feature

# Trabajar en la feature...
git add .
git commit -m "feat: descripción del cambio"

# Terminar feature
git checkout develop
git merge --no-ff feature/mi-feature
git branch -d feature/mi-feature
git push origin develop
```

### Sincronización con upstream

```bash
# Sincronizar con nueva versión de cal.com
./scripts/git-flow/sync-upstream.sh v4.6.0

# Resolver conflictos si hay...
# Correr tests...

git checkout develop
git merge --no-ff upstream-sync/v4.6.0
git branch -d upstream-sync/v4.6.0
git push origin develop
```

### Crear release

```bash
# Verificar que develop está estable
yarn test
yarn build

# Crear release
./scripts/git-flow/release.sh 1.0.0

# Push
git push origin main --tags
git checkout develop
```

## Reglas del modelo

1. **Nunca trabajar directo en `main`**
2. **Nunca mergear upstream directo a `main`**
3. **Todo pasa por `develop`**
4. **Las branches temporales se eliminan después del merge**
5. **Upstream siempre se aísla en `upstream-sync/*`**

## Diagrama de flujo

```
upstream/main
      ↓
upstream-sync/*
      ↓
develop  ← feature/* ← fix/*
      ↓
main (release + tag)
```
