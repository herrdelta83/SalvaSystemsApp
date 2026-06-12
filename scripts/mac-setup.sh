#!/bin/bash
# One-time setup on Mac. Run from repo root: bash scripts/mac-setup.sh
set -e

for p in "/opt/homebrew/bin" "/usr/local/bin"; do
  [ -x "$p/brew" ] && export PATH="$p:$PATH" && break
done

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$REPO_ROOT"

install_xcodegen_binary() {
  local VERSION="2.42.0"
  local INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  echo "    Downloading XcodeGen $VERSION..."
  curl -fsSL "https://github.com/yonaskolb/XcodeGen/releases/download/$VERSION/xcodegen.zip" \
    -o /tmp/xcodegen.zip
  rm -rf /tmp/xcodegen-install
  unzip -oq /tmp/xcodegen.zip -d /tmp/xcodegen-install
  XCODEGEN_BIN=$(find /tmp/xcodegen-install -name "xcodegen" -type f | head -1)
  if [ -z "$XCODEGEN_BIN" ]; then
    echo "ERROR: could not find xcodegen binary inside zip"; exit 1
  fi
  cp "$XCODEGEN_BIN" "$INSTALL_DIR/xcodegen"
  chmod +x "$INSTALL_DIR/xcodegen"
  export PATH="$INSTALL_DIR:$PATH"
  rm -rf /tmp/xcodegen.zip /tmp/xcodegen-install
  echo "    XcodeGen installed -> $INSTALL_DIR/xcodegen"
}

echo "==> Checking XcodeGen..."
export PATH="$HOME/.local/bin:$PATH"
if command -v xcodegen &>/dev/null; then
  echo "    XcodeGen: $(xcodegen version)"
elif command -v brew &>/dev/null; then
  echo "    Installing via Homebrew..."
  brew install xcodegen
else
  echo "    No Homebrew — downloading binary..."
  install_xcodegen_binary
fi

echo "==> Generating AccessFlow.xcodeproj from project.yml..."
(cd frontend/SalvaSystems && xcodegen generate)
echo "    Done — open with: open frontend/SalvaSystems/AccessFlow.xcodeproj"

echo "==> Installing post-merge hook..."
cp .githooks/post-merge .git/hooks/post-merge
chmod +x .git/hooks/post-merge
