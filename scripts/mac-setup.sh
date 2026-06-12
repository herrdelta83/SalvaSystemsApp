#!/bin/bash
# One-time setup on Mac.
# Run from anywhere inside the SalvaSystemsApp repo:
#   bash scripts/mac-setup.sh

set -e

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "==> Checking XcodeGen..."
if ! command -v xcodegen &>/dev/null; then
  echo "    Installing XcodeGen via Homebrew..."
  brew install xcodegen
fi
echo "    XcodeGen OK"

echo "==> Removing nested .git from frontend/AccessFlow (orphan gitlink)..."
if [ -d "frontend/AccessFlow/.git" ]; then
  rm -rf "frontend/AccessFlow/.git"
  echo "    Removed nested .git"
else
  echo "    No nested .git found (already clean)"
fi

echo "==> Removing stale gitlink from index..."
git rm --cached frontend/AccessFlow 2>/dev/null && echo "    Gitlink removed" || echo "    No gitlink in index"

echo "==> Generating AccessFlow.xcodeproj from project.yml..."
(cd frontend/AccessFlow && xcodegen generate)
echo "    AccessFlow.xcodeproj generated"

echo "==> Installing post-merge hook..."
cp .githooks/post-merge .git/hooks/post-merge
chmod +x .git/hooks/post-merge
echo "    Hook installed at .git/hooks/post-merge"

echo "==> Staging all AccessFlow files..."
git add frontend/AccessFlow/
git status --short

echo ""
echo "==> Ready to commit. Review staged files above, then run:"
echo "    git commit -m 'migrate AccessFlow to main repo with XcodeGen'"
echo "    git push"
echo ""
echo "From now on: git pull -> hook regenerates AccessFlow.xcodeproj -> Xcode reloads."
