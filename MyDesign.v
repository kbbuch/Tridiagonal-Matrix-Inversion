
`include "div_pipe.v" //link to designware module for Floating Point Divider

// synopsys translate_off
`include "/afs/eos.ncsu.edu/dist/synopsys2013/syn/dw/sim_ver/DW_fp_addsub.v" //link to designware module for Floating Point Add-Sub
`include "/afs/eos.ncsu.edu/dist/synopsys2013/syn/dw/sim_ver/DW_fp_mult.v" //link to designware module for Floating Point multiplier
//synopsys translate_on

`define READ_ADDRESS_START  7'b0
`define WRITE_ADDRESS_START 7'b001_1100 //28
`define COUNTER_INIT_VALUE 7'b001_1100  //Counter initialized to number of input values

module MyDesign (clock, reset,go,rdAddress, wrAddress,WE,readbus,writebus,overflow,finished);

	input 		        clock;
	input				reset; 
    input               go;
	input 	 [31:0] 	readbus;  // 32 bit bus from match memor
  	output 	 [31:0]		writebus;  //32-bit register containing the final output
	output   [6:0] 		rdAddress; // address to Match memory
	output   [6:0]		wrAddress; // write address
    output              overflow;
    output				finished;
    output              WE;
        
     
    reg  [2:0] 	inst_rnd;
   	//wire [7:0] 		status;
	reg [6:0]      	rdAddress;
	reg [6:0]		wrAddress;
	reg [31:0] 		a [9:0]; // 32bit ASCII data in
	reg [31:0] 		b [8:0]; // 32bit ASCII data in
	reg [31:0] 		c [8:0]; // 32bit ASCII data in
	reg [5:0]  		Counter; //4bit counter
	reg [8:0]		cycle;
	reg 			Enable;
	reg 			ValidDataIn;
	reg    			finished;
	reg				WE;
	
	reg [31:0]			mul_1_in1;
	reg [31:0]			mul_1_in2;
	wire [31:0]			mul_1_out;
	
	reg [31:0]			mul_2_in1;
	reg [31:0]			mul_2_in2;
	wire [31:0]			mul_2_out;
	
	reg [31:0]			div_in1;
	reg [31:0]			div_in2;
	wire [31:0]			div_out;
	
	reg [31:0]			sub_in_1;
	reg [31:0]			sub_in_2;
	wire [31:0]			sub_out;
	
	reg [31:0]			R1_mul1;
	reg [31:0]			R2_mul1;
	
	reg [31:0]			R1_mul2;
	reg [31:0]			R2_mul2;
	
	reg [31:0]			BC [6:2];
	
	reg [31:0]			theta[10:2];
	reg [31:0]			phi[9:2];
	reg [31:0]			T_out;
	
	reg [31:0]			theta_1_10;
	reg [31:0]			theta_0_10;
	wire 				go;	
    wire    		    overflow;
    wire [31:0] 		readbus;
    wire [31:0] 		writebus;
	
	wire [7:0] 			status1;
	wire [7:0] 			status2;
	wire [7:0] 			status3;
	reg	 [7:0]			status_add, status_mul1, status_mul2;
	
	wire	inst_op = 1;




parameter sig_width = 23;      // RANGE 2 TO 253
parameter exp_width = 8;       // RANGE 3 TO 31
parameter ieee_compliance = 0; // RANGE 0 TO 1


//----------------------------------------------------------
// Controller
//----------------------------------------------------------
//1. The counter counts the total number of inputs loaded into "MyDesign" 
//   Counter is initialized to 4'b1110 to indicate the number of input values 

//2. "Enable" is an internal control signal.
//    When Enable is set to "1" , read,write and division operations take place.
//       Enable is set to "1" on the next pos clock edge right after "go" signal goes to "0".
//       Enable goes  to "0"  when the counter value reaches zero. At this point "finished" flag is set to "1" 


