module top();
  logic [15:0] dataIn, CrcOut, dataOut;
  bit clk = 1'b1;
  logic rst, dataValid;
  logic [7:0] m1, m2, ascii;
  string s = "HARSHA";
  logic [7:0] msg[$];
  int length;            // input error vector for the error injuctor module
  logic endMsgIn; 
  logic [31:0] erIn = {2'b11,{30{1'b0}}};                 // singal to indicate end of message transmission
  
  topInterface    TI(.*); 
  crcTxPort       TX(TI.transmitter);
  errorInj        EI(TI.errorInjector);
  rx_wrapper      RX(TI.receiver);

  initial begin
    forever #5 clk = ~clk;
  end
  
  task reset();
    begin
      rst = '1;
      @(negedge clk);
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
  
  task Evenlen(input int length, input logic [7:0] msg [$]);  
    forever begin
      dataValid = '0;
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	  endMsgIn = '1;
	  @(negedge clk);
          break;
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
          dataValid = '1;
	  assert(ER.randomize());
        end
      end
      @(negedge clk);
    end
    repeat(10)@(negedge clk);
    $finish();
  endtask
      
  task Oddlen(input int length, input logic [7:0] msg [$]);
    forever begin
      dataValid = '0;
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	  endMsgIn = '1;
          @(negedge clk);
          break;
	end
        else if(msg.size() == 1)begin
          m1 = msg.pop_front();
          m2 = 8'b0;
          dataIn = {m1,m2};
          dataValid = '1;
	  assert(ER.randomize());
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
          dataValid = '1;
	  assert(ER.randomize());
        end
      end
      @(negedge clk);
    end
    $finish();
  endtask

  class Error_ratio;
    rand logic  [31:0] erIn1;
    constraint c_flips { $countones(erIn1) == 3; }
  endclass

  Error_ratio ER;      
  initial begin
    reset();
    length = s.len();
    $display("%d",length);
    strtoascii(length,s);
    ER = new();
    
    if(length%2 == 0) 
      Evenlen(length, msg);
    else 
      Oddlen(length, msg);    
  end
endmodule