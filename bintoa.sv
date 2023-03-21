module byte_to_ascii (
  input [47:0] data_in,
  input dataValid,
  output string ascii_str
);

  reg [7:0] ascii_byte;
  string str;
  integer i;

  always @ (posedge dataValid) begin
    for (i = 7; i >0; i--) begin
      ascii_byte = data_in[(i*8-1)-:8];
      ascii_str = string'(ascii_byte); 
      str = {str, ascii_str};
    end
    $display("string is %s", str);
  end

endmodule
