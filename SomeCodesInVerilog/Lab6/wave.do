
# Set the working directory, where all compiled verilog goes
vlib work

# Compile all Verilog modules
# Could also handle multiple verilog files 
vlog part2.v

# Load the simulation using part1 as the top-level simulation module
vsim part2

# Log all signals 
log -r {/*}

# Add all items in top level simulation module
add wave {/*}

# Test Case 1: A = 1, B = 2, C = 3, x = 4
force {Clock} 1 0ns, 0 5ns -r 10ns
force {Reset} 1 0ns, 0 10ns
force {Go} 0 0ns, 1 10ns, 0 50ns
#A = 1
run 10ns
force {DataIn} 00000001

run 10ns

#B = 2
force {DataIn} 00000010


run 10ns

#C = 3
force {DataIn} 00000011

run 10ns

#X = 4
force {DataIn} 00000100
run 10ns

run 100ns
 
