# Cal.com Upstream Sync Skill

Automated workflow for synchronizing upstream Cal.com changes into the Apuntafy fork with intelligent conflict resolution.

## 📁 Files in This Skill

- **SKILL.md** - Main skill documentation for GitHub Copilot
- **sync-upstream.sh** - Automated bash script for syncing
- **QUICK_REFERENCE.md** - Copy-paste commands and patterns
- **README.md** - This file

## 🚀 Quick Start

### For AI Agents (GitHub Copilot)

Simply ask in natural language:

```
"Sync upstream Cal.com changes"
"Update from upstream main"
"Traer cambios de cal.com"
```

The agent will automatically follow the workflow defined in `SKILL.md`.

### For Manual Use

#### Option 1: Automated Script

```bash
# Interactive mode (prompts for each step)
./.claude/skills/calcom-upstream-sync/sync-upstream.sh

# Automatic conflict resolution mode
./.claude/skills/calcom-upstream-sync/sync-upstream.sh --auto-resolve
```

#### Option 2: Copy-Paste Commands

See `QUICK_REFERENCE.md` for ready-to-use command sequences.

## 📋 What This Skill Does

1. ✅ Fetches only `upstream/main` (avoids downloading 800+ branches)
2. ✅ Creates a dated update branch
3. ✅ Merges upstream changes
4. ✅ Auto-resolves common conflicts:
   - Removes deprecated Devin workflows
   - Accepts upstream workflow updates
   - Accepts upstream SVG/logo updates
   - Patches `docker-compose.yml` for Coolify network
5. ✅ Merges to `develop` branch
6. ✅ Merges to `main` branch
7. ✅ Cleans up temporary branch

## 🎯 Key Features

### Intelligent Conflict Resolution

The skill knows how to handle:
- **Deleted files** - Automatically removes files Cal.com deprecated
- **Workflow updates** - Accepts upstream GitHub Actions changes
- **Asset updates** - Accepts upstream logo/SVG changes
- **Coolify network** - Preserves Apuntafy's deployment configuration
- **Test files** - Accepts upstream test improvements

### Safety Features

- ✅ Validates clean working directory before starting
- ✅ Confirms with user before merging
- ✅ Shows commit preview before proceeding
- ✅ Interactive prompts for push operations
- ✅ Provides rollback instructions

## 🔧 Configuration

### Prerequisites

Ensure the upstream remote is configured:

```bash
git remote add upstream https://github.com/calcom/cal.com.git
```

Verify:
```bash
git remote -v
# Should show:
# upstream  https://github.com/calcom/cal.com.git (fetch)
# upstream  https://github.com/calcom/cal.com.git (push)
```

### Apuntafy-Specific Customizations

The skill preserves these Apuntafy customizations:

| File | Customization | How It's Preserved |
|------|---------------|-------------------|
| `docker-compose.yml` | Coolify network | Auto-patched after merge |
| `.env.example` | Custom variables | Manual review prompted |
| `package.json` | Custom dependencies | Manual review prompted |

## 📖 Detailed Documentation

### SKILL.md

Complete skill documentation including:
- When to use this skill
- Step-by-step workflow
- Conflict resolution strategies
- Post-merge validation
- Troubleshooting guide
- Best practices

### QUICK_REFERENCE.md

Quick access to:
- One-line commands
- Complete workflow sequences
- Post-merge validation commands
- Emergency rollback procedures
- Useful inspection commands

### sync-upstream.sh

Automated bash script that:
- Validates prerequisites
- Fetches upstream changes
- Shows preview of commits
- Merges with conflict handling
- Offers auto-resolution mode
- Handles integration to develop/main
- Provides cleanup

## 🎓 Usage Examples

### Example 1: AI-Assisted Sync

```
User: "Update project from upstream Cal.com"

AI: [Executes skill workflow]
1. Validates working directory
2. Fetches upstream/main
3. Creates update-upstream-main-20260430
4. Merges and resolves conflicts
5. Merges to develop
6. Merges to main
7. Provides validation commands
```

### Example 2: Manual Automated Sync

```bash
$ ./.claude/skills/calcom-upstream-sync/sync-upstream.sh --auto-resolve

=== Cal.com Upstream Sync ===

Step 1: Checking working directory...
✓ Working directory is clean

Step 2: Verifying upstream remote...
✓ Upstream remote configured

Step 3: Fetching upstream/main...
✓ Fetched upstream/main

Commits that will be merged:
d278d6c9bc refactor: remove dead insights references
9cd1f34f16 cleanup(workspace-platform): remove entrypoints
...

Continue? (y/n) y

Step 4: Creating update branch: update-upstream-main-20260430
✓ Created branch update-upstream-main-20260430

Step 5: Merging upstream/main...
⚠ Conflicts detected. Resolving...
Auto-resolving conflicts...
✓ Conflicts auto-resolved and committed

Merge to develop branch? (y/n) y
...
```

### Example 3: Manual Step-by-Step

```bash
# Fetch
git fetch upstream main

# Create branch
git checkout -b update-upstream-main-20260430

# Merge
git merge upstream/main

# Resolve conflicts using quick reference
# (See QUICK_REFERENCE.md for commands)

# Continue with integration to develop and main
```

## 🐛 Troubleshooting

### Conflicts Still Exist After Auto-Resolve

```bash
# See which files have conflicts
git diff --name-only --diff-filter=U

# Review and manually resolve
# Then:
git add .
git commit --no-verify -m "chore: merge upstream/main (April 2026 update)"
```

### Script Fails with Permission Denied

```bash
chmod +x ./.claude/skills/calcom-upstream-sync/sync-upstream.sh
```

### Upstream Remote Not Found

```bash
git remote add upstream https://github.com/calcom/cal.com.git
```

### Merge Creates Too Many Conflicts

Consider breaking the sync into smaller chunks:
```bash
# Instead of merging all at once, merge specific commits
git cherry-pick <start-commit>..<end-commit>
```

## 📝 Post-Merge Checklist

After syncing, always:

- [ ] Run type check: `yarn type-check:ci --force`
- [ ] Regenerate Prisma types: `yarn prisma generate`
- [ ] Run database migrations if schema changed
- [ ] Test locally: `TZ=UTC yarn test`
- [ ] Build test: `yarn build`
- [ ] Deploy to staging first
- [ ] Verify Coolify deployment works

## 🔄 Update Frequency

**Recommended**: Sync monthly

- Monthly syncs are easier than quarterly
- Less conflicts to resolve
- Smaller diffs to review
- Easier to test changes

**Before syncing**: Check Cal.com's [release notes](https://github.com/calcom/cal.com/releases)

## 🆘 Emergency Rollback

If the merge causes production issues:

### Before Pushing
```bash
git reset --hard origin/develop
```

### After Pushing
```bash
git revert -m 1 <merge-commit-hash>
git push origin develop
```

## 🤝 Contributing

If you find patterns that should be auto-resolved:

1. Document the pattern in `SKILL.md`
2. Add the auto-resolve logic to `sync-upstream.sh`
3. Add the quick command to `QUICK_REFERENCE.md`

## 📄 License

This skill is specific to Apuntafy's Cal.com fork. Use and modify as needed for your own fork.

## 🔗 Related Resources

- [Cal.com GitHub](https://github.com/calcom/cal.com)
- [Apuntafy Fork](https://github.com/DavidKer1/apuntafy)
- [Cal.com Branch Protection Guidelines](../../.claude/rules/BRANCH_PROTECTION.md)
- [Git Workflow Guidelines](../../.claude/rules/ci-git-workflow.md)
