#TESTING THE DISPLAY COUNTER MODULE WITH A SEPARATE DO FILE (SIMULATION)
# Set the working directory
vlib work

# Compile the RateDivider module and other required modules
vlog part2.v

# Load the simulation using RateDivider as the top-level simulation module
vsim RateDivider

# Log all signals
log -r {/*}

# Add all items in the top-level simulation module
add wave {/*}

# Test Case 1: Full Speed
force {ClockIn} 1 0ns, 0 10ns -r 20ns
force {Reset} 0
force {Speed} 2'b00
run 100ns

# Test Case 2: 1 Hz Speed
force {ClockIn} 1 0ns, 0 10ns -r 20ns
force {Reset} 0
force {Speed} 2'b01
run 1us

# Test Case 3: 0.5 Hz Speed
force {ClockIn} 1 0ns, 0 10ns -r 20ns
force {Reset} 0
force {Speed} 2'b10
run 2us

# Test Case 4: 0.25 Hz Speed
force {ClockIn} 1 0ns, 0 10ns -r 20ns
force {Reset} 0
force {Speed} 2'b11
run 4us

# Exit the simulation
#quit



# Set the working directory
vlib work

# Compile the DisplayCounter module and other required modules
vlog part2.v


# Load the simulation using DisplayCounter as the top-level simulation module
vsim part2.v

# Log all signals
log -r {/*}

# Add all items in the top-level simulation module
add wave {/*}

# Test Case 1: Basic Counting
force {Clock} 1 0ns, 0 5ns -r 10ns
force {EnableDC} 1
force {Reset} 0 0ns, 1 8ns, 0 18ns, 0 98ns
run 100ns

# Test Case 2: Counting with Resets
force {Clock} 1 0ns, 0 5ns -r 10ns
force {EnableDC} 1
force {Reset} 1 0ns, 0 8ns, 1 18ns, 0 28ns, 1 38ns, 0 48ns, 1 98ns
run 100 ns

# Test Case 3: Continuous Counting
force {Clock} 1 0ns, 0 5ns -r 10ns
force {EnableDC} 1
force {Reset} 0
run 100 ns

# Test Case 4: Maximum Count
force {Clock} 1 0ns, 0 5ns -r 10ns
force {EnableDC} 1
force {Reset} 1 15ns
run 100 ns

# Exit the simulation
quit