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


