module errorInj(topInterface.errorInjector EIPorts);

 assign EIPorts.erCW = (EIPorts.CWValid) ? (EIPorts.CW ^ EIPorts.erIn) : 'z ;  
 assign EIPorts.erCWValid = (EIPorts.CWValid) ? 1 : 'z ; 
 

endmodule