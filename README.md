# The Circle
## ZX Spectrum Circle Drawing Program

![ZX Spectrum Screenshot](https://github.com/zstarczali/circle/raw/main/screenshot.png) 

## Table of Contents
1. [Program Description](#program-description)
2. [Technical Specifications](#technical-specifications)
3. [Build Instructions](#build-instructions)
4. [Execution](#execution)
5. [Customization](#customization)
6. [Algorithm Details](#algorithm-details)
7. [Memory Usage](#memory-usage)
8. [Compatibility](#compatibility)
9. [Known Issues](#known-issues)
10. [License](#license)

## Program Description

This Z80 assembly program implements Bresenham's circle algorithm to draw perfect circles on the ZX Spectrum 48K. The program:
- Clears the screen
- Draws a circle with configurable position and radius
- Halts the CPU when finished

## Technical Specifications

- **Target Platform**: ZX Spectrum 48K (works on all models)
- **Memory Requirements**: 
  - 32768-49151 (0x8000-0xBFFF) - Program location
  - 16384-22527 (0x4000-0x57FF) - Screen memory
- **Output Format**: .SNA snapshot file
- **Assembler**: sjasmplus (modern Z80 assembler)
- **Dependencies**: None

## Build Instructions

### Prerequisites
1. Install [sjasmplus](https://github.com/z00m128/sjasmplus) (v1.18.3 or newer recommended)
   - Windows: Download pre-built binary
   - Linux: `sudo apt install sjasmplus` or build from source
   - macOS: `brew install sjasmplus`

### Compilation
```bash
sjasmplus --lst=circle.lst --raw=circle.bin --sym=circle.sym circle.asm 
```
#### This generates:

  - circle.sna - Executable snapshot
  - circle.lst - Assembly listing with addresses
  - circle.sym - Symbol table
  - circle.bin - Raw binary

### Execution
  Load circle.sna in your preferred emulator:
  Fuse (multi-platform)
  ZX Spin (Windows)
  ZEsarUX (Linux/macOS)

The program will:

  - Immediately clear the screen
  - Draw a circle with default parameters
  - Halt when complete (press reset to rerun)

### Customization
Modify these values in the source code:

```assembly
Start:
    LD D, 128   ; Center X (0-255)
    LD E, 96    ; Center Y (0-191)
    LD B, 40    ; Radius (1-96 recommended)
For different colors, add after CALL CLEAR_SCREEN:
```
```assembly
    LD A,color_code  ; 0-15 (INK+PAPER*8)
    LD (23693),A     ; Set border
    CALL 8859         ; Set colors
```
### Algorithm Details
Bresenham's Circle Algorithm Implementation
Uses only integer arithmetic
Implements the midpoint circle algorithm
Draws all 8 symmetrical octants simultaneously
Decision parameter updates use bit shifts for efficiency

#### Pixel Plotting
Uses pre-calculated screen address table (SCREEN_Y_LOOKUP)
Optimized bit positioning with RRCA rotation
Automatic clipping of Y coordinates >191
Screen memory layout compliant with ZX Spectrum standard

### Memory Usage
Address Range	Usage
0x4000-0x57FF	Screen memory
0x8000-0x8020	Main program
0x8020-0x80FF	Circle algorithm
0x8100-0x81FF	Screen address table
0x8200-0x83FF	PlotPixel routine
Compatibility
Tested on:

Original ZX Spectrum 48K hardware
ZX Spectrum+
ZX Spectrum 128K (48K mode)
All major emulators

### Known Issues
Maximum reliable radius is 96 pixels (due to 8-bit math)
No bounds checking for X coordinate
Simple HALT at end (no return to BASIC)
Color attributes not set (uses existing screen colors)
### License
This work is released into the Public Domain.
