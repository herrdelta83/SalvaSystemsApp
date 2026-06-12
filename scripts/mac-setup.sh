#!/bin/bash
# One-time setup on Mac.
# Run from the repo root:  bash scripts/mac-setup.sh

set -e

# ── Locate brew (Apple Silicon / Intel) ──────────────────────────────────────
if   [ -x "/opt/homebrew/bin/brew" ]; then export PATH="/opt/homebrew/bin:$PATH"
elif [ -x "/usr/local/bin/brew"    ]; then export PATH="/usr/local/bin:$PATH"
fi

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ── Install XcodeGen ──────────────────────────────────────────────────────────
install_xcodegen_binary() {
  local VERSION="2.42.0"
  local INSTALL_DIR="$HOME/.local/bin"
  echo "    Downloading XcodeGen $VERSION binary from GitHub..."
  mkdir -p "$INSTALL_DIR"
  curl -fsSL "https://github.com/yonaskolb/XcodeGen/releases/download/$VERSION/xcodegen.zip" \
    -o /tmp/xcodegen.zip
  unzip -oq /tmp/xcodegen.zip -d /tmp/xcodegen-install
  cp /tmp/xcodegen-install/xcodegen "$INSTALL_DIR/xcodegen"
  chmod +x "$INSTALL_DIR/xcodegen"
  export PATH="$INSTALL_DIR:$PATH"
  rm -rf /tmp/xcodegen.zip /tmp/xcodegen-install
  echo "    XcodeGen installed at $INSTALL_DIR/xcodegen"
}

echo "==> Checking XcodeGen..."
if command -v xcodegen &>/dev/null; then
  echo "    XcodeGen already available: $(xcodegen version)"
elif command -v brew &>/dev/null; then
  echo "    Installing via Homebrew..."
  brew install xcodegen
else
  echo "    Homebrew not found — downloading binary directly..."
  install_xcodegen_binary
fi

# ── Remove nested .git (orphan gitlink) ──────────────────────────────────────
echo "==> Removing nested .git from frontend/AccessFlow..."
if [ -d "frontend/AccessFlow/.git" ]; then
  rm -rf "frontend/AccessFlow/.git"
  echo "    Removed"
else
  echo "    Already clean"
fi

# ── Generate Xcode project ────────────────────────────────────────────────────
echo "==> Generating AccessFlow.xcodeproj from project.yml..."
(cd frontend/AccessFlow && xcodegen generate)
echo "    AccessFlow.xcodeproj generated with full Sources/ structure"

# ── Install post-merge hook ───────────────────────────────────────────────────
echo "==> Installing post-merge hook..."
cp .githooks/post-merge .git/hooks/post-merge
chmod +x .git/hooks/post-merge
echo "    Installed at .git/hooks/post-merge"

# ── Stage everything ──────────────────────────────────────────────────────────
echo "==> Staging AccessFlow files..."
git add frontend/AccessFlow/
git status --short

echo ""
echo "Done. Commit and push with:"
echo "  git commit -m 'add AccessFlow Xcode project files and Sources scaffold'"
echo "  git push"
echo ""
echo "From now on: git pull -> hook regenerates xcodeproj -> Xcode reloads."
