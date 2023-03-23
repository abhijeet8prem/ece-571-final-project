class Error_ratio;
    rand logic  [31:0] erIn;
    constraint c_flips {$countones(erIn) dist {1:=40, 2:=40, 3:=20};}
endclass


module top();
  
  parameter file = "input-message.txt";
  parameter o_file = "out_file.txt";
  int input_file, output_file;
  bit clk = 1'b1;
  logic rst;
  logic [7:0] m1, m2;


  //logic [15:0] receivedOut[$];
  
// instantiate all the modules
  
  Error_ratio ER = new();       // creating the object for the error class
  topInterface    TI(.*); 
  crcTxPort       TX(TI.transmitter);
  errorInj        EI(TI.errorInjector);
  rx_wrapper      RX(TI.receiver);

  

// clock generator 
  initial begin
    forever #5 clk = ~clk;
  end

// check for error in opening file
  initial
  begin
  input_file = $fopen(file, "r");
  output_file = $fopen(o_file,"w");  
  if (input_file == 0) 
  begin
      $display("Error: opening input file %s", file);
      $finish;
  end
  end

// task to reset the system
  task reset();
    begin
      rst = '1;
      @(negedge clk);
      rst = '0;
    end
  endtask
  
  // Task to read a file and send the message to the port

  task run(); 
    
    forever begin

    // trnasmittor side  
    TI.dataValid = '0;                  // setting that data is not valid
    TI.endMsgIn = '0;                   // setting to default value
            
    if(~(TI.busy))                      // checking if the TX is busy
    begin
      m1 = $fgetc(input_file);          // extracting the first character                               
      if(m1 == 8'hff)                   // check if the end of file is reached
      begin                             
        TI.endMsgIn = '1;               // assert end of transmission
        @(negedge clk);
        break;                          // exit forever TX loop
      end
      else                              // if end of file is not reached
      begin
        m2 = $fgetc(input_file);        // reading second character
        if(m2 == 8'hff)                 // checking if its the end of file
        begin                           // if true, end the transmission,
          TI.dataIn = {m1,m2};          // appeinding both char together and asserting it
                                        // dataIn port
          TI.dataValid = '1;            
          TI.endMsgIn = '1;
          assert(ER.randomize());       // generating random error
          TI.erIn = ER.erIn;            // 
          @(negedge clk);
          break;
        end
        else
        begin 
          TI.dataIn = {m1,m2};
          TI.dataValid = '1;
          assert(ER.randomize());
          TI.erIn = ER.erIn;
        end      
      end
    end
	
  // receiver side  
	if(TI.dOutValid)                      // checking if valid codeword present
    begin         
      $monitor("in TI.dOutValid:%d MSG: %c%c \n",TI.dOutValid, TI.dOut[15:8],TI.dOut[7:0]);     
      if(TI.endMsgOut)                   // check if the end of file is reached
      begin
        $fwrite(output_file,"%c%c",TI.dOut[15:8],TI.dOut[7:0]);                                 
        @(negedge clk);
        $fclose(output_file);             // close the file 
                                          // exit forever TX loop
      end
      else                              // if end of file is not reached
      begin
       $fwrite(output_file,"%c%c",TI.dOut[15:8],TI.dOut[7:0]);
      end
    end

    @(negedge clk);  
    end
    repeat(100)@(negedge clk);
    $fclose(input_file);             // close the file
    $finish();                       
  endtask

  
  initial begin
    reset();
    run();
      
  end

endmodule