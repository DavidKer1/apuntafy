# Quick Reference: Cal.com Upstream Sync

## One-Line Commands

### Fetch Only Main Branch (Safe)
```bash
git fetch upstream main
```

### Create Update Branch with Date
```bash
git checkout -b update-upstream-main-$(date +%Y%m%d)
```

### Auto-Resolve Common Conflicts

#### Delete All Deprecated Files
```bash
git rm .github/workflows/{cubic-devin-review,delete-blacksmith-cache,devin-conflict-resolver,stale-pr-devin-completion}.yml \
  apps/web/components/{EnterprisePage,setup/EnterpriseLicense,setup/LicenseSelection}.tsx \
  "apps/web/app/(use-page-wrapper)/insights/UpgradeTipWrapper.tsx" \
  "apps/web/app/(use-page-wrapper)/settings/teams/new/page.tsx" \
  apps/web/modules/{ee/teams/components/TeamList,onboarding/hooks/useCreateTeam,settings/security/compliance/compliance-documents,settings/teams/new/create-new-team-view,shell/Tips,timezone-buddy/components/AvailabilitySliderTable}.tsx \
  apps/web/playwright/{auth/auth-index,organization/team-management,teams}.e2e.ts \
  "companion/app/(tabs)/(more)/index.tsx" \
  docs/{api-reference/v2/migration-guide.mdx,mint.json} \
  packages/app-store/{deel,granola}/api/add.ts \
  packages/features/ee/billing/service/seatTracking/SeatChangeTrackingService.ts \
  2>/dev/null || true
```

#### Accept Upstream for Workflows
```bash
git checkout --theirs .github/workflows/{cache-clean,changesets,nextjs-bundle-analysis-annotation,nextjs-bundle-analysis}.yml
```

#### Accept Upstream for SVG Assets
```bash
git checkout --theirs apps/web/public/{cal-logo-word-black,cal-logo-word-dark,cal-logo-word,calcom-logo-white-word}.svg
```

#### Accept Upstream for Common Files
```bash
git checkout --theirs apps/web/app/notFoundClient.tsx \
  apps/web/modules/bookings/components/Booker.test.tsx \
  apps/web/modules/onboarding/components/onboarding-{browser,invite-browser}-view.tsx \
  packages/app-store/famulor/api/add.ts \
  packages/lib/constants.ts
```

#### Fix docker-compose.yml for Coolify
```bash
git checkout --theirs docker-compose.yml && \
sed -i '' 's/stack/coolify/g' docker-compose.yml && \
git add docker-compose.yml
```

### Complete Conflict Resolution Sequence
```bash
# Remove deleted files
git rm $(git status | grep "deleted by them" | awk '{print $4}') 2>/dev/null || true

# Accept upstream for workflows and assets
git checkout --theirs .github/workflows/*.yml apps/web/public/*.svg 2>/dev/null || true

# Fix docker-compose
git checkout --theirs docker-compose.yml && sed -i '' 's/stack/coolify/g' docker-compose.yml

# Stage all
git add .

# Commit
git commit --no-verify -m "chore: merge upstream/main ($(date +%B\ %Y) update)"
```

## Full Workflow (Copy-Paste Ready)

### Option 1: Manual (Step-by-Step)
```bash
# 1. Prepare
git status
git fetch upstream main

# 2. Create branch
git checkout -b update-upstream-main-$(date +%Y%m%d)

# 3. Merge
git merge upstream/main

# 4. Resolve conflicts (if any)
git rm $(git status | grep "deleted by them" | awk '{print $4}') 2>/dev/null || true
git checkout --theirs .github/workflows/*.yml apps/web/public/*.svg
git checkout --theirs docker-compose.yml && sed -i '' 's/stack/coolify/g' docker-compose.yml
git add .
git commit --no-verify -m "chore: merge upstream/main ($(date +%B\ %Y) update)"

# 5. Merge to develop
git checkout develop
git pull origin develop
git merge update-upstream-main-$(date +%Y%m%d)
git push origin develop

# 6. Merge to main
git checkout main
git merge develop
git push origin main

# 7. Cleanup
git branch -d update-upstream-main-$(date +%Y%m%d)
```

### Option 2: Automated Script
```bash
# Make script executable (first time only)
chmod +x .claude/skills/calcom-upstream-sync/sync-upstream.sh

# Run with auto-resolution
./.claude/skills/calcom-upstream-sync/sync-upstream.sh --auto-resolve

# Or run interactively
./.claude/skills/calcom-upstream-sync/sync-upstream.sh
```

## Post-Merge Validation Commands

```bash
# Type check
yarn type-check:ci --force

# Regenerate Prisma types
yarn prisma generate

# Database migration (if schema changed)
yarn workspace @calcom/prisma db-migrate

# Run tests
TZ=UTC yarn test

# Build test
yarn build
```

## Emergency Rollback

### Before Pushing to Develop
```bash
git reset --hard origin/develop
git branch -D update-upstream-main-$(date +%Y%m%d)
```

### After Pushing to Develop
```bash
# Find the merge commit hash
git log --oneline -10

# Revert the merge (use -m 1 to keep develop's history)
git revert -m 1 <merge-commit-hash>
git push origin develop
```

## Useful Inspection Commands

### See What Changed in Upstream
```bash
# Last 20 commits
git log --oneline HEAD..upstream/main | head -20

# Full changelog
git log --oneline --no-merges HEAD..upstream/main

# Files changed
git diff --name-status HEAD..upstream/main

# Specific file changes
git diff HEAD..upstream/main -- path/to/file
```

### Check Apuntafy Customizations
```bash
# Files modified by Apuntafy (vs upstream)
git diff --name-only origin/main upstream/main

# Specific file diff
git diff origin/main upstream/main -- docker-compose.yml
```

### Conflict Analysis
```bash
# List files with conflicts
git diff --name-only --diff-filter=U

# See conflict markers in all files
git diff --check

# Count conflicts
git diff --name-only --diff-filter=U | wc -l
```

## Common Sed/Awk Patterns

### Replace All Network References
```bash
sed -i '' 's/stack/coolify/g' docker-compose.yml
```

### Update Network Config Block
```bash
sed -i '' '/networks:/,/external:/ {
    s/name: stack/name: coolify/
    s/external: false/external: true/
}' docker-compose.yml
```

### Extract Deleted Files from Git Status
```bash
git status | grep "deleted by them" | awk '{print $4}'
```

### Extract Modified Files from Git Status
```bash
git status | grep "both modified" | awk '{print $3}'
```

## Troubleshooting

### Problem: "fatal: refusing to merge unrelated histories"
```bash
git merge upstream/main --allow-unrelated-histories
```

### Problem: Lock file exists
```bash
rm -f .git/index.lock
```

### Problem: Submodule conflicts
```bash
git submodule update --init --recursive
```

### Problem: Too many files changed warning
```bash
git config diff.renameLimit 5000
```

## Environment-Specific Notes

### Coolify Network Requirements
- Network name: `coolify`
- External: `true`
- All services must be on `coolify` network
- No `stack` network references allowed

### Apuntafy-Specific Customizations
Files that typically have Apuntafy customizations:
- `docker-compose.yml` - Coolify network
- `apps/web/public/*.svg` - Branding (usually accept upstream)
- `.env.example` - May have custom variables
- `package.json` - May have custom dependencies

Always review these files carefully during merge.
