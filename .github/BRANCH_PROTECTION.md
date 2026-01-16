# GitHub Branch Protection Settings (Manual Configuration)
# Este archivo documenta las configuraciones de protección de branches
# que deben aplicarse manualmente en GitHub (Settings > Branches)

## Branch: main

### Protección recomendada:
branch_protection:
  main:
    # Requiere PR antes de merge
    require_pull_request:
      enabled: true
      required_approving_review_count: 0  # Single developer, puede ser 0
      dismiss_stale_reviews: true
      require_code_owner_reviews: false
    
    # Requiere status checks
    require_status_checks:
      enabled: true
      strict: true  # Branch debe estar actualizada antes de merge
      contexts:
        - "type-check"
        - "lint"
    
    # Restricciones adicionales
    enforce_admins: false  # Permite bypass para emergencias
    allow_force_pushes: false
    allow_deletions: false
    
    # Solo permite merge desde develop
    restrict_pushes:
      enabled: true
      # Solo el bot de CI o tú pueden pushear

## Branch: develop

### Protección recomendada (más permisiva):
branch_protection:
  develop:
    require_pull_request:
      enabled: false  # Single developer puede commitear directo
    
    require_status_checks:
      enabled: false  # Opcional para velocidad de desarrollo
    
    allow_force_pushes: false  # Evitar reescribir historial
    allow_deletions: false

## Pasos para configurar en GitHub:

1. Ir a: https://github.com/DavidKer1/apuntafy/settings/branches

2. Click "Add branch protection rule"

3. Para `main`:
   - Branch name pattern: `main`
   - ☑️ Require a pull request before merging
   - ☑️ Require status checks to pass before merging
   - ☑️ Require branches to be up to date before merging
   - ☐ Do not allow bypassing the above settings (opcional)
   - Click "Create"

4. Para `develop`:
   - Branch name pattern: `develop`
   - ☐ Require a pull request before merging
   - ☑️ Do not allow deletions
   - Click "Create"

## Notas:

- Como single developer, las protecciones son más para prevenir
  errores accidentales que para control de acceso.
  
- Puedes ajustar estas reglas según necesites. Lo importante es
  que `main` nunca reciba pushes directos.
