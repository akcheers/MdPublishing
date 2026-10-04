#!/bin/bash

# Usage: ./generate_nav.sh <directory_path> [site_name]

TARGET_DIR="${1:-.}"
SITE_NAME="${2:-MD Notes}"
OUTPUT_FILE="index.yaml"

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Write header to index.yaml
cat <<EOF > "$OUTPUT_FILE"
site_name: $SITE_NAME

nav:
EOF

# Find all .md files, remove leading './', sort, and construct YAML tree
find "$TARGET_DIR" -type f -name "*.md" | sed 's|^\./||' | sort | while IFS= read -r file; do
  IFS='/' read -ra PARTS <<< "$file"
  NUM_PARTS=${#PARTS[@]}
  
  # Indent base level under 'nav:'
  INDENT="  "
  
  for (( i=0; i<$NUM_PARTS; i++ )); do
    ITEM="${PARTS[$i]}"
    
    if [ $i -eq $((NUM_PARTS - 1)) ]; then
      # File level (e.g., Salary: path/to/Salary.md)
      KEY="${ITEM%.md}"
      echo "${INDENT}${KEY}: ${file}" >> "$OUTPUT_FILE"
    else
      # Directory level
      # Only output the directory header if it hasn't been printed at this depth yet
      INDENT_STR="${INDENT}${ITEM}:"
      if ! grep -q "^${INDENT_STR}$" "$OUTPUT_FILE"; then
        echo "${INDENT_STR}" >> "$OUTPUT_FILE"
      fi
      INDENT="${INDENT}  "
    fi
  done
done

echo "Generated $OUTPUT_FILE successfully."