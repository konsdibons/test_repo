#!/bin/bash

# Setup git sync alias locally for this repository
# This mimics git-town sync behavior for git-flow workflows

echo "Setting up git sync alias locally..."

# Option 1: Merge strategy (preserves history, creates merge commits)
git config --local alias.sync '!f() { \
    CURRENT=$(git branch --show-current); \
    echo "Syncing branch: $CURRENT"; \
    git fetch --prune --tags && \
    echo "Merging from origin/$CURRENT..." && \
    git merge origin/$CURRENT && \
    echo "Merging from origin/develop..." && \
    git merge origin/develop && \
    echo "Pushing to origin..." && \
    git push; \
}; f'

echo "✓ Git sync alias installed (merge strategy)"
echo ""
echo "Usage: git sync"
echo ""
echo "This will:"
echo "  1. Fetch from remote with pruning and tags"
echo "  2. Merge origin/<current-branch> into your branch"
echo "  3. Merge origin/develop into your branch"
echo "  4. Push your branch to origin"