always @(posedge clock) begin
	if(!reset) begin
		Counter <= `COUNTER_INIT_VALUE;
		finished <= 1'b0;
		Enable <= 1'b0;
	end
	else begin
		if(go) begin
			Enable <= 1'b1;
			Counter <= `COUNTER_INIT_VALUE;
			finished <= 1'b0;
		end
		else begin
			if(Counter == 4'b0000) 
			begin
				if(Counter == 4'b0000) 
				begin
				Enable <= 1'b0;
				Counter <= Counter;
				//finished <= 1'b1;              
				end
			end
			else 
			begin
				Enable <= Enable;
				Counter <= Counter - 1;
				//finished <= finished;
			end
			
			if(cycle==108)
				finished <= 1;
		end
		
	end	
end

/*always@(posedge clock)
begin
	status_mul1 <= status2;
	status_mul2 <= status3;
	status_add <= status1;
	//status_div <= status;
end*/

// Demonstration of SRAM Reading and loading registers with input values
//      SRAM Read example: 
// 	Read 32 bit FP data and save it into two 32bit internal registers, inst_a and inst_b.
//	Increase read address by 1 for each cycle.
//	ValidDataIn : '1' when read data is valid.

always@(*) 
begin
	inst_rnd =3'b0;
	
	if (!reset)
	begin
    	rdAddress = `READ_ADDRESS_START;
		ValidDataIn = 1'b0;
	end
	else
	begin
		if(Enable == 1)
		begin
			ValidDataIn = ValidDataIn;
			
			if(Counter == 28)
			begin	
				rdAddress = 7'd0;
			end
			else if(Counter == 27)
			begin	
				rdAddress = 7'd1;
			end
			else if(Counter == 26)
			begin	
				rdAddress = 7'd2;
			end
			else if(Counter == 25)
				begin
				rdAddress = 7'd3;
				end
			else if(Counter == 24)
				begin
					rdAddress = 7'd4;
				end
			else if(Counter == 23)
				begin		
					rdAddress = 7'd5;
				end
			else if(Counter == 22)
				begin		
					rdAddress = 7'd6;
				end
			else if(Counter == 21)
				begin		
					rdAddress = 7'd7;
				end
			else if(Counter == 20)
				begin		
					rdAddress = 7'd8;
				end
			else if(Counter == 19)
				begin		
					rdAddress = 7'd9;
				end
			else if(Counter == 18)
				begin		
					rdAddress = 7'd10;
				end
			else if(Counter == 17)
				begin		
					rdAddress = 7'd11;
				end
			else if(Counter == 16)
				begin		
					rdAddress = 7'd12;
				end
			else if(Counter == 15)
				begin		
					rdAddress = 7'd13;
				end
			else if(Counter == 14)
				begin		
					rdAddress = 7'd14;
				end
			else if(Counter == 13)
				begin		
					rdAddress = 7'd15;
				end
			else if(Counter == 12)
				begin		
					rdAddress = 7'd16;
				end
			else if(Counter == 11)
				begin		
					rdAddress = 7'd17;
				end
			else if(Counter == 10)
				begin		
					rdAddress = 7'd18;
				end
			else if(Counter == 9)
				begin		
					rdAddress = 7'd19;
				end
			else if(Counter == 8)
				begin		
					rdAddress = 7'd20;
					
				end
			else if(Counter == 7)
				begin		
					rdAddress = 7'd21;
				end
			else if(Counter == 6)
				begin		
					rdAddress = 7'd22;
				end
			else if(Counter == 5)
				begin		
					rdAddress = 7'd23;
					
				end
			else if(Counter == 4)
				begin		
					rdAddress = 7'd24;
				end
			else if(Counter == 3)
				begin		
					rdAddress = 7'd25;
				end
			else if(Counter == 2)
				begin		
					rdAddress = 7'd26;
					
				end
			else if(Counter == 1)
				begin		
					rdAddress = 7'd27;
					
					
				end
			else if(Counter == 0)
				begin		
					rdAddress = 7'd28;
				end
			else rdAddress = 7'bx;
		end
		else
		begin
			if(cycle == 1)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 2)
			begin
				rdAddress = 7'd21;
			end
			else if(cycle == 4)
			begin
				rdAddress = 7'd18;
			end
			else if(cycle == 9)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 13)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 15)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 18)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 22)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 23)
			begin
				rdAddress = 7'd15;
			end
			else if(cycle == 24)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 27)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 31)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 32)
			begin
				rdAddress = 7'd12;
			end
			else if(cycle == 33)
			begin
				rdAddress = 7'd14;
			end
			else if(cycle == 34)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 37)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 42)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 43)
			begin
				rdAddress = 7'd9;
			end
			else if(cycle == 44)
			begin
				rdAddress = 7'd11;
			end
			else if(cycle == 45)
			begin
				rdAddress = 7'd14;
			end
			else if(cycle == 46)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 49)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 55)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 56)
			begin
				rdAddress = 7'd6;
			end
			else if(cycle == 57)
			begin
				rdAddress = 7'd8;
			end
			else if(cycle == 58)
			begin
				rdAddress = 7'd11;
			end
			else if(cycle == 59)
			begin
				rdAddress = 7'd14;
			end
			else if(cycle == 60)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 63)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 70)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 71)
			begin
				rdAddress = 7'd3;
			end
			else if(cycle == 72)
			begin
				rdAddress = 7'd5;
			end
			else if(cycle == 73)
			begin
				rdAddress = 7'd8;
			end
			else if(cycle == 74)
			begin
				rdAddress = 7'd11;
			end
			else if(cycle == 75)
			begin
				rdAddress = 7'd14;
			end
			else if(cycle == 76)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 79)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 87)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 89)
			begin
				rdAddress = 7'd2;
			end
			else if(cycle == 90)
			begin
				rdAddress = 7'd5;
			end
			else if(cycle == 91)
			begin
				rdAddress = 7'd8;
			end
			else if(cycle == 92)
			begin
				rdAddress = 7'd11;
			end
			else if(cycle == 93)
			begin
				rdAddress = 7'd14;
			end
			else if(cycle == 94)
			begin
				rdAddress = 7'd17;
			end
			else if(cycle == 97)
			begin
				rdAddress = 7'd27;
			end
			else if(cycle == 106)
			begin
				rdAddress = 7'd27;
			end
			else rdAddress = 7'bx;
			
			ValidDataIn = ValidDataIn;
		end
	end
end

//Data In part.
always@(posedge clock) 
begin
	if (!reset)
	begin
		a[0] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 28)
		begin
			a[0]   <= readbus[31:0];
		end
		
		else
		begin
			a[0] <= a[0];
		end
	end
end

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[0] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 27)
		begin
			b[0]   <= readbus[31:0];
		end
		
		else
		begin
			b[0] <= b[0];
		end
	end
end

always@(*)
begin
		
		//inst_rnd = 0;
		
		sub_in_1 = 32'bx;
		sub_in_2 = 32'bx;
		
		mul_1_in1 = 32'bx;
		mul_1_in2 = 32'bx;
		
		mul_2_in1 = 32'bx;
		mul_2_in2 = 32'bx;
		
		div_in1 = 32'bx;
		div_in2 = 32'bx;
		
	
	if(Enable == 1 && Counter == 26)
		begin	
		
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = b[0];
		end
	else if(Enable == 1 && Counter == 25)
		begin
		
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = a[0];
		end
	else if(Enable == 1 && Counter == 24)
		begin
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = a[0];
		end
	else if(Enable == 1 && Counter == 23)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
			mul_2_in1 = readbus[31:0];
			mul_2_in2 = b[1];
		end
	else if(Enable == 1 && Counter == 22)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[2];
		end
	else if(Enable == 1 && Counter == 21)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[2];
		end
	else if(Enable == 1 && Counter == 20)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
			mul_2_in1 = readbus[31:0];
			mul_2_in2 = b[2];
		end
	else if(Enable == 1 && Counter == 19)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[3];
		end
	else if(Enable == 1 && Counter == 18)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[3];
		end
	else if(Enable == 1 && Counter == 17)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
			mul_2_in1 = readbus[31:0];
			mul_2_in2 = b[3];
		end
	else if(Enable == 1 && Counter == 16)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[4];
		end
	else if(Enable == 1 && Counter == 15)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[4];
		end
	else if(Enable == 1 && Counter == 14)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
			mul_2_in1 = readbus[31:0];
			mul_2_in2 = b[4];
		end
	else if(Enable == 1 && Counter == 13)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[5];
		end
	else if(Enable == 1 && Counter == 12)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[5];
		end
	else if(Enable == 1 && Counter == 11)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
			mul_2_in1 = readbus[31:0];
			mul_2_in2 = b[5];
		end
	else if(Enable == 1 && Counter == 10)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[6];
		end
	else if(Enable == 1 && Counter == 9)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[6];
		end
	else if(Enable == 1 && Counter == 8)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
		end
	else if(Enable == 1 && Counter == 7)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[7];
		end
	else if(Enable == 1 && Counter == 6)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[7];
		end
	else if(Enable == 1 && Counter == 5)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
		end
	else if(Enable == 1 && Counter == 4)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[8];
		end
	else if(Enable == 1 && Counter == 3)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[8];
		end
	else if(Enable == 1 && Counter == 2)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = R1_mul1;
			
		end
	else if(Enable == 1 && Counter == 1)
		begin		
			
			mul_1_in1 = readbus[31:0];
			mul_1_in2 = theta[9];
			
			mul_2_in1 = a[8];
			mul_2_in2 = readbus[31:0];
			
		end
	else if(Enable == 1 && Counter == 0)
		begin		
			sub_in_1 = R1_mul1;
			sub_in_2 = R2_mul1;
			
			mul_1_in1 = b[8];
			mul_1_in2 = c[8];
			
			mul_2_in1 = b[7];
			mul_2_in2 = c[7];
			
		end	
	else if(cycle == 1)
	begin
	
		div_in1 = theta[9];
		div_in2 = theta[10];
		
		sub_in_1 = R2_mul2;
		sub_in_2 = R1_mul1;
		
		mul_1_in1 = b[6];
		mul_1_in2 = c[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];	
	end
	else if(cycle == 2)
	begin
		
		div_in1 = theta[8];
		div_in2 = theta[10];

		mul_1_in1 = readbus[31:0];
		mul_1_in2 = phi[9];
		
	end
	else if(cycle == 3)
	begin
		div_in1 = theta[7];
		div_in2 = theta[10];

		sub_in_1 = R1_mul1;
		sub_in_2 = R2_mul2;
		
		mul_2_in1 = R2_mul1;
		mul_2_in2 = phi[9];		
		
	end
	else if(cycle == 4)
	begin
	
		div_in1 = theta[6];
		div_in2 = theta[10];
		
		mul_2_in1 = readbus[31:0];
		mul_2_in2 = phi[8];		
		
	end
	else if(cycle == 5)
	begin
		div_in1 = theta[5];
		div_in2 = theta[10];
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
	end
	else if(cycle == 6)
	begin
		div_in1 = theta[4];
		div_in2 = theta[10];
		
	end
	else if(cycle == 7)
	begin
		div_in1 = theta[3];
		div_in2 = theta[10];
		
	end
	else if(cycle == 8)
	begin
		div_in1 = theta[2];
		div_in2 = theta[10];
		
	end
	else if(cycle == 9)
	begin
		
		div_in1 = a[0];
		div_in2 = theta[10];
		
		mul_1_in1 = readbus[31:0];
		mul_1_in2 = theta[8];
		
	end
	else if(cycle == 10)
	begin	
		div_in1 = 32'b0011_1111_1000_0000_0000_0000_0000_0000;
		div_in2 = theta[10];

		mul_1_in1 = c[8];
		mul_1_in2 = theta[8];	
		
	end
	else if(cycle == 11)
	begin
		
		mul_1_in1 = b[8];
		mul_1_in2 = theta[8];
		
	end
	else if(cycle == 12)
	begin
		
		mul_1_in1 = phi[9];
		mul_1_in2 = theta[7];
		
		mul_2_in1 = theta[7];
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 13)
	begin
		
		mul_1_in1 = readbus[31:0];
		mul_1_in2 = R1_mul2;
		
	end
	else if(cycle == 14)
	begin
		
		mul_1_in1 = c[8];
		mul_1_in2 = R2_mul2;
		
		mul_2_in1 = theta[7];
		mul_2_in2 = b[7];
	end
	else if(cycle == 15)
	begin

		mul_1_in1 = readbus[31:0];
		mul_1_in2 = R1_mul2;
		
	end
	else if(cycle == 16)
	begin
		
		mul_1_in1 = b[8];
		mul_1_in2 = R2_mul2;
		
		mul_2_in1 = phi[9];
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 17)
	begin

		mul_1_in1 = phi[8];
		mul_1_in2 = theta[6];
		
		mul_2_in1 = c[7];
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 18)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = readbus[31:0];
		mul_2_in2 = R1_mul2;
	end
	else if(cycle == 19)
	begin
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R2_mul2;
		mul_2_in2 = c[8];
		
	end
	else if(cycle == 20)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = theta[6];
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 21)
	begin
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = b[7];
		mul_2_in2 = R1_mul2;
	end
	else if(cycle == 22)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
		mul_2_in1 = BC[6];
		mul_2_in2 = phi[8];
		
	end
	else if(cycle == 23)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
		mul_2_in1 = phi[7];
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 24)
	begin
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
		mul_1_in1 = theta[5];
		mul_1_in2 = phi[7];
		
		mul_2_in1 = theta[5];
		mul_2_in2 = readbus[31:0];
	end
	else if(cycle == 25)
	begin
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 26)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 27)
	begin
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 28)
	begin
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta[5];
		mul_2_in2 = b[5];
	end
	else if(cycle == 29)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 30)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 31)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
		mul_2_in1 = BC[5];
		mul_2_in2 = phi[7];
		
	end
	else if(cycle == 32)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
		mul_2_in1 = readbus[31:0];
		mul_2_in2 = theta[6];
		
	end
	else if(cycle == 33)
	begin
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
		mul_1_in1 = theta[4];
		mul_1_in2 = theta[6];
		
		mul_2_in1 = theta[4];
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 34)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 35)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 36)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 37)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 38)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta[4];
		mul_2_in2 = b[4];
		
	end
	else if(cycle == 39)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[5];
		
	end
	else if(cycle == 40)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 41)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 42)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
		mul_2_in1 = theta[6];
		mul_2_in2 = BC[4];
		
	end
	else if(cycle == 43)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
		mul_2_in1 = theta[5];
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 44)
	begin
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
		mul_1_in1 = theta[3];
		mul_1_in2 = theta[5];
		
		mul_2_in1 = theta[3];
		mul_2_in2 = readbus[31:0];
	end
	else if(cycle == 45)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 46)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 47)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 48)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 49)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 50)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta[3];
		mul_2_in2 = b[3];
	end
	else if(cycle == 51)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[4];
		
	end
	else if(cycle == 52)
	begin

		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[5];
		
	end
	else if(cycle == 53)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 54)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 55)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
		mul_2_in1 = BC[3];
		mul_2_in2 = theta[5];
		
	end
	else if(cycle == 56)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
		mul_2_in1 = readbus[31:0];
		mul_2_in2 = theta[4];
		
	end
	else if(cycle == 57)
	begin
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
		mul_1_in1 = theta[2];
		mul_1_in2 = theta[4];
		
		mul_2_in1 = theta[2];
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 58)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 59)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 60)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 61)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 62)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 63)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 64)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta[2];
		mul_2_in2 = b[2];
		
	end
	else if(cycle == 65)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[3];
		
	end
	else if(cycle == 66)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[4];
		
	end
	else if(cycle == 67)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[5];
		
	end
	else if(cycle == 68)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 69)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 70)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
		mul_2_in1 = BC[2];
		mul_2_in2 = theta[4];
		
	end
	else if(cycle == 71)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
		mul_2_in1 = readbus[31:0];
		mul_2_in2 = theta[3];
		
	end
	else if(cycle == 72)
	begin
		
		sub_in_1 = R1_mul2;
		sub_in_2 = R2_mul2;
		
		mul_1_in1 = theta_1_10;
		mul_1_in2 = theta[3];
		
		mul_2_in1 = theta_1_10;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 73)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[4];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 74)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 75)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 76)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 77)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 78)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 79)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 80)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta_1_10;
		mul_2_in2 = b[1];
		
	end
	else if(cycle == 81)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[4];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[2];
		
	end
	else if(cycle == 82)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[3];
		
	end
	else if(cycle == 83)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[4];
		
	end
	else if(cycle == 84)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[5];
		
	end
	else if(cycle == 85)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 86)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 87)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 88)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
	end
	else if(cycle == 89)
	begin
		
		mul_1_in1 = theta_0_10;
		mul_1_in2 = theta[2];
		
		mul_2_in1 = theta_0_10;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 90)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[3];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 91)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[4];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 92)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 93)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 94)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = readbus[31:0];
		
	end
	else if(cycle == 95)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[6];
		
	end
	else if(cycle == 96)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = c[7];
		
	end
	else if(cycle == 97)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 98)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = c[8];
		
		mul_2_in1 = theta_0_10;
		mul_2_in2 = b[0];
		
	end
	else if(cycle == 99)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[3];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[1];
		
	end
	else if(cycle == 100)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[4];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[2];
		
	end
	else if(cycle == 101)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[5];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[3];
		
	end
	else if(cycle == 102)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = theta[6];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[4];
		
	end
	else if(cycle == 103)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[7];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[5];
		
	end
	else if(cycle == 104)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[8];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[6];
		
	end
	else if(cycle == 105)
	begin
	
		mul_1_in1 = R1_mul2;
		mul_1_in2 = phi[9];
		
		mul_2_in1 = R1_mul2;
		mul_2_in2 = b[7];
		
	end
	else if(cycle == 106)
	begin
		
		mul_1_in1 = R1_mul2;
		mul_1_in2 = readbus[31:0];
		
	end
	else if(cycle == 107)
	begin
		
		mul_1_in1 = R2_mul2;
		mul_1_in2 = b[8];
		
	end
	
	
end



/*------------------------------------------------POSEDGE------------------------------------*/


always@(posedge clock) 
begin
	if(Enable == 1 && Counter == 26)
		begin
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 25)
		begin
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 24)
		begin		
			theta[2] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 23)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			BC[2] <= mul_2_out;
		end
	else if(Enable == 1 && Counter == 22)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 21)
		begin	
			theta[3] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 20)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			BC[3] <= mul_2_out;
		end
	else if(Enable == 1 && Counter == 19)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 18)
		begin	
			theta[4] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 17)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			BC[4] <= mul_2_out;
		end
	else if(Enable == 1 && Counter == 16)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 15)
		begin	
			theta[5] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 14)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			BC[5] <= mul_2_out;
		end
	else if(Enable == 1 && Counter == 13)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 12)
		begin	
			theta[6] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 11)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			BC[6] <= mul_2_out;
		end
	else if(Enable == 1 && Counter == 10)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 9)
		begin	
			theta[7] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 8)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 7)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 6)
		begin	
			theta[8] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 5)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 4)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 3)
		begin	
			theta[9] <= sub_out;
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 2)
		begin		
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
		end
	else if(Enable == 1 && Counter == 1)
		begin	
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
		end
	else if(Enable == 1 && Counter == 0)
		begin	
			theta[10] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= 1;
		end


	else if(Enable == 0 && Counter == 0 && cycle == 1)
		begin
			
			phi[9] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;

			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 2)
		begin		
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;			
		end
	else if(Enable == 0 && Counter == 0 && cycle == 3)
		begin
			phi[8] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 4)
		begin
		
			R2_mul1 <= R1_mul1;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 5)
		begin
			
			phi[7] <= sub_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 6)
		begin
			
			cycle <= cycle + 1;
		end


		
	else if(Enable == 0 && Counter == 0 && cycle == 7)
		begin
		
		theta[9] <= div_out;
		
		cycle <= cycle + 1;
	end
	else if(Enable == 0 && Counter == 0 && cycle == 8)
		begin		

			WE <= 1;
			
			theta[8] <= div_out;
	
			cycle <= cycle + 1;
			
		end
	else if(Enable == 0 && Counter == 0 && cycle == 9)
		begin
			
			WE <= 1;			
			wrAddress <= 127; //`WRITE_ADDRESS_START + 99; // T inv 10,10
			
			T_out <= theta[9];
			
			theta[7] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 10)
		begin
			
			WE <= 1;			
			wrAddress <= 116; // `WRITE_ADDRESS_START + 88; // T inv 9,9
			
			T_out <= R1_mul1;
			
			theta[6] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 11)
		begin
		
			WE <= 1;			
			wrAddress <= 126; //`WRITE_ADDRESS_START + 98; // T inv 10,9
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[5] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 12)
		begin
			
			WE <= 1;			
			wrAddress <= 117; //`WRITE_ADDRESS_START + 89; // T inv 9,10
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[4] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 13)
		begin
			WE <= 1;			
			wrAddress <= 105; //`WRITE_ADDRESS_START + 77; // T inv 8,8
			
			T_out <= R1_mul1;
			
			theta[3] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 14)
		begin
			WE <= 1;			
			wrAddress <= 115; //`WRITE_ADDRESS_START + 87; // T inv 9,8
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[2] <= div_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 15)
		begin
			WE <= 1;			
			wrAddress <= 125; //`WRITE_ADDRESS_START + 97; // T inv 10,8
			theta_1_10 <= div_out;
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 16)
		begin
			WE <= 1;			
			wrAddress <= 106; //`WRITE_ADDRESS_START + 78; // T inv 8,9
			theta_0_10 <= div_out;
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 17)
		begin
			WE <= 1;			
			wrAddress <= 107; //`WRITE_ADDRESS_START + 79; // T inv 8,10
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 18)
		begin
			WE <= 1;			
			wrAddress <= 94; //`WRITE_ADDRESS_START + 66; // T inv 7,7
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 19)
		begin
			WE <= 1;			
			wrAddress <= 104; //`WRITE_ADDRESS_START + 76; // T inv 8,7
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};			
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 20)
		begin
			WE <= 1;			
			wrAddress <= 114; //`WRITE_ADDRESS_START + 86; // T inv 9,7
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 21)
		begin
			WE <= 1;			
			wrAddress <= 124; //`WRITE_ADDRESS_START + 96; // T inv 10,7
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 22)
		begin
			WE <= 1;			
			wrAddress <= 95; //`WRITE_ADDRESS_START + 67; // T inv 7,8
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 23)
		begin
			WE <= 1;			
			wrAddress <= 96; //`WRITE_ADDRESS_START + 68; // T inv 7,9
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 24)
		begin
			WE <= 1;			
			wrAddress <= 97; //`WRITE_ADDRESS_START + 69; // T inv 7,10
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[6] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 25)
		begin
			WE <= 1;			
			wrAddress <= 83; //`WRITE_ADDRESS_START + 55; // T inv 6,6
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 26)
		begin
			WE <= 1;			
			wrAddress <= 93; //`WRITE_ADDRESS_START + 65; // T inv 7,6
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 27)
		begin
			WE <= 1;			
			wrAddress <= 103; //`WRITE_ADDRESS_START + 75; // T inv 8,6
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 28)
		begin
			WE <= 1;			
			wrAddress <= 113; //`WRITE_ADDRESS_START + 85; // T inv 9,6
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 29)
		begin
			WE <= 1;			
			wrAddress <= 123; //`WRITE_ADDRESS_START + 95; // T inv 10,6
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 30)
		begin
			WE <= 1;			
			wrAddress <= 84; //`WRITE_ADDRESS_START + 56; // T inv 6,7
		
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 31)
		begin
			WE <= 1;			
			wrAddress <= 85; //`WRITE_ADDRESS_START + 57; // T inv 6,8
			T_out <= R1_mul1;
			
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 32)
		begin
			WE <= 1;			
			wrAddress <= 86; //`WRITE_ADDRESS_START + 58; // T inv 6,9
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 33)
		begin
			WE <= 1;			
			wrAddress <= 87; //`WRITE_ADDRESS_START + 59; // T inv 6,10
			
			T_out <= R1_mul1;
			
			theta[5] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 34)
		begin
			WE <= 1;			
			wrAddress <= 72; //`WRITE_ADDRESS_START + 44; // T inv 5,5
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 35)
		begin
			WE <= 1;			
			wrAddress <= 82; //`WRITE_ADDRESS_START + 54; // T inv 6,5
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 36)
		begin
			WE <= 1;			
			wrAddress <= 92; //`WRITE_ADDRESS_START + 64; // T inv 7,5
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 37)
		begin
			WE <= 1;			
			wrAddress <= 102; //`WRITE_ADDRESS_START + 74; // T inv 8,5
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 38)
		begin
			WE <= 1;			
			wrAddress <= 112; //`WRITE_ADDRESS_START + 84; // T inv 9,5
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 39)
		begin
			WE <= 1;			
			wrAddress <= 122; //`WRITE_ADDRESS_START + 94; // T inv 10,5
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 40)
		begin
			WE <= 1;			
			wrAddress <= 73; //`WRITE_ADDRESS_START + 45; // T inv 5,6
	
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 41)
		begin
			WE <= 1;			
			wrAddress <= 74; //`WRITE_ADDRESS_START + 46; // T inv 5,7
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 42)
		begin
			WE <= 1;			
			wrAddress <= 75; //`WRITE_ADDRESS_START + 47; // T inv 5,8
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 43)
		begin
			WE <= 1;			
			wrAddress <= 76; //`WRITE_ADDRESS_START + 48; // T inv 5,9
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 44)
		begin
			WE <= 1;			
			wrAddress <= 77; //`WRITE_ADDRESS_START + 49; // T inv 5,10
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[4] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 45)
		begin
			WE <= 1;			
			wrAddress <= 61; //`WRITE_ADDRESS_START + 33; // T inv 4,4
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 46)
		begin
			WE <= 1;			
			wrAddress <= 71; //`WRITE_ADDRESS_START + 43; // T inv 5,4
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 47)
		begin
			WE <= 1;			
			wrAddress <= 81; //`WRITE_ADDRESS_START + 53; // T inv 6,4
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 48)
		begin
			WE <= 1;			
			wrAddress <= 91; //`WRITE_ADDRESS_START + 63; // T inv 7,4
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 49)
		begin
			WE <= 1;			
			wrAddress <= 101; //`WRITE_ADDRESS_START + 73; // T inv 8,4
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 50)
		begin
			WE <= 1;			
			wrAddress <= 111; //`WRITE_ADDRESS_START + 83; // T inv 9,4
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 51)
		begin
			WE <= 1;			
			wrAddress <= 121; //`WRITE_ADDRESS_START + 93; // T inv 10,4
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 52)
		begin
			WE <= 1;			
			wrAddress <= 62; //`WRITE_ADDRESS_START + 34; // T inv 4,5
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 53)
		begin
			WE <= 1;			
			wrAddress <= 63; //`WRITE_ADDRESS_START + 35; // T inv 4,6
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 54)
		begin
			WE <= 1;			
			wrAddress <= 64; //`WRITE_ADDRESS_START + 36; // T inv 4,7
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 55)
		begin
			WE <= 1;			
			wrAddress <= 65; //`WRITE_ADDRESS_START + 37; // T inv 4,8
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 56)
		begin
			WE <= 1;			
			wrAddress <= 66; //`WRITE_ADDRESS_START + 38; // T inv 4,9
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 57)
		begin
			WE <= 1;			
			wrAddress <= 67; //`WRITE_ADDRESS_START + 39; // T inv 4,10
			
			T_out <= R1_mul1;
			
			theta[3] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 58)
		begin
			WE <= 1;			
			wrAddress <= 50; //`WRITE_ADDRESS_START + 22; // T inv 3,3
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 59)
		begin
			WE <= 1;			
			wrAddress <= 60; //`WRITE_ADDRESS_START + 32; // T inv 4,3
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 60)
		begin
			WE <= 1;			
			wrAddress <= 70; //`WRITE_ADDRESS_START + 42; // T inv 5,3
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 61)
		begin
			WE <= 1;			
			wrAddress <= 80; //`WRITE_ADDRESS_START + 52; // T inv 6,3
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 62)
		begin
			WE <= 1;			
			wrAddress <= 90; //`WRITE_ADDRESS_START + 62; // T inv 7,3
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 63)
		begin
			WE <= 1;			
			wrAddress <= 100; //`WRITE_ADDRESS_START + 72; // T inv 8,3
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 64)
		begin
			WE <= 1;			
			wrAddress <= 110; //`WRITE_ADDRESS_START + 82; // T inv 9,3
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 65)
		begin
			WE <= 1;			
			wrAddress <= 120; //`WRITE_ADDRESS_START + 92; // T inv 10,3
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 66)
		begin
			WE <= 1;			
			wrAddress <= 51; //`WRITE_ADDRESS_START + 23; // T inv 3,4
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 67)
		begin
			WE <= 1;			
			wrAddress <= 52; //`WRITE_ADDRESS_START + 24; // T inv 3,5
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 68)
		begin
			WE <= 1;			
			wrAddress <= 53; //`WRITE_ADDRESS_START + 25; // T inv 3,6
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 69)
		begin
			WE <= 1;			
			wrAddress <= 54; //`WRITE_ADDRESS_START + 26; // T inv 3,7
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 70)
		begin
			WE <= 1;			
			wrAddress <= 55; //`WRITE_ADDRESS_START + 27; // T inv 3,8
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 71)
		begin
			WE <= 1;			
			wrAddress <= 56; //`WRITE_ADDRESS_START + 28; // T inv 3,9
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 72)
		begin
			WE <= 1;			
			wrAddress <= 57; //`WRITE_ADDRESS_START + 29; // T inv 3,10
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			theta[2] <= sub_out;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 73)
		begin
			WE <= 1;			
			wrAddress <= 39; //`WRITE_ADDRESS_START + 11; // T inv 2,2
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 74)
		begin
			WE <= 1;			
			wrAddress <= 49; //`WRITE_ADDRESS_START + 21; // T inv 3,2
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 75)
		begin
			WE <= 1;			
			wrAddress <= 59; //`WRITE_ADDRESS_START + 31; // T inv 4,2
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 76)
		begin
			WE <= 1;			
			wrAddress <=  69; //`WRITE_ADDRESS_START + 41; // T inv 5,2
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 77)
		begin
			WE <= 1;			
			wrAddress <= 79; //`WRITE_ADDRESS_START + 51; // T inv 6,2
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 78)
		begin
			WE <= 1;			
			wrAddress <= 89; //`WRITE_ADDRESS_START + 61; // T inv 7,2
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 79)
		begin
			WE <= 1;			
			wrAddress <= 99; //`WRITE_ADDRESS_START + 71; // T inv 8,2
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 80)
		begin
			WE <= 1;			
			wrAddress <= 109; //`WRITE_ADDRESS_START + 81; // T inv 9,2
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 81)
		begin
			WE <= 1;			
			wrAddress <= 119; //`WRITE_ADDRESS_START + 91; // T inv 10,2
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 82)
		begin
			WE <= 1;			
			wrAddress <= 40; //`WRITE_ADDRESS_START + 12; // T inv 2,3
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 83)
		begin
			WE <= 1;			
			wrAddress <= 41; //`WRITE_ADDRESS_START + 13; // T inv 2,4
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 84)
		begin
			WE <= 1;			
			wrAddress <= 42; //`WRITE_ADDRESS_START + 14; // T inv 2,5
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 85)
		begin
			WE <= 1;			
			wrAddress <= 43; //`WRITE_ADDRESS_START + 15; // T inv 2,6
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 86)
		begin
			WE <= 1;			
			wrAddress <= 44; //`WRITE_ADDRESS_START + 16; // T inv 2,7
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 87)
		begin
			WE <= 1;			
			wrAddress <= 45; //`WRITE_ADDRESS_START + 17; // T inv 2,8
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 88)
		begin
			WE <= 1;			
			wrAddress <= 46; //`WRITE_ADDRESS_START + 18; // T inv 2,9
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R2_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 89)
		begin
			WE <= 1;			
			wrAddress <= 47; //`WRITE_ADDRESS_START + 19; // T inv 2,10
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 90)
		begin
			WE <= 1;			
			wrAddress <= `WRITE_ADDRESS_START; // T inv 1,1
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 91)
		begin
			WE <= 1;			
			wrAddress <= 38; //`WRITE_ADDRESS_START + 10; // T inv 2,1
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 92)
		begin
			WE <= 1;			
			wrAddress <= 48; //`WRITE_ADDRESS_START + 20; // T inv 3,1
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 93)
		begin
			WE <= 1;			
			wrAddress <= 58; //`WRITE_ADDRESS_START + 30; // T inv 4,1
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 94)
		begin
			WE <= 1;			
			wrAddress <= 68; //`WRITE_ADDRESS_START + 40; // T inv 5,1
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 95)
		begin
			WE <= 1;			
			wrAddress <= 78; //`WRITE_ADDRESS_START + 50; // T inv 6,1
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 96)
		begin
			WE <= 1;			
			wrAddress <= 88; //`WRITE_ADDRESS_START + 60; // T inv 7,1
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 97)
		begin
			WE <= 1;			
			wrAddress <= 98; //`WRITE_ADDRESS_START + 70; // T inv 8,1
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 98)
		begin
			WE <= 1;			
			wrAddress <= 108; //`WRITE_ADDRESS_START + 80; // T inv 9,1
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 99)
		begin
			WE <= 1;			
			wrAddress <= 118; //`WRITE_ADDRESS_START + 90; // T inv 10,1
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 100)
		begin
			WE <= 1;			
			wrAddress <= 29; //`WRITE_ADDRESS_START + 1; // T inv 1,2
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 101)
		begin
			WE <= 1;			
			wrAddress <= 30; //`WRITE_ADDRESS_START + 2; // T inv 1,3
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 102)
		begin
			WE <= 1;			
			wrAddress <= 31; //`WRITE_ADDRESS_START + 3; // T inv 1,4
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 103)
		begin
			WE <= 1;			
			wrAddress <= 32; //`WRITE_ADDRESS_START + 4; // T inv 1,5
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 104)
		begin
			WE <= 1;			
			wrAddress <= 33; //`WRITE_ADDRESS_START + 5; // T inv 1,6
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 105)
		begin
			WE <= 1;			
			wrAddress <= 34; //`WRITE_ADDRESS_START + 6; // T inv 1,7
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			R1_mul2 <= mul_2_out;
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 106)
		begin
			WE <= 1;			
			wrAddress <= 35; //`WRITE_ADDRESS_START + 7; // T inv 1,8
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R1_mul2;
			//R1_mul1 <= mul_2_out;
			
			
			cycle <= cycle + 1;
		end
	else if(Enable == 0 && Counter == 0 && cycle == 107)
		begin
			WE <= 1;			
			wrAddress <= 36; //`WRITE_ADDRESS_START + 8; // T inv 1,9
			
			T_out <= R1_mul1;
			
			R2_mul1 <= R1_mul1;
			R1_mul1 <= mul_1_out;
			
			R2_mul2 <= R2_mul2;
			
			cycle <= cycle + 1;
			
		end
	else if(Enable == 0 && Counter == 0 && cycle == 108)
		begin
			WE <= 1;			
			wrAddress <= 37; //`WRITE_ADDRESS_START + 9; // T inv 1,10
			
			T_out <= {~R1_mul1[31],R1_mul1[30:0]};
			cycle <= cycle;
			
		end
		
	
	
	if(!reset || (go == 1))
	begin
		cycle <= 0;
		WE <= 0;
	end
	
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[0] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 26)
		begin
			c[0]   <= readbus[31:0];
		end
		
		else
		begin
			c[0] <= c[0];
		end
	end
