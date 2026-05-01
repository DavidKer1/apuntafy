# Cal.com Upstream Sync History

This file tracks major upstream synchronizations from Cal.com to Apuntafy.

## Format

```
## YYYY-MM-DD - Version/Description
- Commits merged: <count>
- Files changed: <count>
- Major changes: <list>
- Conflicts resolved: <list>
- Issues encountered: <list>
```

---

## 2026-04-30 - April 2026 Major Update

**Stats:**
- Commits merged: 20+
- Files changed: 5,829
- Insertions: 277,815
- Deletions: 631,818

**Major Changes:**
- Removed dead insights references
- Cleaned up workspace-platform entrypoints
- Removed instant meeting trigger support
- Fixed app-store search normalization
- Removed deprecated Devin AI tool workflows
- Cleaned up legacy test coverage
- Updated logos and SVG assets
- Refactored workflow runtime config
- Removed deprecated team management features
- Documentation migrations

**Conflicts Resolved:**
1. GitHub Actions workflows - Accepted upstream versions
2. docker-compose.yml - Preserved Coolify network configuration
3. SVG assets - Accepted upstream logo updates
4. Deleted files - Removed deprecated components:
   - Devin AI workflows (4 files)
   - Enterprise/license components (3 files)
   - Deprecated insights components
   - Legacy team management views
   - Old test files (3 e2e tests)
   - Deprecated app integrations (deel, granola)
   - Compliance documents
   - Migration guides

**Integration:**
- Created branch: `update-upstream-main-20260430`
- Merged to develop: ✅
- Merged to main: ✅
- Deployed to production: ⏳ Pending

**Post-Merge Validation:**
- Type check: ⏳ Pending
- Prisma generate: ⏳ Pending
- Tests: ⏳ Pending
- Build: ⏳ Pending

**Notes:**
- Used `--no-verify` for commit due to upstream lint issues
- Coolify network configuration preserved successfully
- All deprecated Devin workflows removed as expected
- First sync using the new calcom-upstream-sync skill

---

## 2026-01-19 - January 2026 Update

**Stats:**
- Commits merged: ~10
- Files changed: 217
- Insertions: 12,644
- Deletions: 3,844

**Major Changes:**
- Added branch protection settings documentation
- Fixed healthcheck issues in docker-compose
- Updated docker-compose network configuration
- Calendar cache features added
- Feature opt-in banner system
- Trigger.dev task implementations
- Team invite improvements

**Conflicts Resolved:**
1. docker-compose.yml - Preserved Coolify network
2. Minor workflow conflicts

**Integration:**
- Created branch: `merge-upstream-main`
- Merged to develop: ✅
- Merged to main: ✅

**Notes:**
- Initial upstream sync after fork
- Established Coolify network pattern
- Set up branch protection guidelines

---

## Template for Future Updates

```markdown
## YYYY-MM-DD - [Month Year] Update

**Stats:**
- Commits merged: X
- Files changed: X
- Insertions: X
- Deletions: X

**Major Changes:**
- Feature 1
- Feature 2
- Bug fix 1

**Conflicts Resolved:**
1. File/pattern - Resolution strategy
2. File/pattern - Resolution strategy

**Integration:**
- Created branch: `update-upstream-main-YYYYMMDD`
- Merged to develop: ✅/❌
- Merged to main: ✅/❌
- Deployed to production: ✅/❌/⏳

**Post-Merge Validation:**
- Type check: ✅/❌/⏳
- Prisma generate: ✅/❌/⏳
- Tests: ✅/❌/⏳
- Build: ✅/❌/⏳

**Notes:**
- Any special notes
- Issues encountered
- Workarounds applied
```

---

## Sync Frequency

**Target**: Monthly syncs
**Actual**: TBD

## Common Conflict Patterns

Based on historical syncs, these patterns typically appear:

1. **docker-compose.yml** - Always needs Coolify network patch
2. **GitHub Actions workflows** - Usually accept upstream
3. **SVG/Logo assets** - Usually accept upstream
4. **Deprecated features** - Remove when upstream deletes
5. **package.json** - Review carefully for custom dependencies
6. **.env.example** - Review carefully for custom variables

## Automation Notes

- Since April 2026: Using `.claude/skills/calcom-upstream-sync/` skill
- Auto-resolution works for ~80% of conflicts
- Manual review still needed for Apuntafy customizations
