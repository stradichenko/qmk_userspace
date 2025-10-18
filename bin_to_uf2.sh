#!/bin/bash

# Convert QMK .bin file to .uf2 for RP2040
# Usage: ./bin_to_uf2.sh input.bin output.uf2

if [ $# -ne 2 ]; then
    echo "Usage: $0 input.bin output.uf2"
    echo "Example: $0 bastardkb_charybdis_3x6_blackpill_my-keyboard.bin charybdis_rp2040.uf2"
    exit 1
fi

INPUT_BIN="$1"
OUTPUT_UF2="$2"

if [ ! -f "$INPUT_BIN" ]; then
    echo "Error: Input file '$INPUT_BIN' not found"
    exit 1
fi

echo "Converting $INPUT_BIN to $OUTPUT_UF2..."

# Check if uf2conv.py exists
if command -v uf2conv.py &> /dev/null; then
    UF2CONV="uf2conv.py"
elif [ -f "/usr/local/bin/uf2conv.py" ]; then
    UF2CONV="/usr/local/bin/uf2conv.py"
elif [ -f "./uf2conv.py" ]; then
    UF2CONV="./uf2conv.py"
else
    echo "Error: uf2conv.py not found. Please install it or place it in the current directory."
    echo "You can download it from: https://github.com/microsoft/uf2/blob/master/utils/uf2conv.py"
    exit 1
fi

# Convert bin to uf2 with RP2040 family ID
python3 "$UF2CONV" -b 0x10000000 -f 0xe48bff56 "$INPUT_BIN" -o "$OUTPUT_UF2"

if [ $? -eq 0 ]; then
    echo "✓ Successfully converted to $OUTPUT_UF2"
    echo "You can now drag and drop this .uf2 file to your RP2040 in bootloader mode"
else
    echo "✗ Conversion failed"
    exit 1
fi