end

always@(posedge clock) 
begin
	if (!reset)
	begin
		a[1] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 25)
		begin
			a[1]   <= readbus[31:0];
		end
		
		else
		begin
			a[1] <= a[1];
		end
	end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[1] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 24)
		begin
			b[1]  <= readbus[31:0];
		end
		
		else
		begin
			b[1] <= b[1];
		end
	end
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[1] <= 32'bx;
	end
	else
	begin
		if(Enable == 1 && Counter == 23)
		begin
			c[1]   <= readbus[31:0];
		end
		
		else
		begin
			c[1] <= c[1];
		end
	end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		a[2] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 22)
		begin
			a[2]   <= readbus[31:0];
		end
		
		else
		begin
			a[2] <= a[2];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[2] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 21)
		begin
			b[2]  <= readbus[31:0];
		end
		
		else
		begin
			b[2] <= b[2];
		end
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[2] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 20)
		begin
			c[2]   <= readbus[31:0];
		end
		
		else
		begin
			c[2] <= c[2];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		a[3] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 19)
		begin
			a[3]   <= readbus[31:0];
		end
		
		else
		begin
			a[3] <= a[3];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[3] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 18)
		begin
			b[3]  <= readbus[31:0];
		end
		
		else
		begin
			b[3] <= b[3];
		end
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[3] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 17)
		begin
			c[3]   <= readbus[31:0];
		end
		
		else
		begin
			c[3] <= c[3];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		a[4] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 16)
		begin
			a[4]   <= readbus[31:0];
		end
		
		else
		begin
			a[4] <= a[4];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[4] <= 32'bx;
	end
	else
		if(Enable == 1 && Counter == 15)
		begin
			b[4]  <= readbus[31:0];
		end
		
		else
		begin
			b[4] <= b[4];
		end
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[4] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 14)
		begin
			c[4]   <= readbus[31:0];
		end
		
		else
		begin
			c[4] <= c[4];
		end
