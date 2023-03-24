vlib work
vlog source ErrorCorrection.sv crcChecker.sv errorInjector.sv receiver.sv top.sv topinterface.sv transmitter.sv verification.sv 
# vlog source ErrorCorrection.sv crcChecker.sv errorInjector.sv receiver.sv top.sv topinterface.sv transmitter.sv verification.sv DEBUG
add wave -r *
vsim -c top
VSIM 1> run - all