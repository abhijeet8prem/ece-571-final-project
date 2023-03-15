////////////////////////////////////////////////////////////////////////////////////////////////
// interface.sv - Interface to connect all the modules in the CRC error Detction and correction
//                project                    
//
// Author           : Abhijeet Prem  (abhij@pdx.edu)
// Last modified    : 14th Mar 2023
//
// Description:
//  * Aninterface to encapsulate all the singnals from the top module
//  * Three modports
//          - one for the Transmitter
//          - one for the Error Injector
//          - one for the Receiver
//
////////////////////////////////////////////////////////////////////////////////////////////////


interface   MainBus(                        // <-- ports that interfaces with the top module
    input   logic clk,                      // master clock signal
    input   logic rst,                      // master rest signal
    input   logic d_in_valid,               // singal to indicate that the input data is valid
    input   logic er_load,                  // control signal to load error vector 
    input   logic [15:0] d_in,              // input data to the tx block from top
    input   logic [31:0] er_in,             // input error vector for the error injuctor module
    output  tri   [15:0] d_out,             // output data from the receiver block
    output  logic d_out_valid,              // contol signal to indicate valid date on the d_out line   
    output  logic er_freeN,                 // signal to indicate if the data is error free or not
    output  logic msg_done                  // singal to indicate end of transmission
    );

    // internal ports for the interface
    tri  cw_valid;                          // signal to indicate that codeword is valid
    tri [15:0] cw_d, er_cw_d;
    tri [15:0] cw_crc, er_cw_crc;

    // modeport for the transmitter module

//### CHECK WITH HARSH WHAT OTHER SINGLAS ARE NEEDED! ######
    modport transmitter(
        input clk, rst, d_in_valid, d_in,
        output cw_valid, cw_d, er_cw_d
        );

    // modport for the error injector module
    modport errorInjector (
        input   rst, er_load, er_in, cw_d, cw_crc,
        output  er_cw_d, er_cw_crc
        );

    // modport for the receiver module
    modport receiver(
        input clk, rst, er_cw_d, er_cw_crc, cw_valid,
        output d_out_valid, er_freeN, msg_done, d_out
        );

endinterface