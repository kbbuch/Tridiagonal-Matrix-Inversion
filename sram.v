/*module************************************
*
* NAME:  sram_1R1W
*
* DESCRIPTION:   
*	Output Buffer: 64*32bits, 2 Ports: 1R+1W
*  
* REVISION HISTORY
*   Date     Programmer    Description
*   2/4/13   Wenxu Zhao    Version 1.0
*  10/12/15 Bowen Li         Version 2.0
*  08/22/16 Teddy Nigussie   Version 3.0
*M*/

module SRAM_1R1W (clock, WE, WriteAddress, ReadAddress, WriteBus, ReadBus);
input  clock, WE; 
input  [6:0] WriteAddress, ReadAddress; // Change as you change size of SRAM
input  [31:0] WriteBus;
output [31:0] ReadBus;


reg [31:0] Register [0:127];   // 128 words, with each 32 bits wide
reg [31:0] ReadBus;

// provide one write enable line per register
reg [127:0] WElines;
integer i;

// Write '1' into write enable line for selected register
// Note the 4 ns delay - THIS IS THE INPUT DELAY FOR THE MEMORY FOR SYNTHESIS
always@(*)
#4 WElines = (WE << WriteAddress);

always@(posedge clock)
    for (i=0; i<=127; i=i+1)
    if (WElines[i]) Register[i] <= WriteBus;

// Note the 4 ns delay - this is the OUTPUT DELAY FOR THE MEMORY FOR SYNTHESIS
always@(*) 
  begin 
    #4 ReadBus  =  Register[ReadAddress];
  end
endmodule
