module ErrorCorrection(input clk, rst, CrcRemValid, [31:0] erCW, [15:0] CrcRem, output dOutValid, er_status, [15:0] dOut);
  reg   [31:0] erIn;
  logic [15:0] CRC1, CRC2, CRC3;
  logic [31:0] dataOut1, dataOut2, m;
  logic [31:0] Q1, Q2;
  logic        en1, en2, erCWValid, crcValid1, crcValid2, valid;
  logic [2:0]  hits, load;
  logic [1:0]  sel;
  logic [1:0]  crcValid;
  logic [31:0] dOut1, dOut2;
  logic        busyIn;
  
  Correction   CR(erIn, CRC1, crt_en, isZero, hits, dataOut1, dataOut2);
  crcCheck     C1(clk, rst, en1, Q1, crcValid1, CRC2, dOut1); 
  crcCheck     C2(clk, rst, en2, Q2, crcValid2, CRC3, dOut2);
  Mux4x1       M1(erIn[31:16], dOut1[31:16], dOut2[31:16], sel, dOut);
  JKFF         JK(clk, set_busy, clr_busy, busy);
  ecController eC(clk, rst, valid, hits, crcValid, busyIn, CRC1, CRC2, CRC3, load, sel, dOutValid, er_status, set_busy, clr_busy, crt_en);

  always_latch
    if(CrcRemValid) m = erCW[31:0];
    
  always_latch
    if(~busy) erIn = m;

  always_latch
    if(CrcRemValid) valid = CrcRemValid;

  always_latch
    if(load == 3'b001) CRC1 = CrcRem;

  always_latch
    if(load == 3'b001) Q1 = dataOut1;
  
  always_latch
    if(load == 3'b001) Q2= dataOut2;

  always_comb
    if(load == 3'b010)begin
      en1 = '1;
    end else if(load == 3'b110)begin
      en1 = '1;
      en2 = '1;
    end else begin
      en1 = '0;
      en2 = '0;
    end
  
  assign crcValid = {crcValid2,crcValid1};
  assign busyIn = {ErrorCorrection.C1.busy};

endmodule

module Mux4x1(d2, d1, d0, select, dOut);
  input [15:0] d2, d1, d0;
  input [1:0]  select;
  output logic [15:0] dOut;

  always_comb
    begin
      unique case(select)
        2'b01 : dOut = d2;
        2'b10 : dOut = d1;
        2'b11 : dOut = d0;
        default: dOut = 'z;
      endcase
    end

endmodule

module JKFF(clk, j, k, q);
  input clk;
  input j, k;
  output q;

  reg q;

  always_ff @(posedge clk)
      begin
      if ({j,k} == 2'b11)
          q <= ~q;
      else if ({j,k} == 2'b10)
          q <= 1;
      else if ({j,k} == 2'b01)
          q <= '0;
      end
endmodule


module ecController(
    input   logic           clk,                    // master clock signal
    input   logic           rst,                    // master reset signal
    input   logic           en,                     // signal to enable the controller
    input   logic [2:0]     hits,                   // signals indicating if there is a match in the error correction vector
    input   logic [1:0]     crcValid,               // signals indicating if the CRC output is valid or not
    input   logic           busyIn,                 // incoming busy signals from the CRC generator modules  [busy1, busy2]
    input   logic [15:0]    CRC1,CRC2,CRC3,         // the CRC values afgter verify if the error is corrected or not 
    output  logic [2:0]     load,                   // load signal for the flip-flops [load2, load1 ,load_cw]
    output  logic [1:0]     sel,                    // select signals for the ouput mux
    output  logic           dOutValid ,              // signal to indicate that the output is valid
    output  logic           er_status,                 // indicates if the error is corrected or not
    output  logic           set_busy,                // singal to enable the busy state
    output  logic           clr_busy,                // signal to clear the busy state
    output  logic           crt_en                 // signal to enable the error correction unit
    );

    enum logic [1:0] {  IDLE,            
                        LOAD_CW,         
                        CORRECT_ERROR,   
                        VERIFY_ERROR} State, NextState;
    
  always_ff @( posedge clk ) begin
    if(rst)     State <= IDLE;
    else        State <= NextState;   
  end

  always_comb begin : set_next_state
    NextState = State;   
    unique case (State)
      IDLE:begin
            if(en && (!busyIn))   
              NextState = LOAD_CW;  
          end                          
      LOAD_CW: begin
            NextState = CORRECT_ERROR; 
          end         
      CORRECT_ERROR:begin
            if (!(hits) | !(CRC1))
              NextState  = IDLE;
            else
              NextState  = VERIFY_ERROR; 
          end
      VERIFY_ERROR:begin
            if(crcValid)      
                NextState   = IDLE; 
          end   
        endcase
  end: set_next_state


  always_comb begin : Set_outputs
    {load, sel, dOutValid, er_status, set_busy, clr_busy, crt_en} = '0;
    unique case(State)        
            IDLE:                              
                begin
                clr_busy = '1;
                end           
            LOAD_CW:      
                begin
                load = 3'b001;
                set_busy = '1;
                crt_en = '1;   
                end           
            CORRECT_ERROR:
                begin
                if(!(hits) & !(CRC1)) begin
                    dOutValid = '1;
                    er_status = '1;
		    sel = 2'b01;
                end
                else if(!(hits) & (CRC1)) begin
                    dOutValid = '1;
		    sel = 2'b01;
                end 
                else if(hits === 3'b100 | hits === 3'b010) begin
                    load = 3'b010;
                end
                else if(hits === 3'b001) begin
                    load = 3'b110;
                end
                end                          
            VERIFY_ERROR:
                begin
                if(!(CRC2) & (crcValid == 1)) begin
                    sel = 2'b10;
                    dOutValid = '1;
                end
                if(!(CRC3) & (crcValid == 2)) begin
                    sel = 2'b11;
                    dOutValid = '1;
                end
                end                                   
        endcase
        
    end: Set_outputs

endmodule