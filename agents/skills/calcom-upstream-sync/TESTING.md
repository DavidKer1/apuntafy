# Testing the Cal.com Upstream Sync Skill

This guide helps verify that the skill is working correctly.

## 1. Verify Skill Installation

### Check Skill Files

```bash
ls -la .claude/skills/calcom-upstream-sync/

# Should show:
# - SKILL.md (main skill documentation)
# - README.md (usage guide)
# - QUICK_REFERENCE.md (command reference)
# - sync-upstream.sh (automation script)
# - SYNC_HISTORY.md (changelog)
# - TESTING.md (this file)
```

### Verify Script Permissions

```bash
ls -la .claude/skills/calcom-upstream-sync/sync-upstream.sh

# Should show:
# -rwxr-xr-x ... sync-upstream.sh
#  ^^^ - executable permissions
```

If not executable:
```bash
chmod +x .claude/skills/calcom-upstream-sync/sync-upstream.sh
```

## 2. Test AI Agent Discovery

### Test with GitHub Copilot Chat

Ask the agent:
```
"Sync upstream Cal.com changes"
```

The agent should:
1. Recognize the request matches the skill
2. Load the SKILL.md documentation
3. Follow the workflow defined in the skill
4. Execute the sync process

### Alternative Trigger Phrases

Test these phrases to verify trigger detection:

English:
- "Update from upstream Cal.com"
- "Merge upstream/main"
- "Pull latest Cal.com changes"
- "Sync with cal.com main"

Spanish:
- "Actualizar desde upstream"
- "Traer cambios de cal.com"
- "Sincronizar con upstream"

## 3. Test Manual Script Execution

### Dry Run Test (Safe - No Changes)

```bash
# This will stop before making any changes
./.claude/skills/calcom-upstream-sync/sync-upstream.sh

# When prompted "Continue? (y/n)", type 'n'
```

Expected output:
```
=== Cal.com Upstream Sync ===

Step 1: Checking working directory...
✓ Working directory is clean

Step 2: Verifying upstream remote...
✓ Upstream remote configured

Step 3: Fetching upstream/main...
✓ Fetched upstream/main

Commits that will be merged:
[... commit list ...]

Continue? (y/n) n

Sync cancelled.
```

### Test Auto-Resolve Flag

```bash
# This tests the auto-resolution logic (stops at first prompt)
./.claude/skills/calcom-upstream-sync/sync-upstream.sh --auto-resolve

# Type 'n' when asked to continue
```

## 4. Test Individual Commands

### Test Upstream Fetch

```bash
# Safe - only downloads data, doesn't change your branches
git fetch upstream main

# Verify it worked
git log --oneline HEAD..upstream/main | head -5
```

Expected: Shows commits from Cal.com that aren't in your current branch

### Test Branch Creation

```bash
# Create a test branch
git checkout -b test-skill-$(date +%Y%m%d)

# Verify you're on the new branch
git branch --show-current

# Clean up
git checkout develop
git branch -d test-skill-$(date +%Y%m%d)
```

### Test Conflict Pattern Detection

```bash
# Check if common conflict files exist
ls -la .github/workflows/cache-clean.yml
ls -la docker-compose.yml
ls -la apps/web/public/cal-logo-word.svg

# These files often have conflicts during sync
```

## 5. Test Conflict Resolution Patterns

### Test Docker Compose Network Replacement

Create a test file:
```bash
# Create test file
cat > /tmp/test-docker-compose.yml << 'EOF'
networks:
  stack:
    name: stack
    external: false
services:
  app:
    networks:
      - stack
EOF

# Test sed replacement
sed 's/stack/coolify/g' /tmp/test-docker-compose.yml

# Expected output should show 'coolify' instead of 'stack'
```

### Test Git Status Parsing

```bash
# Test the awk command for extracting deleted files
# (This is safe - just testing the command syntax)
echo "deleted by them:   test-file.txt" | awk '{print $4}'

# Expected output: test-file.txt
```

## 6. Validate YAML Frontmatter

The SKILL.md file should have valid YAML frontmatter:

