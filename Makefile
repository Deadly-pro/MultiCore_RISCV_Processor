#
# A Makefile to compile and run your processor with Icarus Verilog
# This version is built for Windows and finds files in your subfolders.
#

# --- Configuration ---
# --- FIX: Added './' prefix to match the wildcard output ---
TESTBENCH_FILE = ./multicore_tb.v
OUTPUT_EXE = processor.vvp
WAVEFORM_FILE = waveform.vcd

# --- Find all Verilog files ---
# We list all the directories that contain Verilog source code,
# based on your screenshot.
VERILOG_DIRS := . \
                decode_stage \
                exec_stage \
                fetch_stage \
                mem_stage \
                write_stage \
                memory

# This command finds all .v files in those directories
VERILOG_SOURCES := $(foreach dir,$(VERILOG_DIRS),$(wildcard $(dir)/*.v))

# This filter-out command will now correctly find and remove the testbench
# from the main list, preventing the "already declared" error.
VERILOG_FILES := $(filter-out $(TESTBENCH_FILE), $(VERILOG_SOURCES))

# --- Rules ---

# Default rule: 'make' or 'make all'
all: $(OUTPUT_EXE)
	@echo "Compilation successful. Running simulation..."
	vvp $(OUTPUT_EXE)
	@echo "Simulation finished. Opening waveform..."
	gtkwave $(WAVEFORM_FILE)

# Compile rule: How to build the .vvp executable
$(OUTPUT_EXE): $(TESTBENCH_FILE) $(VERILOG_FILES)
	@echo "Compiling all Verilog files..."
	@echo "Found files: $(VERILOG_FILES)"
	iverilog -g2012 -o $(OUTPUT_EXE) $(TESTBENCH_FILE) $(VERILOG_FILES)

# Clean rule: 'make clean' to remove old files
clean:
	@echo "Cleaning up old files..."
	rm -f $(OUTPUT_EXE) $(WAVEFORM_FILE)