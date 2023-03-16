// vertion 2 code
module error_injector( topInterface.errorInjectorV2 EIPorts);

 assign EIPorts.erCW = CW ^ erIn;   // adding the error with the incoming codeword
 
endmodule