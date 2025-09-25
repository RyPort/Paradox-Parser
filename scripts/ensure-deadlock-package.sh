#!/usr/bin/env bash
set -euo pipefail

progname=$(basename "$0")

usage() {
  cat <<EOF
Usage: $progname [--dry-run|-n] [--recursive|-r] [DIRECTORY]

Ensure every .proto file in DIRECTORY starts with the exact line:

  package deadlock;

If the file already starts with that line it is left unchanged. By default
DIRECTORY is ./deadlock. --dry-run will only print which files would be
modified.
EOF
}

dry_run=0
recursive=0
dir="../deadlock"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) dry_run=1; shift ;;
    -r|--recursive) recursive=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *) dir="$1"; shift ;;
  esac
done

if [[ ! -d "$dir" ]]; then
  echo "Directory not found: $dir" >&2
  exit 2
fi

header_line='package deadlock;'

process_file() {
  local file="$1"

  # Read first line (handle CRLF)
  if ! IFS= read -r firstline < "$file"; then
    # empty file
    firstline=""
  fi
  firstline=${firstline//$'\r'/}

  if [[ "$firstline" == "$header_line" ]]; then
    return 0
  fi

  if [[ $dry_run -eq 1 ]]; then
    echo "Would prepend header to: $file"
    return 0
  fi

  # Create temp file in same directory to avoid cross-device rename issues
  tmpfile=$(mktemp "${file}.XXXXXX")
  # Write header with a single newline after it, then append original content
  printf '%s\n' "$header_line" > "$tmpfile"
  # Append original file content
  cat -- "$file" >> "$tmpfile"
  # Preserve permissions
  if command -v chmod >/dev/null 2>&1; then
    chmod --reference="$file" "$tmpfile" || true
  fi
  mv -- "$tmpfile" "$file"
  echo "Prepended header to: $file"
}

export -f process_file

found=0
if [[ $recursive -eq 1 ]]; then
  # Use find -print0 to handle any filenames
  while IFS= read -r -d '' f; do
    found=1
    process_file "$f"
  done < <(find "$dir" -type f -name '*.proto' -print0)
else
  shopt -s nullglob
  for f in "$dir"/*.proto; do
    if [[ -f "$f" ]]; then
      found=1
      process_file "$f"
    fi
  done
  shopt -u nullglob
fi

if [[ $found -eq 0 ]]; then
  echo "No .proto files found in: $dir"
fi

exit 0
