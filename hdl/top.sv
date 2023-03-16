module top();
  logic [15:0] dataIn, CrcOut, dataOut;
  bit clk = 1'b1;
  logic rst, crcValid, endOfMsg, eot;
  logic [7:0] m1, m2, ascii;
  string s = "HARSHA";
  logic [7:0] msg[$];
  int length;//, bit_flips;
  logic [31:0] error_bits;

  logic [31:0] erIn,              // input error vector for the error injuctor module
  logic endMsgIn                  // singal to indicate end of message transmission
  
  //crcgen DUT(.*);
  topInterface    TI(.*); 
  crcgen          TX(TI.transimitter);
  error_injector  EI(TI.errorInjectorV2);
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
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	        endOfMsg = '1;
	        @(negedge clk);
          break;
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
	  assert(ER.randomize());
          //bit_flips = $urandom_range(0,3);
          //Error_injection(bit_flips);
        end
      end
      /*
      if(top.DUT.clr == '1)begin
         $display("%b, %b, %b, %b, %b, %b, %b, %b", m1, m2, dataIn, dataOut, CrcOut, error_bits, eom, crcValid);
      end*/
      @(negedge clk);
    end
    $finish();
  endtask
      
  task Oddlen(input int length, input logic [7:0] msg [$]);
    forever begin
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	  endOfMsg = '1;
          @(negedge clk);
          break;
	end
        else if(msg.size() == 1)begin
          m1 = msg.pop_front();
          m2 = 8'b0;
          dataIn = {m1,m2};
          //bit_flips = $urandom_range(0,3);
          //Error_injection(bit_flips);
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          dataIn = {m1,m2};
          //bit_flips = $urandom_range(0,3);
          //Error_injection(bit_flips);
        end
      end/*
      if(top.DUT.clr == '1)begin
         $display("%b, %b, %b, %b, %b, %b, %b, %b", m1, m2, dataIn, dataOut, CrcOut, error_bits, eom, crcValid);
      end*/
      @(negedge clk);
    end
    $finish();
  endtask
          
  task Error_injection(input int bit_flips);
    bit [31:0] error_out;
    error_out = '0;
    for(int j = 0; j < bit_flips; j++) begin
      error_out[$urandom_range(0,31)] = 1'b1;
    end
    error_bits = error_out;
  endtask

  class Error_ratio;
    rand int bit_flips;
    constraint c_flips {
      bit_flips dist {0 := 50, [1:2] := 40, [3:6] := 10};}
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

    forever begin
      if(~(TI.busy)) begin
        if(msg.size() == 0)
          break;
        else begin
          assert(ER.randomize()) $info("random error success %d",ER.bit_flips);
          Error_injection(ER.bit_flips);
        end
      end
    end
    
  end
endmodule