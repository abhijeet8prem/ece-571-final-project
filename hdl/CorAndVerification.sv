////////////////////////////////////////////////////////////////////////////////////////////////
// CorandVerification.sv - (Correction and Verification)Module to Correct and verify Whether all possible 1 and 2 bit errors are corrected                   
//
// Last modified    : 24th Mar 2023
//
// Description:
//  * Error Correction modules corrects all possible 1 and 2 bit errors and verify the ouputs.
//  * It also reports if there are more than 2 bit errors, which cannot be corrected.
//  
////////////////////////////////////////////////////////////////////////////////////////////////

module ErrorCorrection(input clk, rst, RemValid, [31:0] erCW, [15:0] Rem, output dOutValid, erFree, [15:0] dOut);
  logic [15:0] RemOut1, RemOut2; 	//Remainder outputs generated after correction
  logic [31:0] CorCW1, CorCW2;  	//Corrected codewords
  logic [31:0] CorOut1, CorOut2;	//Corrected outputs after verification
  logic [31:0] Q1, Q2;
  logic [2:0]  hits;
  logic [1:0]  sel;
  logic [1:0]  enable;
  logic        en1, en2, load;
  logic        RemValid1, RemValid2;	//Valid signals from verification blocks
  logic        busy, er_status;
  
  //Correction Module corrects the Corrupted data based on the Remainder pattern
  Correction   CR(erCW, Rem, crt_en, isZero, hits, CorCW1, CorCW2);

  //crcCheck Modules to verify whether the output has been corrected
  ErrorCheck   C1(clk, rst, en1, Q1, RemValid1, RemOut1, CorOut1); 
  ErrorCheck   C2(clk, rst, en2, Q2, RemValid2, RemOut2, CorOut2);

  //Multiplexer is used to connect the corresponding corrected Codeword to the output
  Mux3x1       M1(erCW[31:16], CorOut1[31:16], CorOut2[31:16], sel, dOut);

  //Flipflop to indicate the busy state of the correction module
  JKFF         JK(clk, set_busy, clr_busy, busy);

  //Controller to control all the Correction and Error check modules
  ecController eC(clk, rst, RemValid, hits, RemValid1, RemValid2, Rem, RemOut1, RemOut2, load, enable, sel, dOutValid, er_status, set_busy, clr_busy, crt_en);

  always_latch
    if(load) Q1 = CorCW1;
  
  always_latch
    if(load) Q2 = CorCW2;

  assign {en1,en2} = enable;/*
  always_comb
    if(enable == 2'b10)begin
      en1 = '1;
      en2 = '0;
    end else if(enable == 2'b11)begin
      en1 = '1;
      en2 = '1;
    end else begin
      en1 = '0;
      en2 = '0;
    end*/
  
  assign erFree = ~er_status;

endmodule

module Mux3x1(d2, d1, d0, select, dOut);
  input [15:0] d2, d1, d0;
  input [1:0]  select;
  output logic [15:0] dOut;

  always_comb
    begin
      unique case(select)
        2'b01 : dOut = d2;
        2'b10 : dOut = d1;
        2'b11 : dOut = d0;
        2'b00 : dOut = 'z;
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
          q <= '1;
      else if ({j,k} == 2'b01)
          q <= '0;
      end
endmodule


module ecController(
    input   logic           clk,                    // master clock signal
    input   logic           rst,                    // master reset signal
    input   logic           en,                     // signal to enable the controller
    input   logic [2:0]     hits,                   // signals indicating if there is a match in the error correction vector
    input   logic           RemValid1,              // signals indicating if the CRC output is valid or not
    input   logic           RemValid2,              // signals indicating if the CRC output is valid or not
    input   logic [15:0]    CRC1,CRC2,CRC3,         // the CRC values afgter verify if the error is corrected or not 
    output  logic           load,                   // load signal for the flip-flops [load2, load1 ,load_cw]
    output  logic [1:0]     enable,
    output  logic [1:0]     sel,                    // select signals for the ouput mux
    output  logic           dOutValid ,             // signal to indicate that the output is valid
    output  logic           er_status,              // indicates if the error is corrected or not
    output  logic           set_busy,               // singal to enable the busy state
    output  logic           clr_busy,               // signal to clear the busy state
    output  logic           crt_en                  // signal to enable the error correction unit
    );

    enum logic [1:0] {  IDLE,            
                        LOAD_CW,         
                        CORRECT_ERROR,   
                        VERIFY_OUTPUT} State, NextState;
    
  always_ff @( posedge clk ) begin
    if(rst)     State <= IDLE;
    else        State <= NextState;   
  end

  always_comb begin : set_next_state
    NextState = State;   
    unique case (State)
      IDLE:begin
            if(en)   
              NextState = LOAD_CW;  
          end                          
      LOAD_CW: begin
            NextState = CORRECT_ERROR; 
          end         
      CORRECT_ERROR:begin
            if (!(hits) | !(|CRC1))
              NextState  = IDLE;
            else
              NextState  = VERIFY_OUTPUT; 
          end
      VERIFY_OUTPUT:begin
            if(RemValid1 | RemValid2)      
                NextState   = IDLE; 
          end   
        endcase
  end: set_next_state


  always_comb begin : Set_outputs
    {load, enable, sel, dOutValid, er_status, set_busy, clr_busy, crt_en} = '0;
    unique case(State)        
            IDLE:                              
                begin
                clr_busy = '1;
                end           
            LOAD_CW:      
                begin
                load = '1;
                set_busy = '1;
                crt_en = '1;   
                end           
            CORRECT_ERROR:
                begin
                if(!(hits) & (|CRC1)) begin
                    dOutValid = '1;
                    er_status = '1;
		    sel = 2'b01;
                end
                else if(!(hits) & !(|CRC1)) begin
                    dOutValid = '1;
		    sel = 2'b01;
                end 
                else if((hits === 3'b100) | (hits === 3'b010)) begin
                    enable = 2'b10;
                end
                else if(hits === 3'b001) begin
                    enable = 2'b11;
                end
                end                          
            VERIFY_OUTPUT:
                begin
                if(!(|CRC2) & (RemValid1)) begin
                    sel = 2'b10;
                    dOutValid = '1;
                end
                else if(!(|CRC3) & (RemValid2)) begin
                    sel = 2'b11;
                    dOutValid = '1;
                end
                end                                   
        endcase
        
    end: Set_outputs

endmodule