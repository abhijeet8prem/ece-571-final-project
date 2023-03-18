////////////////////////////////////////////////////////////////////////////////////////////
// ec-controller.sv - error corretion control unit for the error correction unit                   
//
// Author           : Abhijeet Prem  (abhij@pdx.edu)
// Last modified    : 18th Mar 2023
//
// Description:
//   
//
/////////////////////////////////////////////////////////////////////////////////////////////


module ecController(
    input   logic           clk,                    // master clock signal
    input   logic           rst,                    // master reset signal
    input   logic           en,                     // signal to enable the controller
    input   logic [2:0]     hits,                   // signals indicating if there is a match in the error correction vector
    input   logic [1:0]     crcValid,               // signals indicating if the CRC output is valid or not
    input   logic [1:0]     busyIn,                 // incoming busy signals from the CRC generator modules  [busy1, busy2]
    input   logic [15:0]    CRC1,CRC2,CRC3          // the CRC values afgter verify if the error is corrected or not 
    output  logic [2:0]     load,                   // load signal for the flip-flops [load2, load1 ,load_cw]
    output  logic [1:0]     sel,                    // select signals for the ouput mux
    output  logic           DOutValid               // signal to indicate that the output is valid
    output  logic           er_stat                 // indicates if the error is corrected or not
    output  logic           set_busy                // singal to enable the busy state
    output  logic           clr_busy                // signal to clear the busy state
    output  logic           crt_en                  // signal to enable the error correction unit
    );

    enum logic [1:0] {  IDLE,            
                        LOAD_CW,         
                        CORRECT_ERROR,   
                        VERIFY_ERROR} State, NextState;
    
    always_ff @( posedge clk ) begin
      if(rst)     State <= NORMAL;
      else        State <= NextState;   
   end

    always_comb begin : set_next_state

        NextState = State;   // the default for each cases below

        unique case (State)
            
            IDLE:                                       
                if(en)                                  
                    NextState   = LOAD_CW;               
            
            LOAD_CW:      
                    NextState   = CORRECT_ERROR;
            
            CORRECT_ERROR:
                if (!(hits) | !(CRC1))
                    NextState  = IDLE;
                else
                    NextState  = VERIFY_ERROR;
            
            VERIFY_ERROR:
                if(crcValid)      
                    NextState   = IDLE;      

        endcase    
    end: set_next_state


    always_comb begin : Set_outputs

        {load, sel, DOutValid, er_stat, set_busy, clr_busy,crt_en} = '0;

        unique case(State)    
            
            IDLE:                              // When in inital state
                begin
                clr_busy = '1;
                end
            
            LOAD_CW:      
                begin
                load[0] = '1;
                set_busy = '1;
                ctr_en = '1;   
                end
            
            CORRECT_ERROR:
                begin
                if(!(hits) & CRC1) begin
                    DOutValid = '1;
                    er_stat = '1;
                end
                else if(!(hits) & !(CRC1)) begin
                    DOutValid = '1;
                end 

                else if(hits === 3'd1 | hits === 3'd2  ) begin
                    load = 3'b010;
                end
                
                else if(hits === 3'd4) begin
                    load = 3'b110;
                end
                end               
            
            VERIFY_ERROR:
                begin
                if(!(CRC2) & !(crcValid[0])) begin
                    sel = 2'b01;
                    DOutValid = '1;
                end
                if(!(CRC3) & !(crcValid[1])) begin
                    sel = 2'b10;
                    DOutValid = '1;
                end

                end
                 
                                    
        endcase
    end: Set_outputs

endmodule