#!/bin/sh
# Verify cloned beaver-iot-web is from our repo and has widget fixes (CI).
# Run from workspace root after ci-clone-web. Fail if wrong repo or fixes missing.

set -e
WEB_DIR="${1:-beaver-iot-web}"
COMPONENTS="apps/web/src/components/drawing-board/plugin/plugins/components.ts"
FILTER="apps/web/src/components/drawing-board/hooks/useFilterPlugins.tsx"

if [ ! -d "$WEB_DIR" ]; then
  echo "ERROR: $WEB_DIR not found (run ci-clone-web first)"
  exit 1
fi

# Must use our fork (rifatsekerariot)
origin=$(cd "$WEB_DIR" && git remote get-url origin 2>/dev/null || true)
if ! echo "$origin" | grep -q "rifatsekerariot/beaver-iot-web"; then
  echo "ERROR: Web clone is not our repo. origin=$origin"
  exit 1
fi

# components.ts: import.meta.glob('./*/control-panel/index.ts')
if ! grep -q "control-panel/index.ts" "$WEB_DIR/$COMPONENTS" 2>/dev/null || ! grep -q "import.meta.glob" "$WEB_DIR/$COMPONENTS" 2>/dev/null; then
  echo "ERROR: components.ts missing widget glob (expected control-panel glob)"
  exit 1
fi

# useFilterPlugins: return pluginsControlPanel (no filter)
if ! grep -q "return pluginsControlPanel" "$WEB_DIR/$FILTER" 2>/dev/null; then
  echo "ERROR: useFilterPlugins missing 'return pluginsControlPanel' (widget filter fix)"
  exit 1
fi

echo "OK: Web source is our repo, components.ts + useFilterPlugins widget fixes present"
