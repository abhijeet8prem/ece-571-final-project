module top();
  reg [15:0] datain;
  reg clk = 1'b1;
  reg rst;
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
    for(int j =0;j<length;j++)
      begin
        out = s.getc(j);
        msg = {msg,out};
        $display($time,"%p",msg);
      end
    if((length%2) == 0) begin
      Evenlen(length, msg);
      $display($time,"HI");
    end
    else
      oddlen(length, msg);
  end
    
  task Evenlen(input int length, input bit [7:0] msg [$]);
    for(int i = 0; i < (length/2); i++) begin
        p1 = msg.pop_front();
        p2 = msg.pop_front();
        datain = {p1,p2};
        delay();
        reset();
      end
    $finish();
   endtask
    
  task oddlen(input int length, input bit [7:0] msg [$]);
    for(int i=0; i <= (length/2); i++) begin
      if(i == (length/2)) begin
          p1 = msg.pop_front();
          p2 = 8'b0;
          datain = {p1,p2};
          delay();
          reset();
       end else begin
          p1 = msg.pop_front();
          p2 = msg.pop_front();
          datain = {p1,p2};
          delay();
          reset();
       end
     end
    $finish();
   endtask
    
  task delay();
    repeat(33)@(negedge clk);
  endtask
    
  task reset();
     rst = 1'b1;
     repeat(2)@(negedge clk);
     rst = 1'b0;
  endtask
  
      
    /*

    for(int i=0;i<3;i++)
      begin
        m1 = msg.pop_front();
        m2 = msg.pop_front();
        data = {m1,m2};
        repeat(36)@(posedge clk);
        rst = 1'b1;
        #15;
        rst = 1'b0;
      end
    $finish();
  end*/
    
  initial begin
    $monitor("%b,%b,%b,%b,%b",clk,p1,p2,datain,crcout);
  end
endmodule
