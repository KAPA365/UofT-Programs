# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog -novopt part1.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver part1

#log all signals and add some signals to waveform window
log -r {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {clock} 1 0ns, 0 5ns -r 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {wren} 0
force {address} 00000 
force {data} 0000
#run simulation for a few ns
run 50ns

force {wren} 1
force {address} 01100 
force {data} 1100
#run simulation for a few ns
run 50ns


force {wren} 0
force {address} 01100 
force {data} 0001
#run simulation for a few ns
run 50ns

force {wren} 1
force {address} 01100 
force {data} 1001
#run simulation for a few ns
run 50ns

force {wren} 1
force {address} 01000 
force {data} 0111
#run simulation for a few ns
run 50ns

force {wren} 0
force {address} 01100 
force {data} 1111
#run simulation for a few ns
run 50ns