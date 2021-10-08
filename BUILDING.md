# Prerequisites

* GNU Make
* [RGBDS](https://rgbds.gbdev.io/)
* Python
* (optional) bsdiff
* (optional) [Save state patch by Matt Currie](https://github.com/mattcurrie/gb-save-states)

# Building
1. Place a copy of the original ROM in the root directory under the filename
   `Wario Land - Super Mario Land 3 (W) [!].gb`.
2. (optional) Copy the save state patch
   `Wario Land - Super Mario Land 3 (W) [!].gb.bsdiff`
   into the root directory.
3. Run `make`.
   This builds the patched ROM `sml3_practice.gb` in the root directory.
