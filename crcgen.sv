module DFF(D,clk,rst,Q);
input D; // Data input 
input clk; // clock input
input rst;  // reset input
output bit Q; // output Q 
always @(posedge clk) 
begin
  if(rst)
    Q<=0;
  else
    Q<=D;
end
endmodule

module crcgen(input clk,rst,[15:0]data,output reg [15:0]crcout);
  reg [15:0] genpol;
  bit databit;
  reg [31:0] datawithcrc;
  int i = 32;
  
  assign datawithcrc = {data,16'b0};
  
  always@(posedge clk)
    begin
      $display("data is %b",datawithcrc);
      if((i >= 0) && (!rst))
        begin
          databit = datawithcrc[i-1];
          $display("%d,%b",i-1,datawithcrc[i-1]);
          i = i-1;
        end
      else if(i == -1)
        begin
          crcout = genpol;
          $display("%b",i-1);
          @(posedge clk);
          crcout = 'x;
          i = 32;
        end
    end

  DFF D15((databit^genpol[15]),clk,rst,genpol[0]);
  DFF D0(genpol[0],clk,rst,genpol[1]);
  DFF D1(genpol[1],clk,rst,genpol[2]);
  DFF D2(genpol[2],clk,rst,genpol[3]);
  DFF D3(genpol[3],clk,rst,genpol[4]);
  DFF D4((genpol[4]^genpol[15]),clk,rst,genpol[5]);
  DFF D5(genpol[5],clk,rst,genpol[6]);
  DFF D6(genpol[6],clk,rst,genpol[7]);
  DFF D7(genpol[7],clk,rst,genpol[8]);
  DFF D8(genpol[8],clk,rst,genpol[9]);
  DFF D9(genpol[9],clk,rst,genpol[10]);
  DFF D10(genpol[10],clk,rst,genpol[11]);
  DFF D11((genpol[11]^genpol[15]),clk,rst,genpol[12]);
  DFF D12(genpol[12],clk,rst,genpol[13]);
  DFF D13(genpol[13],clk,rst,genpol[14]);
  DFF D14(genpol[14],clk,rst,genpol[15]);

endmodule
