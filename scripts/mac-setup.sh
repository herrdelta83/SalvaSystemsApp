#!/bin/bash
# One-time setup on Mac.
# Run from anywhere inside the SalvaSystemsApp repo:
#   bash scripts/mac-setup.sh

set -e

# Locate brew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [ -x "/opt/homebrew/bin/brew" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [ -x "/usr/local/bin/brew" ]; then
  export PATH="/usr/local/bin:$PATH"
fi

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "==> Checking XcodeGen..."
if ! command -v xcodegen &>/dev/null; then
  if command -v brew &>/dev/null; then
    echo "    Installing XcodeGen via Homebrew..."
    brew install xcodegen
  else
    echo "ERROR: Homebrew not found. Install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "Then re-run this script."
    exit 1
  fi
fi
echo "    XcodeGen: $(xcodegen version)"

echo "==> Removing nested .git from frontend/AccessFlow (orphan gitlink)..."
if [ -d "frontend/AccessFlow/.git" ]; then
  rm -rf "frontend/AccessFlow/.git"
  echo "    Removed nested .git"
else
  echo "    No nested .git found (already clean)"
fi

echo "==> Generating AccessFlow.xcodeproj from project.yml..."
(cd frontend/AccessFlow && xcodegen generate)
echo "    AccessFlow.xcodeproj regenerated with full Sources/ structure"

echo "==> Installing post-merge hook..."
cp .githooks/post-merge .git/hooks/post-merge
chmod +x .git/hooks/post-merge
echo "    Hook installed at .git/hooks/post-merge"

echo "==> Staging all AccessFlow files..."
git add frontend/AccessFlow/
git status --short

echo ""
echo "==> All set. Commit and push with:"
echo "    git commit -m 'add AccessFlow Xcode project files and Sources scaffold'"
echo "    git push"
echo ""
echo "From now on: git pull -> hook auto-runs xcodegen -> Xcode reloads."
