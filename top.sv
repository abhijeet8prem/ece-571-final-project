module top();
  reg [15:0] datain;
  reg clk = 1'b1;
  reg rst, finish;
  reg [15:0] crcout;
  bit [7:0] p1,p2;
  string s = "HARSHA";
  bit [7:0] msg[$];
  bit [7:0] out;
  int length;
  
  crcgen DUT(.*,.data(datain));
  
  initial begin
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1'b1;
    #5; rst = 1'b0;
    length = s.len();
    $display("%d",length);
    for(int j = 0; j<length; j++)
      begin
        out = s.getc(j);
        msg = {msg,out};
        $display($time,"%p",msg);
      end
 
    forever begin
      if((length%2 == 0) && ~(top.DUT.busy)) begin
        if(msg.size() == 0)begin
          break;
        end
        else begin
          p1 = msg.pop_front();
          p2 = msg.pop_front();
          datain = {p1,p2};
        end
      end
      if(top.DUT.reset == '1)begin
        rst = '1;
        #10;
        rst ='0;
      end
      @(negedge clk);
    end
$finish();
end

  initial begin
    $monitor("%b,%b,%b,%b,%b",clk,p1,p2,datain,crcout);
  end
endmodule

