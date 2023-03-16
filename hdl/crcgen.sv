module crcgen(topinterface.CrcIntA gen); 
  reg [15:0] Q; 
  bit databit;
  reg [31:0] datawithzeroes; //data appended with zeroes
  enum logic [1:0]{Init, Load, Reset}State, NextState; //FSM with three states
  reg ld_en, cnt_en, done, clr; //busy, load_enable, count_enable, done, clear
  
  assign datawithzeroes = {gen.dataIn,16'b0};
  assign eot = (gen.eom == 1);
  
  DownCounter D(gen.clk, ld_en, datawithzeroes, cnt_en, databit, done);
  
  always_ff @(posedge gen.clk)
    begin
      if (gen.rst)
        State <= Init;
      else
        State <= NextState;
    end

  always_comb
    begin
      {gen.busy, ld_en, cnt_en, gen.crcValid, clr} = '0;
      case(State)
        Init: begin
          gen.busy = '0;
          ld_en = '1;
        end
        Load:begin
          gen.busy = '1;
          cnt_en = '1;
        end
        Reset:begin
          clr = '1;
          gen.busy = '1;
	  gen.crcValid = '1;
        end
      endcase
    end
  
  always_comb
    begin
      NextState = State;
      case(State)
        Init:begin
          NextState = Load;
        end
        Load:begin
          if(done == 1)
            NextState = Reset;
        end
        Reset:begin
          NextState = Init;
        end
      endcase
    end
  
  always_ff@(posedge gen.clk)
    begin
      if(done == 1) begin
         gen.CrcOut <= Q;
         gen.dataOut <= gen.dataIn;
      end
      else begin
        gen.CrcOut <= '0;
        gen.dataOut <= '0;
      end
    end

  DFF D0((databit^Q[15]),gen.clk,gen.rst,clr,Q[0]);
  DFF D1(Q[0],gen.clk,gen.rst,clr,Q[1]);
  DFF D2(Q[1],gen.clk,gen.rst,clr,Q[2]);
  DFF D3(Q[2],gen.clk,gen.rst,clr,Q[3]);
  DFF D4(Q[3],gen.clk,gen.rst,clr,Q[4]);
  DFF D5((Q[4]^Q[15]),gen.clk,gen.rst,clr,Q[5]);
  DFF D6(Q[5],gen.clk,gen.rst,clr,Q[6]);
  DFF D7(Q[6],gen.clk,gen.rst,clr,Q[7]);
  DFF D8(Q[7],gen.clk,gen.rst,clr,Q[8]);
  DFF D9(Q[8],gen.clk,gen.rst,clr,Q[9]);
  DFF D10(Q[9],gen.clk,gen.rst,clr,Q[10]);
  DFF D11(Q[10],gen.clk,gen.rst,clr,Q[11]);
  DFF D12((Q[11]^Q[15]),gen.clk,gen.rst,clr,Q[12]);
  DFF D13(Q[12],gen.clk,gen.rst,clr,Q[13]);
  DFF D14(Q[13],gen.clk,gen.rst,clr,Q[14]);
  DFF D15(Q[14],gen.clk,gen.rst,clr,Q[15]);

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
  int count;

  assign done = (count == '0);

  always_ff @(posedge clk)
    begin
      if (load)begin
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

