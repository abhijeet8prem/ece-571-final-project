class Error_ratio;
    rand logic  [31:0] erIn;
    constraint c_flips {$countones(erIn) dist {1:=40, 2:=40, 3:=20};}
endclass


module top();
  
  parameter file = "input-message.txt";
  
  bit clk = 1'b1;
  logic rst;// dataValid;
  logic [7:0] m1, m2, ascii;
  string fileContents;    // String variable to store the input message
  logic [7:0] msg[$];
  logic [15:0] receivedOut[$];
  int length;            // input error vector for the error injuctor module

  
  Error_ratio ER = new();       // creating the object for the error class

  topInterface    TI(.*); 
  crcTxPort       TX(TI.transmitter);
  errorInj        EI(TI.errorInjector);
  rx_wrapper      RX(TI.receiver);

  
  
  // Initial block to perform file handeling
  initial begin
      // Open the file
      automatic int file_handle = $fopen(file, "r");
      automatic byte data;
      if (file_handle == 0) begin
        $display("Error opening file %s", file);
        $finish;
      end
      // Read the file contents into the string variable   
      while (!$feof(file_handle)) begin
        $fread(data, file_handle);
        fileContents = {fileContents, $sformatf("%c", data)};
      end
      // Close the file
      $fclose(file_handle);
    end

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
      TI.dataValid = '0;
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	   TI.endMsgIn = '1;
	   @(negedge clk);
          break;
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          TI.dataIn = {m1,m2};
          TI.dataValid = '1;
	  assert(ER.randomize());
          TI.erIn = ER.erIn;
        end
      end
      @(negedge clk);
    end
    repeat(100)@(negedge clk);
    $finish();
  endtask

  task Oddlen(input int length, input logic [7:0] msg [$]);
    forever begin
      TI.dataValid = '0;
      if(~(TI.busy)) begin
        if(msg.size() == 0)begin
	  TI.endMsgIn = '1;
          @(negedge clk);
          break;
	end
        else if(msg.size() == 1)begin
          m1 = msg.pop_front();
          m2 = 8'b0;
          TI.dataIn = {m1,m2};
          TI.dataValid = '1;
	  assert(ER.randomize());
          TI.erIn = ER.erIn;
        end
        else begin
          m1 = msg.pop_front();
          m2 = msg.pop_front();
          TI.dataIn = {m1,m2};
          TI.dataValid = '1;
	  assert(ER.randomize() );
          TI.erIn = ER.erIn;
        end
      end
      @(negedge clk);
    end
    $finish();
  endtask

  initial begin
    reset();
    length = fileContents.len();
    $display("%d",length);
    strtoascii(length,fileContents);
      
    if(length%2 == 0) 
      Evenlen(length, msg);
    else 
      Oddlen(length, msg);    
  end

endmodule