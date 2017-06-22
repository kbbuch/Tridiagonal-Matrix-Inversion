// synopsys translate_off
`include "/afs/eos.ncsu.edu/dist/synopsys2013/syn/dw/sim_ver/DW_fp_div.v" //link to designware module for Floating Point Divider
//synopsys translate_on

module div_pipe( inst_a, inst_b, z6, overflow, clock );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;


input [sig_width+exp_width : 0] inst_a;
input [sig_width+exp_width : 0] inst_b;
input clock;
output [sig_width+exp_width : 0] z6;
output overflow;

wire [sig_width+exp_width : 0] z_inst;
reg [sig_width+exp_width : 0] z2;
reg [sig_width+exp_width : 0] z1;
reg [sig_width+exp_width : 0] z3;
reg [sig_width+exp_width : 0] z4;
reg [sig_width+exp_width : 0] z5;
reg [sig_width+exp_width : 0] z6;
//wire [7 : 0] status_inst;
wire	[7:0]	status_inst0;
reg overflow;


always@(posedge clock)
begin
	z1 <= z_inst;
	z2 <= z1;
	z3 <= z2;
	z4 <= z3;
	z5 <= z4;
	z6 <= z5;
	//status_inst0 <= status_inst;
	if(inst_b ==32'h0) 
		overflow <= 1'b1;
    else 
		overflow <= 1'b0;
end



  // Instance of DW_fp_div
DW_fp_div #(sig_width, exp_width, ieee_compliance) U1 ( .a(inst_a), .b(inst_b), .rnd(3'b0), .z(z_inst), .status(status_inst0) );

endmodule