////////////////////////////////////////////////////////////////////////////////////////////////
// transmitter.sv - Module to genearte the CRC pattern based on the input.
//                  16 bit CRC is calculated for every 16 bit data input.                   
//
// Last modified    : 22th Mar 2023
//
// Description:
//  * Connected with the help of Topninterface to pass input signals
//  * modport trasmitter facilitates the inputs and outputs
//        
//          
////////////////////////////////////////////////////////////////////////////////////////////////

module CrcGen(topInterface.transmitter TxPort);
  reg [15:0] Q; 
  bit databit;
  reg [31:0] datawithzeroes, CW; 		//16 bit input data appended with 16 zeroes to append the 16 bit CRC pattern
  enum logic [1:0]{Idle, Load, Busy, Wait}State, NextState;
  logic done;					//done signal to indicate the CRC generation completion
  logic cnt_en, ld_en;				//ld_en load enable to latch the input Error code word, cnt_en to Start the counter
  logic clr;  					//Clear signal to clear the D flip flops after every CRC generation
  
  assign datawithzeroes = {TxPort.dataIn,16'b0};
  
  //Counter module to keep track of bit shifts
  DownCounter D(TxPort.clk, ld_en, datawithzeroes, cnt_en, databit, done);
  
  //Initialisation of FSM 
  always_ff @(posedge TxPort.clk)
    begin
      if(TxPort.rst)
        State <= Idle;
      else
        State <= NextState;
    end

  //Setting the output values of the FSM
  always_comb
    begin
      {TxPort.Txbusy, ld_en, cnt_en, clr} = '0;
      case(State)
        Idle: begin
	  clr = '1;
        end
        Load:begin
          ld_en = '1;
          TxPort.Txbusy = '1;
        end
        Busy:begin
          TxPort.Txbusy = '1;
	  cnt_en = '1;
        end
        Wait:begin
          TxPort.Txbusy = '1;
          clr = '1;
        end
      endcase
    end
  
  //Next state logic for the FSM
  always_comb
    begin
      NextState = State;
      case(State)
        Idle:begin
          if(TxPort.dataValid)
            NextState = Load;
          else 
            NextState = Idle;
        end
        Load:begin
            NextState = Busy;
        end
        Busy:begin
          if(done)
            NextState = Wait;
          else
            NextState = Busy;
        end
        Wait: begin
          if(~TI.Rxbusy)
            NextState = Idle;
          else
            NextState = Wait;
        end
      endcase
    end

  always_latch
     if(done) CW = {TxPort.dataIn,Q};

  //Driving the output bus based on receiver busy
  assign TxPort.CW = ((State == Wait) && (~TI.Rxbusy)) ? CW : 'z;
  assign TxPort.CWValid = ((State == Wait) && (~TI.Rxbusy)) ? '1 : 0;

  // Implementing shift register using D flip flops
  DFF D0((databit^Q[15]),TxPort.clk,TxPort.rst,clr,Q[0]);
  DFF D1(Q[0],TxPort.clk,TxPort.rst,clr,Q[1]);
  DFF D2(Q[1],TxPort.clk,TxPort.rst,clr,Q[2]);
  DFF D3(Q[2],TxPort.clk,TxPort.rst,clr,Q[3]);
  DFF D4(Q[3],TxPort.clk,TxPort.rst,clr,Q[4]);
  DFF D5((Q[4]^Q[15]),TxPort.clk,TxPort.rst,clr,Q[5]);
  DFF D6(Q[5],TxPort.clk,TxPort.rst,clr,Q[6]);
  DFF D7(Q[6],TxPort.clk,TxPort.rst,clr,Q[7]);
  DFF D8(Q[7],TxPort.clk,TxPort.rst,clr,Q[8]);
  DFF D9(Q[8],TxPort.clk,TxPort.rst,clr,Q[9]);
  DFF D10(Q[9],TxPort.clk,TxPort.rst,clr,Q[10]);
  DFF D11(Q[10],TxPort.clk,TxPort.rst,clr,Q[11]);
  DFF D12((Q[11]^Q[15]),TxPort.clk,TxPort.rst,clr,Q[12]);
  DFF D13(Q[12],TxPort.clk,TxPort.rst,clr,Q[13]);
  DFF D14(Q[13],TxPort.clk,TxPort.rst,clr,Q[14]);
  DFF D15(Q[14],TxPort.clk,TxPort.rst,clr,Q[15]);

endmodule

module DFF(D,clk,clr,rst,Q);
  input D;
  input clk;
  input rst; 
  input clr; 
  output bit Q; 

  always_ff @(posedge clk) 
    begin
      if(rst | clr)
        Q <= 0;
      else
        Q <= D;
    end
endmodule

module DownCounter(clk, load, data, enable, databit, done);
  input clk;
  input load;
  input [31:0] data;
  input enable;
  output bit databit;
  output bit done;
  reg [31:0] m;
  reg [6:0] count;

  assign done = (count == 0);

  always_ff @(posedge clk)
    begin
      if(load)begin
         m <= data;
         count <= 33;
      end
      else if (enable)
        begin
          databit <= m[count-2];
          count <= count - 1;
        end
    end
  
endmodule