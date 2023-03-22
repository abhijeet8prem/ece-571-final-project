module rx_wrapper(topInterface.receiver RxPort);
  logic [31:0] ercodeWord, dataOut1, dataOut2;
  reg   [31:0] erCW, ErrCW;
  logic [15:0] CrcRem, dOut, crcIn;
  logic        CrcRemValid, isZero, eot;
  
  crcCheck        cC(RxPort.clk, RxPort.rst, RxPort.erCWValid, erCW, CrcRemValid, CrcRem, ercodeWord); 
  ErrorCorrection EC(RxPort.clk, RxPort.rst, CrcRemValid, ErrCW, crcIn, RxPort.dOutValid, RxPort.erFree, RxPort.dOut);

  always_latch
    if(RxPort.erCWValid) erCW = RxPort.erCW;
  
  always_latch
    if(CrcRemValid) ErrCW = ercodeWord;
  
  always_latch
    if(CrcRemValid) crcIn = CrcRem;

  always_latch
    if(CrcRemValid) eot = RxPort.endMsgIn;
   
  always_latch
    if(RxPort.dOutValid) RxPort.endMsgOut = eot;


endmodule