////////////////////////////////////////////////////////////////////////////////////////////////
// receiver.sv - Module to receive the corrupted codeword and sends out the corrected output
//                                     
//
// Last modified    : 24th Mar 2023
//
// Description:
//  * Connected with the help of topInterface to pass input and output signals
//  * modport receiver facilitates the inputs and outputs
//  * All 1 or 2 bit erros are corrected.
//  * 3 or more errors that happened on the CW cannot be corrected but are reported
//          
//
////////////////////////////////////////////////////////////////////////////////////////////////

module rx_wrapper(topInterface.receiver RxPort);
  logic [31:0] erCWOut;  		//output from the Errorcheck block
  reg   [31:0] erCWIn;			//register to latch the output
  logic [15:0] RemIn;			//output from the Errorcheck block
  reg   [15:0] RemOut;			//register to latch the output
  logic        RemValid;		//signal to indicate valid data on the output bus
  
  ErrorCheck      E1(RxPort.clk, RxPort.rst, RxPort.erCWValid, RxPort.erCW, RemValid, RemOut, erCWOut); 
  ErrorCorrection E2(RxPort.clk, RxPort.rst, RemValid, erCWIn, RemIn, RxPort.dOutValid, RxPort.erFree, RxPort.dOut);
  
  //signal to indicate the busy state of the receiver
  assign RxPort.Rxbusy = (rx_wrapper.E1.busy | rx_wrapper.E2.busy); 
  assign RxPort.endMsgOut = (RxPort.endMsgIn && RxPort.dOutValid) ? '1 : '0;

  always_latch
    if(RemValid) erCWIn = erCWOut;
  
  always_latch
    if(RemValid) RemIn = RemOut;

endmodule