vlib work
vlog source ErrorCorrection.sv crcChecker.sv errorInjector.sv receiver.sv top.sv topinterface.sv transmitter.sv verification.sv
# comment line 2 and uncomment line 4 to run in debug mode
# vlog source ErrorCorrection.sv crcChecker.sv errorInjector.sv receiver.sv top.sv topinterface.sv transmitter.sv verification.sv +define+DEBUG
add wave -r *
vsim -c top; run -all
