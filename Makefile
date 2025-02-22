# Flexible Makefile for compiling Verilog code with Icarus Verilog and viewing with GTKWave

# Directory for output files
BUILD_DIR := build
SRC_DIR := src
TB_DIR := tb

# Rule to compile and run simulation for other individual modules
$(MAKECMDGOALS):
	@echo "Processing $@..."
	@mkdir -p $(BUILD_DIR)
	iverilog -o $(BUILD_DIR)/$@_dsn $(TB_DIR)/$@_tb.v $(SRC_DIR)/$@.v
	vvp $(BUILD_DIR)/$@_dsn 
# && gtkwave $(BUILD_DIR)/$@.vcd

# Clean rule
clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR)