```bash
head -15 .claude/skills/calcom-upstream-sync/SKILL.md

# Should start with:
# ---
# name: calcom-upstream-sync
# description: ...
# triggers:
#   - "sync upstream"
#   ...
# ---
```

## 7. Test Emergency Rollback

### Safe Rollback Test

```bash
# Save current state
CURRENT_BRANCH=$(git branch --show-current)
CURRENT_COMMIT=$(git rev-parse HEAD)

# Create test branch
git checkout -b test-rollback

# Make a test commit
echo "test" > /tmp/test.txt
git add /tmp/test.txt
git commit -m "test: rollback test"

# Test rollback
git reset --hard $CURRENT_COMMIT

# Verify we're back
git log --oneline -1

# Cleanup
git checkout $CURRENT_BRANCH
git branch -D test-rollback
rm /tmp/test.txt
```

## 8. Integration Test Checklist

Before running a real sync, verify:

- [ ] Working directory is clean: `git status`
- [ ] On correct branch: `git branch --show-current`
- [ ] Upstream remote exists: `git remote -v | grep upstream`
- [ ] Internet connection works: `ping github.com`
- [ ] Have permissions to push: `git remote -v | grep origin`
- [ ] Backup recent work: Check you've pushed recent changes

## 9. Post-Sync Validation Tests

After a real sync, run these:

### Type Check
```bash
yarn type-check:ci --force

# Expected: Should pass or show errors (that you can fix)
```

### Prisma Generation
```bash
yarn prisma generate

# Expected: Successfully generates types
```

### Basic Build Test
```bash
# This can take a while
yarn build

# Or just test web app
cd apps/web && yarn build
```

### Test Suite
```bash
# Run fast unit tests
TZ=UTC yarn test --run

# Expected: Most tests should pass
# Some failures are acceptable if they're in upstream code
```

## 10. Smoke Test Checklist

After sync and deploy to staging:

- [ ] Homepage loads
- [ ] Can log in
- [ ] Can create a booking
- [ ] Can view calendar
- [ ] Settings page works
- [ ] No console errors
- [ ] No network errors in DevTools

## 11. Monitoring After Production Deploy

Watch for:

- [ ] Error rate increase in monitoring
- [ ] Performance degradation
- [ ] User reports of issues
- [ ] Broken integrations (calendars, payments, etc.)

## Common Test Failures and Fixes

### "fatal: not a git repository"

```bash
# You're not in the project directory
cd /path/to/apuntafy
```

### "upstream does not appear to be a git repository"

```bash
# Add upstream remote
git remote add upstream https://github.com/calcom/cal.com.git
```

### "Permission denied" on script

```bash
chmod +x ./.claude/skills/calcom-upstream-sync/sync-upstream.sh
```

### "You have unstaged changes"

```bash
# Stash or commit your changes first
git stash
# or
git add . && git commit -m "wip: save work before sync"
```

## Success Criteria

The skill is working correctly if:

✅ AI agent recognizes sync commands
✅ Script runs without errors
✅ Conflicts are auto-resolved correctly
✅ Coolify network configuration is preserved
✅ Upstream changes are successfully merged
✅ Type checks pass (or show fixable errors)
✅ Project builds successfully
✅ Tests mostly pass

## Troubleshooting Guide

If tests fail, check:

1. **Git configuration**: `git config --list`
2. **Remote URLs**: `git remote -v`
3. **Branch state**: `git status` and `git branch -v`
4. **Node version**: `node --version` (should be 18+)
5. **Yarn version**: `yarn --version`
6. **Dependencies**: `yarn install`

## Reporting Issues

If you find bugs in the skill:

1. Document the exact command used
2. Capture the error output
3. Note the current branch and commit: `git branch --show-current && git rev-parse HEAD`
4. Check SYNC_HISTORY.md for similar issues
5. Update SKILL.md with the fix

## Next Steps After Testing

Once testing is complete:

1. Update SYNC_HISTORY.md with test results
2. Document any issues found
3. Add new auto-resolution patterns if discovered
4. Share learnings with the team
5. Schedule next sync (recommend monthly)

---

**Last tested**: [Date]
**Tested by**: [Name]
**Result**: ✅ Pass / ❌ Fail
**Notes**: [Any observations]
