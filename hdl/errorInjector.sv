////////////////////////////////////////////////////////////////////////////////////////////////
// errorInjector.sv - Module to inject errors into the Codeword
//                                     
// Last modified    : 22th Mar 2023
//
// Description:
//  * Connected with the help of Topninterface to pass input signals
//  * modport errorInjector faciliates the connection of inputs and outputs
//        
//          
////////////////////////////////////////////////////////////////////////////////////////////////


module errorInj(topInterface.errorInjector EIPorts);
 
  //CW & CWValid     : Codeword Without errors & corresponding valid signal
  //erCW & erCWValid : Codeword after injecting errors & corresponding valid signal

  assign EIPorts.erCW = (EIPorts.CWValid) ? (EIPorts.CW ^ EIPorts.erIn) : 'z ;   
  assign EIPorts.erCWValid = (EIPorts.CWValid) ? '1 : '0 ; 

endmodule