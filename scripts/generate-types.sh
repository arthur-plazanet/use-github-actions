#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TYPES_DIR="$ROOT_DIR/types"
DIST_DIR="$ROOT_DIR/dist"

mkdir -p "$DIST_DIR"

# Collect all interface names for cross-referencing
declare -A INTERFACES
for file in "$TYPES_DIR"/*.json; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .json)
  INTERFACES["$name"]=1
done

# Generate each type file
for file in "$TYPES_DIR"/*.json; do
  [ -f "$file" ] || continue

  # Use filename as interface name (already PascalCase)
  name=$(basename "$file" .json)
  output="$DIST_DIR/$name.ts"

  # Collect imports: check if any field references another interface
  imports=""
  while IFS= read -r value; do
    base_type="${value%\[\]}"
    if [[ -n "${INTERFACES[$base_type]}" && "$base_type" != "$name" ]]; then
      imports+="import type { $base_type } from './$base_type.js'"$'\n'
    fi
  done < <(jq -r '.[]' "$file")

  {
    if [[ -n "$imports" ]]; then
      echo "$imports"
    fi
    echo "export interface $name {"
    jq -r 'to_entries | .[] | "  \(.key): \(.value)"' "$file"
    echo "}"
  } > "$output"

  echo "Generated: $output"
done

# Generate index.ts barrel export
{
  for file in "$TYPES_DIR"/*.json; do
    [ -f "$file" ] || continue
    name=$(basename "$file" .json)
    echo "export type { $name } from './$name.js'"
  done
} > "$DIST_DIR/index.ts"

echo "Generated: $DIST_DIR/index.ts"
echo "Done! Types generated in $DIST_DIR"
