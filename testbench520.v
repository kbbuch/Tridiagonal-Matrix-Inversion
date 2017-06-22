module test_fixture;
reg  clock = 0; // Single clock for entire design
reg  reset = 1; // Global reset signal – active low
reg  go = 0; // tells DUT to start.  Active high for one cycle
wire finished;  // comes from DUT – goes high for one cycle when finished
reg  ended; // internal finished flag
wire overflow; // comes from DUT  Goes high if an overflow occurs.
wire [31:0] readbus; // input port of module being tested
wire [31:0] writebus;	
wire [6:0] readAddress;
wire [6:0] writeAddress;	
integer cycle_counts = 0; // counts the number of clock cycles to finish
integer	overflow_counts = 0;		
integer i=0;			
parameter clock_period = 10;
	
	
initial	//following block executed only once
   begin
	
	cycle_counts = 0;//initialize cicle count as zero
	ended = 0;
	
        $readmemh("validation_input2.txt", m1.Register); // load  T matrix or any other input values into SRAM

        #(clock_period*2+clock_period/2+1) reset = 0;  // send reset low for one cycle
        #(clock_period) reset = 1;
        #(clock_period*3) go = 1;    // send go high for one cycle
        #(clock_period) go = 0;
		
	wait (ended)// wait til finished flag high

       $writememh("output_hex.txt", m1.Register,28,127); //output the stored result values into "output_hex.txt file
       $display ("Total Cycle Count : %d", cycle_counts);
       $display ("Total Overflow Count : %d", overflow_counts);		
		
   end

//Clock
always  #(clock_period/2) clock = ~clock;

//Count Clock Cycle
always @(posedge clock)
begin
	cycle_counts = cycle_counts + 1;
end

	
always @(*)begin
	if(DUT.finished) 
        begin
		#(clock_period)
		ended <= 1;
	end
end

//Count overflow
always @(posedge clock)begin
	if(DUT.overflow) 
        begin
		overflow_counts = overflow_counts+1;
	end
end


// instantiate and connect your design...Note:  your synthesis clock can be faster but there is no need
 MyDesign DUT(.clock(clock), .reset(reset),.go(go),.rdAddress(readAddress),.wrAddress(writeAddress),.WE(WE),.readbus(readbus),.writebus(writebus),.overflow(overflow),.finished(finished));
		 	 
// instantiate and connect memory... do not synthesize the memory
 SRAM_1R1W m1 (.clock(clock),.ReadAddress(readAddress),.WriteAddress(writeAddress),.WE(WE),.ReadBus(readbus),.WriteBus(writebus) );

	
endmodule  /*test_fixture*/
