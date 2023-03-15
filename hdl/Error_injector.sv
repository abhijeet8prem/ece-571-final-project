module error_injector(
  input rst,
  input er_load,
  input [31:0] er_in,
  input [31:16] cw_d_in,
  input [15:0] cw_crc_in,
  output [15:0] er_cw_crc,
  output [31:16] er_cw_d);

  reg [31:0] error;

 always_latch begin
      if (rst) begin
         error <= 32'd0;  // clear error register on reset
      end else if (er_load) begin
         error <= er_in;  // load err_in into error register on load
      end
   end
 assign {er_cw_d, er_cw_crc} = ({cw_d_in, cw_crc_in} ^ error);
 
 
endmodule