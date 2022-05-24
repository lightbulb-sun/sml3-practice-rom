NAME := sml3_practice

GFX := gfx
BUILD_DIR := build
SML3_ROM := Wario Land - Super Mario Land 3 (W) [!].gb
SML3_SAVESTATES_BSDIFF := Wario Land - Super Mario Land 3 (W) [!].gb.bsdiff
TEMP_ROM := $(BUILD_DIR)/sml3_temp.gb
SOURCE_FILE := $(NAME).asm
OBJECT_FILE := $(BUILD_DIR)/$(NAME).o
OUTPUT_ROM := $(NAME).gb
SYM_ROM := $(BUILD_DIR)/$(NAME).sym

all:
	mkdir -p $(BUILD_DIR) $(GFX)/out
	python ./generate_tile_map.py
	rgbgfx -f -o $(GFX)/out/cursor_inactive.2bpp $(GFX)/cursor_inactive.png
	rgbgfx -f -o $(GFX)/out/cursor_active.2bpp $(GFX)/cursor_active.png
	rgbgfx -f -o $(GFX)/out/line.2bpp $(GFX)/line.png
	rgbgfx -f -o $(GFX)/out/version_minor.2bpp $(GFX)/version_minor.png
	bspatch "$(SML3_ROM)" "$(TEMP_ROM)" "$(SML3_SAVESTATES_BSDIFF)" || \
		cp "$(SML3_ROM)" "$(TEMP_ROM)"
	rgbasm  -E $(SOURCE_FILE) -o $(OBJECT_FILE)
	rgblink -n $(SYM_ROM) -O $(TEMP_ROM) -o $(OUTPUT_ROM) $(OBJECT_FILE)
	rgbfix -f gh $(OUTPUT_ROM)

clean:
	rm -rf $(BUILD_DIR) $(GFX)/out $(OUTPUT_ROM)

.PHONY: clean
