vlib work
vlog errorCorrection.sv errorChecker.sv errorInjector.sv receiver.sv top.sv topInterface.sv transmitter.sv CorAndVerification.sv
# comment line 2 and uncomment line 4 to run in debug mode
#vlog errorCorrection.sv errorChecker.sv errorInjector.sv receiver.sv top.sv topInterface.sv transmitter.sv CorAndVerification.sv +define+DEBUG
vsim -c work.top
add wave -r *
run -all