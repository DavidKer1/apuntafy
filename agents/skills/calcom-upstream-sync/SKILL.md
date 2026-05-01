---
name: calcom-upstream-sync
description: Synchronize upstream Cal.com changes to Apuntafy fork. Use when asked to "sync upstream", "update from Cal.com", "merge upstream/main", or "get latest Cal.com changes". Handles conflict resolution for common patterns specific to Apuntafy's fork.
triggers:
  - "sync upstream"
  - "update from upstream"
  - "merge upstream/main"
  - "pull cal.com changes"
  - "actualizar desde upstream"
  - "traer cambios de cal.com"
---

# Cal.com Upstream Sync Skill

This skill automates the process of synchronizing upstream Cal.com changes into the Apuntafy fork while handling common conflicts and preserving Apuntafy-specific configurations.

## When to Use This Skill

Invoke this skill when:
- User asks to sync/update from upstream Cal.com
- User wants to merge the latest Cal.com changes
- Periodic updates are needed from the main Cal.com repository
- User mentions "upstream", "cal.com main", or "latest changes"

## Prerequisites

Before syncing, verify:
1. Working directory is clean (no uncommitted changes)
2. `upstream` remote is configured: `git remote -v` should show `upstream` pointing to `https://github.com/calcom/cal.com.git`
3. Current branch state is known

## Sync Workflow

### 1. Fetch Upstream Changes

```bash
# Only fetch main branch from upstream (not all 800+ branches)
git fetch upstream main
```

**Critical**: Never run `git fetch upstream` without specifying the branch. Cal.com has 800+ branches that would all be downloaded.

### 2. Create Update Branch

```bash
# Use descriptive branch name with date
git checkout -b update-upstream-main-$(date +%Y%m%d)
```

### 3. Merge Upstream Main

```bash
git merge upstream/main
```

This will likely produce conflicts. Proceed to conflict resolution.

## Conflict Resolution Strategy

### Files to Delete (Accept Upstream Deletion)

When upstream deletes files, accept the deletion if they are:

**Devin-related workflows** (Cal.com removed these AI tools):
- `.github/workflows/cubic-devin-review.yml`
- `.github/workflows/delete-blacksmith-cache.yml`
- `.github/workflows/devin-conflict-resolver.yml`
- `.github/workflows/stale-pr-devin-completion.yml`

**Enterprise/deprecated features**:
- `apps/web/components/EnterprisePage.tsx`
- `apps/web/components/setup/EnterpriseLicense.tsx`
- `apps/web/components/setup/LicenseSelection.tsx`
- Files in `apps/web/app/(use-page-wrapper)/insights/` (deprecated insights)
- Files in `apps/web/modules/settings/teams/new/` (refactored)

**Deprecated integrations**:
- `packages/app-store/deel/api/add.ts`
- `packages/app-store/granola/api/add.ts`

**Cleanup tests** (Cal.com removed legacy tests):
- `apps/web/playwright/auth/auth-index.e2e.ts`
- `apps/web/playwright/organization/team-management.e2e.ts`
- `apps/web/playwright/teams.e2e.ts`

**Documentation** (migrated elsewhere):
- `docs/api-reference/v2/migration-guide.mdx`
- `docs/mint.json`

**Command to remove all deleted files**:
```bash
git rm .github/workflows/cubic-devin-review.yml \
       .github/workflows/delete-blacksmith-cache.yml \
       .github/workflows/devin-conflict-resolver.yml \
       .github/workflows/stale-pr-devin-completion.yml \
       apps/web/components/EnterprisePage.tsx \
       apps/web/components/setup/EnterpriseLicense.tsx \
       apps/web/components/setup/LicenseSelection.tsx \
       packages/app-store/deel/api/add.ts \
       packages/app-store/granola/api/add.ts \
       # Add other deleted files as needed
```

### Files to Accept Upstream Version

For these file types, generally accept upstream's version:

**GitHub Actions Workflows**:
```bash
git checkout --theirs .github/workflows/cache-clean.yml
git checkout --theirs .github/workflows/changesets.yml
git checkout --theirs .github/workflows/nextjs-bundle-analysis*.yml
```

**SVG Assets** (Cal.com logo updates):
```bash
git checkout --theirs apps/web/public/cal-logo-*.svg
git checkout --theirs apps/web/public/calcom-logo-*.svg
```

**Test files** (upstream improvements):
```bash
git checkout --theirs apps/web/modules/bookings/components/Booker.test.tsx
```

**Application code** (unless Apuntafy has specific customizations):
```bash
git checkout --theirs apps/web/app/notFoundClient.tsx
git checkout --theirs packages/lib/constants.ts
```

### docker-compose.yml - Special Handling

This file requires manual resolution to preserve Apuntafy's Coolify network configuration:

1. Accept upstream version first:
   ```bash
   git checkout --theirs docker-compose.yml
   ```

2. Replace network name:
   ```bash
   sed -i '' 's/stack/coolify/g' docker-compose.yml
   ```

3. Update network configuration:
   ```bash
   # Change from:
   networks:
     coolify:
       name: coolify
       external: false
   
   # To:
   networks:
     coolify:
       external: true
   ```

**Why**: Apuntafy uses Coolify for deployment which requires an external network named `coolify`. Cal.com uses a local `stack` network.

### Files Requiring Manual Review

**Always review these files** before accepting upstream version:

