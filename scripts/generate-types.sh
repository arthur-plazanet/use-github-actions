#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TYPES_DIR="$ROOT_DIR/types"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

for file in "$TYPES_DIR"/*.json; do
  [ -f "$file" ] || continue

  name=$(basename "$file" .json)
  # Capitalize first letter for interface name
  interface=$(echo "$name" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

  output="$DIST_DIR/$name.ts"

  echo "export interface $interface {" > "$output"
  jq -r 'to_entries | .[] | "  \(.key): \(.value)"' "$file" >> "$output"
  echo "}" >> "$output"

  echo "Generated: $output"
done

echo "Done! Types generated in $DIST_DIR"
