////////////////////////////////////////////////////////////////////////////////////////////////
// topInterface.sv - Interface to connect all the modules in the CRC error Detection and correction
//                project                    
//
// Last modified    : 24th Mar 2023
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
    input   logic rst                      // master rest signal  
    );

    // internal ports for the interface
    logic             dataValid;         // control signal to load error vector (uncomment if needed)
    logic     [15:0]  dataIn;            // input data to the tx block from top
    logic     [31:0]  erIn;              // input error vector for the error injuctor module
    logic             endMsgIn;                  // singal to indicate end of message transmission
    logic             CWValid;                // signal to indicate that codeword is valid
    logic             erCWValid;	      // signal to indicate that error codeword is valid                
    logic             dOutValid;              // contol signal to indicate valid date on the d_out line   
    logic             erFree, endMsgOut;      // signal to indicate if the data is error free or not, end of message
    logic     [31:0]  CW, erCW;               // ports to interface 
    logic     [15:0]  dOut;                     // output data from the receiver block
    logic             Txbusy, Rxbusy;

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
        input clk, rst, dataIn, dataValid,          
        output CWValid, CW, Txbusy 
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
    
    modport errorInjector (
        input   erIn, CW, CWValid,
        output  erCW, erCWValid
        );

//////////  Modport for the receiver module ////////////////////////////////////////////////////
// 
//  Port definitions:
//      
//      clk         -> Master clock signal
//      rst         -> Master reset signal
//      erCW        -> Incoming codeword with error in it 
//      CWValid     -> signal to indicate that the codeword is valid
//      dOutValid   -> Indicate that the output data is valid
//      erFree      -> Indicate that data is error free or not
//      endMsgOut   -> Indicate end of message transmission
//      dOut        -> data out after attmepting to correct the error
//
///////////////////////////////////////////////////////////////////////////////////////////////////

    modport receiver(
        input clk, rst, erCWValid, erCW, endMsgIn,
        output Rxbusy, dOutValid, erFree, endMsgOut, dOut);

endinterface