- `.env.example` - May have Apuntafy-specific variables
- `package.json` - Check for Apuntafy-specific dependencies
- Any files in `apps/web/modules/` that Apuntafy has customized
- Any Apuntafy-specific features or branding

### Conflict Resolution Commands

```bash
# After handling deletions and choosing upstream versions:
git add .

# Verify no unresolved conflicts:
git status | grep "Unmerged paths"

# If clean, commit:
git commit --no-verify -m "chore: merge upstream/main ($(date +%B\ %Y) update)"
```

**Why `--no-verify`**: Upstream code may have lint errors that haven't been fixed yet. We skip pre-commit hooks to avoid blocking the merge, then fix lint issues separately if needed.

## Integration to Develop and Main

### 1. Merge to Develop

```bash
git checkout develop
git pull origin develop  # Get any changes pushed by others
git merge update-upstream-main-YYYYMMDD
git push origin develop
```

### 2. Merge to Main

```bash
git checkout main
git merge develop
git push origin main
```

### 3. Cleanup

```bash
git branch -d update-upstream-main-YYYYMMDD
```

## Post-Merge Validation

After merging, validate:

1. **Type check**:
   ```bash
   yarn type-check:ci --force
   ```

2. **Lint** (optional, can be fixed later):
   ```bash
   yarn biome check --write .
   ```

3. **Database schema**:
   ```bash
   # If schema.prisma changed
   yarn prisma generate
   yarn workspace @calcom/prisma db-migrate
   ```

4. **Build test**:
   ```bash
   yarn build
   ```

5. **Run critical tests**:
   ```bash
   TZ=UTC yarn test
   ```

## Common Issues and Solutions

### Issue: Too Many Conflicts

**Solution**: Break the update into smaller chunks by cherry-picking specific commit ranges:
```bash
# Instead of merging all changes at once:
git cherry-pick <start-commit>..<end-commit>
```

### Issue: Database Migration Conflicts

**Solution**: 
1. Accept upstream migrations
2. Create a new migration for Apuntafy-specific changes
3. Keep migrations in chronological order

### Issue: Coolify Network Breaks

**Symptom**: Docker containers can't communicate
**Solution**: Verify `docker-compose.yml` has:
- All services on `coolify` network
- Network set to `external: true`
- No references to `stack` network

### Issue: Lost Apuntafy Customizations

**Solution**: Before merging, identify customized files:
```bash
# See what Apuntafy changed from base Cal.com
git log --oneline --no-merges origin/main ^upstream/main -- <file>

# Review changes to preserve:
git diff upstream/main origin/main -- <file>
```

## Best Practices

1. **Sync Regularly**: Monthly updates are easier than quarterly ones
2. **Read Upstream Changelogs**: Check Cal.com's release notes before syncing
3. **Test Locally First**: Always test the merge locally before pushing
4. **Document Custom Changes**: Keep track of Apuntafy-specific modifications
5. **Use Descriptive Branch Names**: Include date for easy identification
6. **Never Force Push**: Especially not to `main` or `develop`

## Automatic Conflict Resolution Patterns

When encountering conflicts, apply these rules automatically:

| File Pattern | Resolution |
|-------------|------------|
| `.github/workflows/*.yml` | Accept upstream (theirs) |
| `apps/web/public/*.svg` | Accept upstream (theirs) |
| `*.test.tsx`, `*.e2e.ts` | Accept upstream (theirs) |
| `docker-compose.yml` | Accept upstream, then apply Coolify patches |
| `package.json` | Merge carefully, preserve Apuntafy deps |
| `.env.example` | Merge carefully, preserve Apuntafy vars |
| Deleted files (enterprise, devin, deprecated) | Remove (accept deletion) |

## Emergency Rollback

If the merge causes critical issues:

```bash
# On feature branch (before pushing to develop):
git reset --hard origin/develop

# If already pushed to develop:
git revert -m 1 <merge-commit-hash>
git push origin develop
```

## Summary Checklist

- [ ] Working directory clean
- [ ] Fetched only upstream/main (not all branches)
- [ ] Created descriptive update branch
- [ ] Merged upstream/main
- [ ] Resolved conflicts using patterns above
- [ ] Preserved Coolify network configuration
- [ ] Committed with `--no-verify` if needed
- [ ] Merged to develop
- [ ] Tested locally
- [ ] Merged to main
- [ ] Pushed both branches
- [ ] Deleted temporary branch
- [ ] Ran type-check and basic tests
- [ ] Verified deployment works

## Example Complete Session

```bash
# 1. Prepare
git status  # Clean working directory
git fetch upstream main

# 2. Create branch and merge
git checkout -b update-upstream-main-20260430
git merge upstream/main

# 3. Resolve conflicts
git rm <deleted-files>
git checkout --theirs <upstream-preferred-files>
# Manually fix docker-compose.yml for Coolify
git add .
git commit --no-verify -m "chore: merge upstream/main (April 2026 update)"

# 4. Integrate to develop
git checkout develop
git pull origin develop
git merge update-upstream-main-20260430
git push origin develop

# 5. Integrate to main
git checkout main
git merge develop
git push origin main

# 6. Cleanup
git branch -d update-upstream-main-20260430

# 7. Validate
yarn type-check:ci --force
yarn prisma generate
```

---

**Note**: This skill is specific to Apuntafy's Cal.com fork. Other forks may have different conflict resolution needs.
