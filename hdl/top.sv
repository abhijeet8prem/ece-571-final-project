class Errors;

  rand bit [31:0] bit_flips;  
  constraint c_Errors { bit_flips dist {0 := 10, 1 := 40, 2 := 40, 3 := 10};}

endclass


module top();
  
  parameter file = "input-message.txt";
  parameter o_file = "out_file.txt";
  bit clk = 1'b1;
  logic rst;
  logic [7:0] m1, m2;
  int Passcount, Failcount, UnCorErr;  //UnCorrErr : count of 3 or more bit errors that cannot be corrected
  int input_file, output_file;
  logic [31:0] erIn;

  

  Errors ER = new();       // creating the object for the error class
  
  //instantiating all the modules
  topInterface    TI(.*); 
  CrcGen          TX(TI.transmitter);
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

  
  //task to genearte Error input
  task Error_injection(input int bit_flips);
    bit [31:0] error_out;
    error_out = '0;
    for(int j = 0; j < bit_flips; j++) begin
      error_out[$urandom_range(0,31)] = 1'b1;
    end
    if(bit_flips >= 3)
      UnCorErr++;
    erIn = error_out;
    //$display("%b", erIn);
  endtask
  
  
  // Task to read a file and send and receive messages
  task run(); 
    forever begin
      TI.dataValid = '0;                     // setting that data is not valid
      TI.endMsgIn = '0;                      // setting to default value

      // Message transmission based on transmitter busy 
      if(~(TI.Txbusy))                      
       begin
         m1 = $fgetc(input_file);            // extracting the first character     
 
         if(m1 == 8'hff)                     // checking end of file
          begin                             
            TI.endMsgIn = '1;                // assert end of transmission
          end else                           // if end of file is not reached
          begin
            m2 = $fgetc(input_file);         // reading second character

            if(m2 == 8'hff)                  // checking end of file
            begin                            
              TI.dataIn = {m1,m2};           // appending both char together and transmitting it
              TI.dataValid = '1;            
              TI.endMsgIn = '1;
              assert(ER.randomize());        // generating random error
              Error_injection(ER.bit_flips);
              TI.erIn = erIn;           
            end else
            begin 
              TI.dataIn = {m1,m2};
              TI.dataValid = '1;
              assert(ER.randomize());
              Error_injection(ER.bit_flips);
              TI.erIn = erIn;
            end
          end
       end
      
	
      // Message receiver based on Data output valid  
      if(TI.dOutValid)                    
        begin         

          if(~TI.endMsgOut && TI.erFree)                   // check if the end of message is reached
            begin 
              $fwrite(output_file,"%c%c",TI.dOut[15:8],TI.dOut[7:0]);     
	          Passcount++;                            
            end else if (~TI.endMsgOut && ~TI.erFree)                           
            begin
              $fwrite(output_file,"%c%c",42,42);
              Failcount++;
            end
         end
      @(negedge clk);
      if(TI.endMsgOut)
        break;
  
    end
    if(UnCorErr == Failcount)
      $display("Error detection and Correction is Successful");
    else 
      $display("Error detection and Correction failed");
    $fclose(input_file);      
    $finish();                       
  endtask

  
  initial begin
    reset();
    run();
 
  end

endmodule