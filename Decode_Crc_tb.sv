module top;
  //bit clock;
  reg [15:0] CrcRem;
  reg [31:0] CrcCor;
  crc_detection d1(.*);
 /*initial begin
      forever #10 clock=~clock;
    end*/
initial begin
CrcRem=16'b0001001000110001;
#10;
$display($time,"CrcCor=%b",CrcCor);

CrcRem=16'b0000000000000001;
#10;
$display($time,"CrcCor=%b",CrcCor);

CrcRem=16'b0100000010000111;
#10;
$display($time,"CrcCor=%b",CrcCor);
$finish;
end
endmodule
