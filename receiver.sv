module rx_wrapper(topInterface.receiver RxPort);
  logic [31:0] ercodeWord, dataOut1, dataOut2;
  reg   [31:0] erCW, m, n, ErrCW;
  logic [15:0] CrcRem, dOut, o, crcIn;
  logic        CrcRemValid, isZero, busy ;
  
  crcCheck        CR(RxPort.clk, RxPort.rst, RxPort.erCWValid, erCW, CrcRemValid, CrcRem, ercodeWord); 
  ErrorCorrection EC(RxPort.clk, RxPort.rst, CrcRemValid, ErrCW, crcIn, RxPort.dOutValid, RxPort.erFree, RxPort.dOut);

  assign erCW = m;
  always_ff@(posedge RxPort.clk)
    if(RxPort.erCWValid) m = RxPort.erCW;
  
  assign ErrCW = n;
  always_latch
    if(CrcRemValid) n = ercodeWord;
  
  assign crcIn = o;
  always_latch
    if(CrcRemValid) o = CrcRem;


endmodule