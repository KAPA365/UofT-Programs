# Set the working directory, where all compiled verilog goes
vlib work

# Compile all Verilog modules
# Could also handle multiple verilog files 
vlog part1.v

# Load the simulation using part1 as the top-level simulation module
vsim part1

# Log all signals 
log -r {/*}

# Add all items in top level simulation module
add wave {/*}

# Test Case 1: Basic Counting
force {Clock} 1 0ns, 0 5ns -r 10ns
force {Enable} 1
force {Reset} 0 0ns, 1 8ns, 0 18ns, 0 98ns
run 100ns

# This test case verifies basic counting behavior. The counter should increment each time the clock signal rises while the "Enable" signal is active. It also demonstrates the effect of a brief reset on the counter.


# Test Case 2: Counting with Resets
force {Clock} 1 0ns, 0 5ns -r 10ns
force {Enable} 1
force {Reset} 1 0ns, 0 8ns, 1 18ns, 0 28ns, 1 38ns, 0 48ns, 1 98ns 
run 100 ns

# This test case checks how the counter responds to repeated resets. It verifies that the counter correctly resets and continues counting.

# Test Case 3: Continuous Counting
force {Clock} 1 0ns, 0 5ns -r 10ns
force {Enable} 1
force {Reset} 0
run 100 ns

#In this test case, the counter continuously counts without resets. It demonstrates how the counter behaves over an extended period.


# Test Case 4: Maximum Count
force {Clock} 1 0ns, 0 5ns -r 10ns
force {Enable} 1
force {Reset} 1 255ns
run 300 ns

# This test case checks if the counter correctly handles reaching its maximum #count value and resets itself. It verifies the behavior of the counter when it hits the #maximum value.

# Exit the simulation
#quit