# ==========================================
# RISC-V Multicore Project Makefile
# ==========================================

# 1. Automatic Source Discovery
# This uses the Linux 'find' command to grab every .v file 
# in the current directory (.) and all subdirectories.
SRCS = $(shell find . -name "*.v")

# 2. Output Configuration
PROJ_NAME = processor
DUMP_FILE = waveform.vcd

# 3. Toolchain
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

# 4. Compilation Flags
# -o: Output name
# -g2012: Enables SystemVerilog features (optional but good)
FLAGS = -o $(PROJ_NAME) -g2012

# ==========================================
# Targets
# ==========================================

all: compile run

# Compile: Feeds ALL found .v files to iverilog
compile:
	@echo "Compiling $(words $(SRCS)) source files..."
	$(COMPILER) $(FLAGS) $(SRCS)
	@echo "Compilation Successful! 💾"

# Run: Executes the simulation
run:
	@echo "Running Simulation..."
	$(SIMULATOR) $(PROJ_NAME)
	@echo "Simulation Complete! 🚀"

# View: Opens GTKWave
wave:
	@echo "Opening Waveforms..."
	$(VIEWER) $(DUMP_FILE) &

# Clean: Removes generated files
clean:
	rm -f $(PROJ_NAME) $(DUMP_FILE)
	@echo "Cleaned up. 🧹"
