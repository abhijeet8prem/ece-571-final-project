module crcgen(input clk,rst,[15:0]data,output reg [15:0]crcout);
  reg [15:0] genpol;
  bit databit;
  reg [31:0] datawithcrc;
  enum logic [1:0]{Init, Load, Reset}State, NextState;
  reg busy, ld_en, cnt_en, done, reset;
  
  assign datawithcrc = {data,16'b0};
  
  DownCounter D(clk, ld_en, datawithcrc, cnt_en, databit, done);
  
  always_ff @(posedge clk)
    begin
      if (rst)
        State <= Init;
      else
        State <= NextState;
    end

  always_comb
    begin
      {busy, ld_en, cnt_en, reset} = '0;
      case(State)
        Init: begin
          busy = '0;
          ld_en = '1;
        end
        Load:begin
          busy = '1;
          cnt_en = '1;
        end
        Reset:begin
          reset = '1;
          busy = '1;
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
  
  always_ff@(posedge clk)
    begin
      if(NextState == Reset)
         crcout <= genpol;
      else
        crcout <= 32'bx;
    end


  DFF D0((databit^genpol[15]),clk,rst,genpol[0]);
  DFF D1(genpol[0],clk,rst,genpol[1]);
  DFF D2(genpol[1],clk,rst,genpol[2]);
  DFF D3(genpol[2],clk,rst,genpol[3]);
  DFF D4(genpol[3],clk,rst,genpol[4]);
  DFF D5((genpol[4]^genpol[15]),clk,rst,genpol[5]);
  DFF D6(genpol[5],clk,rst,genpol[6]);
  DFF D7(genpol[6],clk,rst,genpol[7]);
  DFF D8(genpol[7],clk,rst,genpol[8]);
  DFF D9(genpol[8],clk,rst,genpol[9]);
  DFF D10(genpol[9],clk,rst,genpol[10]);
  DFF D11(genpol[10],clk,rst,genpol[11]);
  DFF D12((genpol[11]^genpol[15]),clk,rst,genpol[12]);
  DFF D13(genpol[12],clk,rst,genpol[13]);
  DFF D14(genpol[13],clk,rst,genpol[14]);
  DFF D15(genpol[14],clk,rst,genpol[15]);

endmodule

module DFF(D,clk,rst,Q);
  input D;
  input clk;
  input rst;  
  output bit Q; 

  always_ff @(posedge clk) 
    begin
      if(rst)
        Q <= 0;
      else
        Q <= D;
    end
endmodule

module DownCounter(clock, load, data, enable, databit, done);
  input clock;
  input load;
  input [31:0] data;
  input enable;
  output bit databit;
  output bit done;
  reg [31:0] m;
  int i;

  always_ff @(posedge clock)
    begin
      if (load)begin
         m <= data;
         i = 32;
         done = '0;
      end
      else if (enable)
        begin
          databit <= m[i-1];
          i <= i-1;
          if(i == 0) begin
            done = '1;
            i = 32;
          end
        end
    end
  
endmodule
