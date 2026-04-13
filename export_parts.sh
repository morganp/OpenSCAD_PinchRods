#!/usr/bin/env bash
# Export all printable pinch rod components as 3mf files.
# Usage: ./export_parts.sh [output_dir]
# Output directory defaults to ./export/

set -euo pipefail

SCAD="$(dirname "$0")/pinch_rods.scad"
OUT="${1:-$(dirname "$0")/export}"

mkdir -p "$OUT"

parts=(guide1 guide2 fastener rod)

for part in "${parts[@]}"; do
    out_file="$OUT/pinch_rods_${part}.3mf"
    echo "Exporting ${part} -> ${out_file}"
    openscad \
        -D 'MODE="print"' \
        -D "PRINT_PART=\"${part}\"" \
        --render \
        -o "${out_file}" \
        "${SCAD}"
done

echo "Done. Files in ${OUT}/"
