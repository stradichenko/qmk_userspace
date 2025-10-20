# BastardKB Charybdis 3x6 QMK Setup Instructions

## Overview
This document contains the complete setup process for compiling QMK firmware for BastardKB Charybdis keyboards using the proper BastardKB QMK fork and userspace configuration.

## Problem Summary
The standard QMK setup doesn't work with BastardKB keyboards. You must use:
1. **BastardKB QMK fork** (not standard QMK firmware)
2. **Proper userspace configuration**
3. **Correct keyboard identifiers**

## Prerequisites

- Working QMK environment (see [QMK Docs](https://docs.qmk.fm/#/newbs))
- Git installed
- ARM GCC toolchain
- Existing QMK userspace repository with your keymap

## Step-by-Step Setup

### 1. Clone and Setup BastardKB QMK Fork

```bash
# Navigate to your projects directory
cd /home/gespitia/projects

# Clone the BastardKB QMK fork
git clone https://github.com/bastardkb/bastardkb-qmk

# Switch to the BastardKB directory and checkout the correct branch
cd bastardkb-qmk
git checkout -b bkb-master origin/bkb-master

# Initialize QMK submodules
qmk git-submodule

# Set this as your default QMK installation
qmk config user.qmk_home="$(realpath .)"
```

### 2. Configure QMK Userspace

```bash
# Navigate to your userspace directory
cd /home/gespitia/projects/qmk_userspace

# Set the userspace overlay directory
qmk config user.overlay_dir="$(realpath .)"
```

### 3. Fix qmk.json Configuration

Your `qmk.json` file should look like this:

```json
{
    "userspace_version": "1.0",
    "build_targets": [
        ["bastardkb/charybdis/3x6", "my-keyboard"]
    ]
}
```

**Important Notes:**
- Use version `"1.0"` (not `"1.1"`)
- Use keyboard identifier `bastardkb/charybdis/3x6` (not `bastardkb/charybdis/3x6/blackpill`)

### 4. Verify Configuration

```bash
# Run userspace doctor to check configuration
qmk userspace-doctor

# Check QMK configuration (should show correct paths)
qmk config

# Verify QMK home and overlay directories are set correctly
# Expected output:
# user.overlay_dir=/home/gespitia/projects/qmk_userspace
# user.qmk_home=/home/gespitia/projects/bastardkb-qmk

# List available keymaps (should show your keymap)
qmk list-keymaps -kb bastardkb/charybdis/3x6

# Test compile with default keymap first to verify setup
qmk compile -c -kb bastardkb/charybdis/3x6 -km default
```

### 5. Compile Firmware

#### Method 1: Using Userspace Overlay (Recommended)
```bash
# Navigate to BastardKB QMK directory
cd /home/gespitia/projects/bastardkb-qmk

# Compile your keymap (userspace overlay automatically includes your keymap)
qmk compile -c -kb bastardkb/charybdis/3x6 -km my-keyboard
```

#### Method 2: Symlink Keymap (Better Alternative)
If userspace overlay isn't working, you can symlink the keymap directory:

```bash
# Create symlink from BastardKB QMK to your userspace keymap
ln -s /home/gespitia/projects/qmk_userspace/keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard /home/gespitia/projects/bastardkb-qmk/keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard

# Navigate to BastardKB QMK directory and compile
cd /home/gespitia/projects/bastardkb-qmk
qmk compile -c -kb bastardkb/charybdis/3x6 -km my-keyboard
```

**Advantages of symlinking:**
- Single source of truth - no duplicate files
- Automatic updates - changes in userspace immediately available
- No manual copying needed after initial setup

#### Method 3: Direct Copy (Last Resort)
Only if symlink doesn't work on your system:

```bash
# Copy your keymap to the BastardKB QMK fork
cp -r /home/gespitia/projects/qmk_userspace/keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard /home/gespitia/projects/bastardkb-qmk/keyboards/bastardkb/charybdis/3x6/keymaps/

# Navigate to BastardKB QMK directory and compile
cd /home/gespitia/projects/bastardkb-qmk
qmk compile -c -kb bastardkb/charybdis/3x6 -km my-keyboard
```

**Note:** Method 2 (symlink) is preferred over copying as it maintains a single source of truth.

**Expected Output:**
- Compilation should complete successfully
- UF2 file generated: `bastardkb_charybdis_3x6_my-keyboard.uf2`
- File will be copied to both QMK directory and userspace directory

### 6. Flashing the Keyboard

#### For RP2040-based keyboards (like your custom Charybdis):

1. **Enter bootloader mode:**
   - Double-tap reset button, OR
   - Hold bootloader key combo while plugging USB, OR
   - Use `QK_BOOT` keycode from your keymap (LOWER + EE_CLR or RAISE + QK_BOOT)

2. **Check if in bootloader mode:**
   ```bash
   lsusb | grep -i "rp2040\|pico\|2e8a"
   ```
   
3. **Flash the firmware:**
   ```bash
   # Option 1: Copy UF2 file to mounted RP2040 drive
   cp bastardkb_charybdis_3x6_my-keyboard.uf2 /media/RPI-RP2/
   
   # Option 2: Use QMK flash command
   qmk flash -kb bastardkb/charybdis/3x6 -km my-keyboard
   ```

## File Structure

Your project structure should look like:

```
/home/gespitia/projects/
├── bastardkb-qmk/                    # BastardKB QMK fork
│   ├── keyboards/bastardkb/charybdis/3x6/
│   └── bastardkb_charybdis_3x6_my-keyboard.uf2
└── qmk_userspace/                    # Your userspace
    ├── qmk.json
    ├── keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard/
    │   ├── keymap.c
    │   ├── config.h
    │   ├── rules.mk
    │   └── readme.md
    └── bastardkb_charybdis_3x6_my-keyboard.uf2
```

## Common Issues and Solutions

### Issue 1: "Invalid keymap argument"
**Cause:** Using standard QMK instead of BastardKB fork
**Solution:** Follow Step 1 to set up BastardKB QMK fork

### Issue 2: "Invalid `qmk.json`" 
**Cause:** Wrong userspace version or incorrect build target format
**Solution:** Use version "1.0" and correct keyboard identifier format

### Issue 3: Keymap not found
**Cause:** Userspace overlay not configured properly
**Solution:** Run `qmk config user.overlay_dir="$(realpath .)"` from userspace directory

### Issue 4: Wrong keyboard identifier
**Cause:** Using `bastardkb/charybdis/3x6/blackpill` instead of `bastardkb/charybdis/3x6`
**Solution:** Use the correct identifier without the MCU suffix

### Issue 5: "Could not determine QMK userspace location"
**Cause:** Running `qmk userspace-compile` without proper overlay configuration
**Solution:** Run `qmk config user.overlay_dir="$(realpath .)"` from userspace directory

### Issue 6: Running from wrong directory
**Cause:** Running QMK commands from `/home/gespitia/projects/qmk_firmware` (standard QMK)
**Solution:** Always run compile commands from `/home/gespitia/projects/bastardkb-qmk` directory

**Important:** The original error occurred because you were in the wrong QMK installation directory. Always ensure you're using the BastardKB QMK fork directory for compilation.

## Key Differences from Standard QMK

1. **Must use BastardKB QMK fork** - Contains specific code for BastardKB keyboards
2. **Different userspace schema** - Uses version 1.0 instead of 1.1
3. **Keyboard identifiers** - Use base keyboard name without MCU variants
4. **Special features** - Includes BastardKB-specific features like auto pointer layers, sniping mode, etc.

## Diagnostic Commands

If you encounter issues, use these commands to diagnose:

```bash
# Check if keymap exists in the expected location
find /home/gespitia/projects/qmk_userspace -name "keymap.c" -path "*/bastardkb/charybdis/3x6/keymaps/*"

# Verify BastardKB QMK fork has the keyboard definition
cd /home/gespitia/projects/bastardkb-qmk
find . -path "*/bastardkb/charybdis/3x6*" -name "keyboard.json" -o -name "info.json"

# Check current QMK configuration
qmk config

# Test if userspace overlay is working
qmk userspace-doctor

# List all available keyboards in BastardKB QMK
qmk list-keyboards | grep charybdis
```

## Future Compilations

For subsequent compilations, simply run:

```bash
cd /home/gespitia/projects/bastardkb-qmk
qmk compile -c -kb bastardkb/charybdis/3x6 -km my-keyboard
```

## References

- [BastardKB Compile Firmware Guide](https://docs.bastardkb.com/fw/compile-firmware.html)
- [BastardKB QMK Repository](https://github.com/bastardkb/bastardkb-qmk)
- [BastardKB QMK Userspace](https://github.com/Bastardkb/qmk_userspace)
- [QMK Documentation](https://docs.qmk.fm/)

---

*Last updated: October 18, 2025*
*Generated from troubleshooting session with GitHub Copilot*



----

## TL;DR 

_Oct 20, 2025_


```My setup commands for context:

cd /home/USERNAME/projects && git clone https://github.com/bastardkb/bastardkb-qmk
cd /home/USERNAME/projects/bastardkb-qmk && git checkout -b bkb-master origin/bkb-master
qmk git-submodule
qmk config user.qmk_home="$(realpath .)"
cd /home/USERNAME/projects/qmk_userspace && qmk config user.overlay_dir="$(realpath .)"
ln -s /home/USERNAME/projects/qmk_userspace/keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard /home/USERNAME/projects/bastardkb-qmk/keyboards/bastardkb/charybdis/3x6/keymaps/my-keyboard
cd /home/USERNAME/projects/bastardkb-qmk
qmk config
#user.overlay_dir=/home/USERNAME/projects/qmk_userspace
#user.qmk_home=/home/USERNAME/projects/bastardkb-qmk
qmk compile -c -kb bastardkb/charybdis/3x6 -km my-keyboard

```

Make sure you clear eeprom when compiling and flashing new firmware. Easiest way to do this is to enter bootloader via bootmagic (hold down top leftmost key on the left half or top rightmost key on the right half while connecting to USB)
Alternatively if you're compiling and flashing your own firmware, just disable via.
The dynamic keymap and associated parts are stored in persistent memory, and this is not repopulated from the flash memory automatically.