end

always@(posedge clock) 
begin
	if (!reset)
	begin
		a[5] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 13)
		begin
			a[5]   <= readbus[31:0];
		end
		
		else
		begin
			a[5] <= a[5];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[5] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 12)
		begin
			b[5]  <= readbus[31:0];
		end
		
		else
		begin
			b[5] <= b[5];
		end
end


/*always@(posedge clock) 
begin
	if (!reset)
	begin
		c[5] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 11)
		begin
			c[5]  <= readbus[31:0];
		end
		
		else
		begin
			c[5] <= c[5];
		end
end

always@(posedge clock) 
begin
	if (!reset)
	begin
		a[6] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 10)
		begin
			a[6]   <= readbus[31:0];
		end
		
		else
		begin
			a[6] <= a[6];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[6] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 9)
		begin
			b[6]  <= readbus[31:0];
		end
		
		else
		begin
			b[6] <= b[6];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		c[6] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 8)
		begin
			c[6]   <= readbus[31:0];
		end
		
		else
		begin
			c[6] <= c[6];
		end
end

/*always@(posedge clock) 
begin
	if (!reset)
	begin
		a[7] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 7)
		begin
			a[7]   <= readbus[31:0];
		end
		
		else
		begin
			a[7] <= a[7];
		end
end*/

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[7] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 6)
		begin
			b[7]  <= readbus[31:0];
		end
				
		else
		begin
			b[7] <= b[7];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		c[7] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 5)
		begin
			c[7]   <= readbus[31:0];
		end
		
		else
		begin
			c[7] <= c[7];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		a[8] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 4)
		begin
			a[8]   <= readbus[31:0];
		end		
		else
		begin
			a[8] <= a[8];
		end
