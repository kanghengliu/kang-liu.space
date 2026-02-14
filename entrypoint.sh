#!/bin/bash
set -e

WATCH_PATHS="${WATCH_PATHS:-content/todos}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"
TRIGGER_FILE="${TRIGGER_FILE:-/tmp/rebuild}"

# Convert comma-separated paths to array
IFS=',' read -ra PATHS <<< "$WATCH_PATHS"

BUILD_DIR="/tmp/zola_build"

build() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Building site..."
    rm -rf "$BUILD_DIR"
    if zola build -o "$BUILD_DIR"; then
        # Sync to output (can't build directly to mounted volume)
        cp -a "$BUILD_DIR"/. "$OUTPUT_DIR"/
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Build complete -> $OUTPUT_DIR"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Build failed!"
    fi
}

# Initial build
build

# Create trigger file for manual builds
touch "$TRIGGER_FILE"

echo "Watching: ${WATCH_PATHS}"
echo "Output:   ${OUTPUT_DIR}"
echo "Manual trigger: touch $TRIGGER_FILE (or: docker exec <container> /trigger)"

# Build inotifywait args
WATCH_ARGS=()
for path in "${PATHS[@]}"; do
    path=$(echo "$path" | xargs)  # trim whitespace
    if [ -e "$path" ]; then
        WATCH_ARGS+=("-r" "$path")
    fi
done
WATCH_ARGS+=("$TRIGGER_FILE")

# Watch for changes
while true; do
    inotifywait -q -e modify,create,delete,move "${WATCH_ARGS[@]}"
    # Small delay to batch rapid changes
    sleep 0.5
    build
done
