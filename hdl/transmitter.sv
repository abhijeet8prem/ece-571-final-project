module crcTxPort(topInterface.transmitter TxPort); 
  reg [15:0] Q; 
  bit databit;
  reg [31:0] datawithzeroes; 
  enum logic [1:0]{Reset, Load, Busy}State, NextState; 
  reg ld_en, cnt_en, done, clr; 
  
  assign datawithzeroes = {TxPort.dataIn,16'b0};
  
  DownCounter D(TxPort.clk, ld_en, datawithzeroes, cnt_en, databit, done);
  
  always_ff @(posedge TxPort.clk)
    begin
      if(TxPort.rst)
        State <= Reset;
      else
        State <= NextState;
    end

  always_comb
    begin
      {TxPort.busy, ld_en, cnt_en, clr} = '0;
      case(State)
        Reset: begin
	  clr = '1;
        end
        Load:begin
          ld_en = '1;
          TxPort.busy = '1;
        end
        Busy:begin
          TxPort.busy = '1;
	  cnt_en = '1;
        end
      endcase
    end
  
  always_comb
    begin
      NextState = State;
      case(State)
        Reset:begin
          if(TxPort.dataValid)
            NextState = Load;
          else 
            NextState = Reset;
        end
        Load:begin
            NextState = Busy;
        end
        Busy:begin
          if(done == 1)
            NextState = Reset;
          else
            NextState = Busy;
        end
      endcase
    end
 
  always_ff@(posedge TxPort.clk)
    begin
      if(done == 1) begin
         TxPort.CW <= {TxPort.dataIn,Q};
	 TxPort.CWValid = '1;
      end
      else begin
        TxPort.CW <= 'z;
	TxPort.CWValid = '0;
      end
    end

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
      if(rst || clr)
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
  int count = 33;

  assign done = (count == 0);

  always_ff @(posedge clk)
    begin
      if(load)begin
         m <= data;
         count = 33;
      end
      else if (enable)
        begin
          databit <= m[count-2];
          count <= count - 1;
        end
    end
  
endmodule
