////////////////////////////////////////////////////////////////////////////////////////////////
// interface.sv - Interface to connect all the modules in the CRC error Detction and correction
//                project                    
//
// Author           : Abhijeet Prem  (abhij@pdx.edu)
// Last modified    : 15th Mar 2023
//
// Description:
//  * Aninterface to encapsulate all the singnals from the top module
//  * Three modports
//          - one for the Transmitter
//          - one for the Error Injector
//          - one for the Receiver
//
////////////////////////////////////////////////////////////////////////////////////////////////


interface   topInterface(                   // <-- ports that interfaces with the top module
    input   logic clk,                      // master clock signal
    input   logic rst,                      // master rest signal
    input   logic erLoad,                   // control signal to load error vector (uncomment if needed)
    input   logic [15:0] dataIn,            // input data to the tx block from top
    input   logic [31:0] erIn,              // input error vector for the error injuctor module
    input   logic endMsgIn                  // singal to indicate end of message transmission
    );

    // internal ports for the interface
    tri             CWValid;                // signal to indicate that codeword is valid
    tri     [15:0]  dataOut;                // output data from the receiver block
    wire            dOutValid;              // contol signal to indicate valid date on the d_out line   
    wire            erFree, endMsgOut;      // signal to indicate if the data is error free or not, end of message
    tri     [31:0]  CW, erCW;               // ports to interface 


////////// Modport for the transmitter module ////////////////////////////////////////////////////
// 
//  Port definitions:
//      
//      clk     -> Master clock signal
//      rst     -> Master reset signal
//      dataIn  -> Incoming data from the top module to the transmitter block   
//      cwValid -> Indicates when the code word is valid
//      cw      -> Is the codeword output from the transimitter block
//      busy    -> bBsy signal to indicate if the transmitter block is busy or not
//
///////////////////////////////////////////////////////////////////////////////////////////////////

    modport transmitter (
        input clk, rst, dataIn, endOfMsg             
        output CWValid, CW, busy 
        );          

//////////  Modport for the error injector module V1 ///////////////////////////////////////////////
// 
//  Port definitions:
//      
//      rst     -> Master reset signal
//      erIn    -> Incoming error vector from the top module   
//      cw      -> Is the codeword output from the transimitter block
//      erCw    -> codeword injucted with error
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
    
    modport errorInjectorV1 (
        input   rst, erIn, CW,
        input   erLoad          // uncommet if need to be used  
        output  erCW
        );

//////////  Modport for the error injector module V2 ///////////////////////////////////////////////
// 
//  Description: This modport is for interfacing with the injuctor module without memeory element 
//              in it to store the error in it. It directly take the error vector from the testbench 
//              and selectively adds to the codeword. Hence no reset signal is also needed.
// 
//  Port definitions:
//    
//      erIn    -> Incoming error vector from the top module   
//      cw      -> Is the codeword output from the transimitter block
//      erCw    -> codeword injucted with error
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
    
    modport errorInjectorV2 (
        input   erIn, CW,
        output  erCW
        );

//////////  Modport for the receiver module ////////////////////////////////////////////////////
// 
//  Port definitions:
//      
//      clk         -> Master clock signal
//      rst         -> Master reset signal
//      erCW        -> Incoming codeword with error in it 
//      CWValid     -> signal to indicate that the codeword is valid
//      dOutValid   -> Indicate that the ouput data is valid
//      erFree      -> Indicate that data is error free or not
//      endMsgOut   -> Indicate end of message transmission
//      dOut        -> data out after attmepting to correct the error
//
///////////////////////////////////////////////////////////////////////////////////////////////////

    modport receiver(
        input clk, rst, erCW, CWValid,
        output dOutValid, erFree, endMsgOut, dOut
        );

endinterface