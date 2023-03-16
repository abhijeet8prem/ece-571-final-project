// vertion 2 code
module error_injector( topInterface.errorInjectorV2 EIPorts);

 assign EIPorts.erCW <= EIPorts.CW ^ EIPorts.erIn;   // adding the error with the incoming codeword
 
endmodule