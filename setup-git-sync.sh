#!/bin/bash

# Setup git sync alias locally for this repository
# This mimics git-town sync behavior for git-flow workflows

echo "Setting up git sync alias locally..."

# Comprehensive sync alias (mimics git-town sync behavior)
git config --local alias.sync '!f() { \
    CURRENT=$(git branch --show-current); \
    echo "Syncing branch: $CURRENT"; \
    \
    if [ -z "$CURRENT" ]; then \
        echo "Error: Cannot sync in detached HEAD state"; \
        return 1; \
    fi; \
    \
    if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then \
        echo "Error: You are in the middle of a merge. Please complete or abort it first."; \
        return 1; \
    fi; \
    \
    if [ "$CURRENT" = "develop" ] || [ "$CURRENT" = "main" ]; then \
        echo "Syncing perennial branch $CURRENT..."; \
        git fetch --prune --tags && \
        git pull origin $CURRENT && \
        git push --tags; \
        return 0; \
    fi; \
    \
    if git submodule status 2>/dev/null | grep -q "^[+ ]"; then \
        SUBMODULE_CHANGES=$(git -C "$(git rev-parse --show-toplevel)" submodule foreach --quiet '\''git diff-index --quiet HEAD -- || echo $name'\''); \
        if [ -n "$SUBMODULE_CHANGES" ]; then \
            echo "Warning: Submodule has uncommitted changes. Continuing with main repo sync only."; \
        fi; \
    fi; \
    \
    HAS_CHANGES=false; \
    if ! git diff-index --quiet HEAD --; then \
        HAS_CHANGES=true; \
        echo "Stashing uncommitted changes..."; \
        git add -A && \
        git stash push -m "Git Town WIP" || { echo "Error: Failed to stash changes"; return 1; }; \
    fi; \
    \
    SYNC_FAILED=false; \
    git fetch --prune --tags || { SYNC_FAILED=true; }; \
    \
    if [ "$SYNC_FAILED" = false ] && git show-ref --verify --quiet refs/remotes/origin/$CURRENT; then \
        echo "Merging from origin/$CURRENT..."; \
        if ! git merge --no-edit origin/$CURRENT; then \
            SYNC_FAILED=true; \
            echo ""; \
            echo "Merge conflict detected. Please resolve conflicts and run:"; \
            echo "  git add <resolved-files>"; \
            echo "  git commit"; \
            echo "  git sync  # to continue"; \
        fi; \
    elif [ "$SYNC_FAILED" = false ]; then \
        echo "Branch not yet on remote, skipping origin/$CURRENT merge"; \
    fi; \
    \
    if [ "$SYNC_FAILED" = false ]; then \
        echo "Merging from origin/develop..."; \
        if ! git merge --no-edit origin/develop; then \
            SYNC_FAILED=true; \
            echo ""; \
            echo "Merge conflict detected. Please resolve conflicts and run:"; \
            echo "  git add <resolved-files>"; \
            echo "  git commit"; \
            echo "  git sync  # to continue"; \
        fi; \
    fi; \
    \
    if [ "$SYNC_FAILED" = false ]; then \
        echo "Pushing to origin..."; \
        git push -u origin $CURRENT || { \
            echo "Warning: Push failed. You may need to pull or force push."; \
            SYNC_FAILED=true; \
        }; \
    fi; \
    \
    if [ "$HAS_CHANGES" = true ]; then \
        if [ "$SYNC_FAILED" = false ]; then \
            echo "Restoring uncommitted changes..."; \
            if git stash pop; then \
                git restore --staged . 2>/dev/null || true; \
            else \
                echo "Warning: Could not restore stashed changes automatically."; \
                echo "Your changes are safe in the stash. Run '\''git stash list'\'' to see them."; \
            fi; \
        else \
            echo ""; \
            echo "Your uncommitted changes are safely stashed."; \
            echo "After resolving conflicts, run '\''git stash pop'\'' to restore them."; \
        fi; \
    fi; \
    \
    if [ "$SYNC_FAILED" = true ]; then \
        return 1; \
    fi; \
    \
    echo ""; \
    echo "✓ Sync completed successfully"; \
}; f'

echo "✓ Git sync alias installed with advanced features"
echo ""
echo "Usage: git sync"
echo ""
echo "Use 'git sync' to synchronize your current feature branch with its remote counterpart and the develop branch."