end

always@(posedge clock) 
begin
	if (!reset)
	begin
		b[8] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 3)
		begin
			b[8]  <= readbus[31:0];
		end
		
		else
		begin
			b[8] <= b[8];
		end
end


always@(posedge clock) 
begin
	if (!reset)
	begin
		c[8] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 2)
		begin
			c[8]   <= readbus[31:0];
		end
		
		else
		begin
			c[8] <= c[8];
		end
end
/*always@(posedge clock) 
begin
	if (!reset)
	begin
		a[9] <= 32'b0;
	end
	else
		if(Enable == 1 && Counter == 1)
		begin
			a[9]   <= readbus[31:0];
		end
		
		else
		begin
			a[9] <= a[9];
		end
end*/
 
 
assign writebus = (WE) ? (T_out) : 32'bx;  
 // Instance of DW_fp_div
div_pipe U1 (.inst_a(div_in1), .inst_b(div_in2), .z6(div_out) , .overflow(overflow), .clock(clock));
DW_fp_addsub #(sig_width, exp_width, ieee_compliance) U2 ( .a(sub_in_1), .b(sub_in_2), .rnd(inst_rnd), .op(inst_op), .z(sub_out), .status(status1));
DW_fp_mult #(sig_width, exp_width, ieee_compliance) U3 (.a(mul_1_in1), .b(mul_1_in2),.z(mul_1_out) , .rnd(inst_rnd), .status(status2));
DW_fp_mult #(sig_width, exp_width, ieee_compliance) U4 (.a(mul_2_in1), .b(mul_2_in2),.z(mul_2_out) , .rnd(inst_rnd), .status(status3));
endmodule
