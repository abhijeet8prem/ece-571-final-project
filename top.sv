module top();
  reg [15:0] dataIn, CrcOut, dataOut;
  reg clk = 1'b1;
  reg rst, crcValid;
  bit [7:0] m1, m2, ascii;
  string s = "HARSHA";
  bit [7:0] msg[$];
  int length;
  
  crcgen DUT(.*);
  
  initial begin
    forever #5 clk = ~clk;
  end
  
  task reset();
    begin
      rst = '1;
      @(posedge clk);
      rst = '0;
    end
  endtask
  
  task strtoascii(input int length, input string s);
    begin
      for(int i = 0; i < length; i++)begin
        ascii = s.getc(i);
        msg = {msg,ascii};
        $display($time,"%p",msg);
      end
    end
  endtask
  
  task Evenlen(input int length, input bit [7:0] msg [$]);
    forever begin
      if(~(top.DUT.busy)) begin
        if(msg.size() == 0)begin
          break;
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
        end
      end
      
      if(top.DUT.clear == '1)begin
         reset();
         $display("%b,%b,%b,%b,%b", m1, m2, dataIn, dataOut, CrcOut);
      end
      @(negedge clk);
    end
    $finish();
  endtask
      
  task Oddlen(input int length, input bit [7:0] msg [$]);
    forever begin
      if(~(top.DUT.busy)) begin
        if(msg.size() == 0)
          break;
        else if(msg.size() == 1)begin
          m1 = msg.pop_front();
          m2 = 8'b0;
          dataIn = {m1,m2};
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
        end
      end
      if(top.DUT.clear == '1)begin
         reset();
         $display("%b,%b,%b,%b,%b", m1, m2, dataIn, dataOut, CrcOut);
      end
      @(negedge clk);
    end
    $finish();
  endtask
          
  initial begin
    rst = 1'b1;
    @(negedge clk);
    rst = 1'b0;
    length = s.len();
    $display("%d",length);
    strtoascii(length,s);
    
    if(length%2 == 0) 
        Evenlen(length, msg);
    else 
      Oddlen(length, msg);
  end
endmodule


