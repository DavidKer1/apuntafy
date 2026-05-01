#!/bin/bash
# Cal.com Upstream Sync Automation Script
# Usage: ./sync-upstream.sh [--auto-resolve]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
UPDATE_BRANCH="update-upstream-main-$(date +%Y%m%d)"
AUTO_RESOLVE=${1:-""}

echo -e "${GREEN}=== Cal.com Upstream Sync ===${NC}"

# Step 1: Verify clean working directory
echo -e "\n${YELLOW}Step 1: Checking working directory...${NC}"
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${RED}Error: Working directory is not clean. Commit or stash your changes first.${NC}"
    git status
    exit 1
fi
echo -e "${GREEN}✓ Working directory is clean${NC}"

# Step 2: Verify upstream remote exists
echo -e "\n${YELLOW}Step 2: Verifying upstream remote...${NC}"
if ! git remote get-url $UPSTREAM_REMOTE &> /dev/null; then
    echo -e "${RED}Error: Upstream remote not configured.${NC}"
    echo "Add it with: git remote add upstream https://github.com/calcom/cal.com.git"
    exit 1
fi
echo -e "${GREEN}✓ Upstream remote configured${NC}"

# Step 3: Fetch upstream (only main branch)
echo -e "\n${YELLOW}Step 3: Fetching upstream/main...${NC}"
git fetch $UPSTREAM_REMOTE $UPSTREAM_BRANCH
echo -e "${GREEN}✓ Fetched upstream/main${NC}"

# Step 4: Show what will be merged
echo -e "\n${YELLOW}Commits that will be merged:${NC}"
git log --oneline HEAD..upstream/main | head -20
echo -e "\n${YELLOW}Continue? (y/n)${NC}"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Sync cancelled."
    exit 0
fi

# Step 5: Create update branch
echo -e "\n${YELLOW}Step 4: Creating update branch: $UPDATE_BRANCH${NC}"
git checkout -b $UPDATE_BRANCH
echo -e "${GREEN}✓ Created branch $UPDATE_BRANCH${NC}"

# Step 6: Merge upstream
echo -e "\n${YELLOW}Step 5: Merging upstream/main...${NC}"
if git merge upstream/main --no-edit; then
    echo -e "${GREEN}✓ Merge completed successfully with no conflicts!${NC}"
else
    echo -e "${YELLOW}⚠ Conflicts detected. Resolving...${NC}"

    if [[ "$AUTO_RESOLVE" == "--auto-resolve" ]]; then
        # Auto-resolve conflicts
        echo -e "${YELLOW}Auto-resolving conflicts...${NC}"

        # Remove deleted files (common deletions from upstream)
        DELETED_FILES=(
            ".github/workflows/cubic-devin-review.yml"
            ".github/workflows/delete-blacksmith-cache.yml"
            ".github/workflows/devin-conflict-resolver.yml"
            ".github/workflows/stale-pr-devin-completion.yml"
        )

        for file in "${DELETED_FILES[@]}"; do
            if git ls-files -u | grep -q "$file"; then
                echo "Removing $file"
                git rm "$file" 2>/dev/null || true
            fi
        done

        # Accept upstream for workflows
        git checkout --theirs .github/workflows/*.yml 2>/dev/null || true

        # Accept upstream for SVG assets
        git checkout --theirs apps/web/public/*.svg 2>/dev/null || true

        # Handle docker-compose.yml specially
        if git ls-files -u | grep -q "docker-compose.yml"; then
            echo -e "${YELLOW}Handling docker-compose.yml with Coolify network...${NC}"
            git checkout --theirs docker-compose.yml
            sed -i '' 's/stack/coolify/g' docker-compose.yml

            # Fix network configuration
            sed -i '' '/networks:/,/external:/ {
                s/name: coolify//
                s/external: false/external: true/
            }' docker-compose.yml

            git add docker-compose.yml
        fi

        # Stage remaining resolved files
        git add .

        # Check if conflicts remain
        if git diff --name-only --diff-filter=U | grep -q .; then
            echo -e "${RED}Some conflicts could not be auto-resolved:${NC}"
            git diff --name-only --diff-filter=U
            echo -e "\n${YELLOW}Please resolve these manually, then run:${NC}"
            echo "git add ."
            echo "git commit --no-verify -m 'chore: merge upstream/main ($(date +%B\ %Y) update)'"
            exit 1
        fi

        # Commit the merge
        git commit --no-verify -m "chore: merge upstream/main ($(date +%B\ %Y) update)"
        echo -e "${GREEN}✓ Conflicts auto-resolved and committed${NC}"
    else
        echo -e "${YELLOW}Please resolve conflicts manually, then run:${NC}"
        echo "  git add ."
        echo "  git commit --no-verify -m 'chore: merge upstream/main ($(date +%B\ %Y) update)'"
        echo ""
        echo -e "${YELLOW}Or re-run this script with --auto-resolve to attempt automatic resolution${NC}"
        exit 1
    fi
fi

# Step 7: Offer to merge to develop
echo -e "\n${YELLOW}Merge to develop branch? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Switching to develop...${NC}"
    git checkout develop

    echo -e "${YELLOW}Pulling latest develop...${NC}"
    git pull origin develop

    echo -e "${YELLOW}Merging update branch...${NC}"
    git merge $UPDATE_BRANCH --no-edit

    echo -e "${GREEN}✓ Merged to develop${NC}"
    echo -e "\n${YELLOW}Push to origin/develop? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git push origin develop
        echo -e "${GREEN}✓ Pushed to origin/develop${NC}"
    fi

    # Offer to merge to main
    echo -e "\n${YELLOW}Merge to main branch? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git checkout main
        git merge develop --no-edit
        echo -e "${GREEN}✓ Merged to main${NC}"

        echo -e "\n${YELLOW}Push to origin/main? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git push origin main
            echo -e "${GREEN}✓ Pushed to origin/main${NC}"
        fi
    fi

    # Cleanup
    echo -e "\n${YELLOW}Delete update branch? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git branch -d $UPDATE_BRANCH
        echo -e "${GREEN}✓ Deleted update branch${NC}"
    fi
fi

echo -e "\n${GREEN}=== Sync Complete ===${NC}"
echo -e "${YELLOW}Don't forget to:${NC}"
echo "  1. Run: yarn type-check:ci --force"
echo "  2. Run: yarn prisma generate (if schema changed)"
echo "  3. Test locally before deploying"
