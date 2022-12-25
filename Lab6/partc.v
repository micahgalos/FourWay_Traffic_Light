`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
///////  LAB#6 
///////////////////////////////////////////////////////////////////////////
///////

//#########################################################################
module laser_surgery_sys #(parameter NBITS = 32)(
	input wire b, input wire clk,
	output reg NORTH, output reg SOUTH,
	output reg EAST, output reg WEST
);

	reg reset = 1'b0; 
	reg reset1 = 1'b0;
	reg sCheck = 1'b0;
	reg waitWalk = 1'b0;
	
	reg [1:0] curr;
	reg [1:0] next;
	
	wire timer;
	wire timer1;
	
	wire [NBITS-1:0] cnt_ini;
	wire [NBITS-1:0] cnt_rst;
	wire [NBITS-1:0] cnt_ini1;
	wire [NBITS-1:0] cnt_rst1;

// --------------------------------------
// Comb. Logic
// --------------------------------------
assign cnt_ini = 32'D0000 ;
assign cnt_rst = 32'D150000000; // 3 secs ( 25 MHZ internal clock )

assign cnt_ini1 = 32'D0000 ;
assign cnt_rst1 = 32'D250000000; // 5 secs

// --------------------------------------
// Comb. Logic - FSM
// --------------------------------------	
localparam EWLANE = 2'b00;
localparam NSLANE = 2'b01;
localparam WALK = 2'b10;

// --------------------------------------
// Sequential logic
// --------------------------------------
always @(posedge clk) 
	begin
	curr <= next;
	
	if(reset)
		begin
		waitWalk = 1'b0;
		end
	
	if(b)
		begin
		waitWalk = 1'b1;
		end
	
	if(curr == NSLANE)
		sCheck = 1'b0;
	
	if(curr == EWLANE)
		sCheck = 1'b1;
	
	end

always @(curr) 
	begin
		case (curr)
			NSLANE:
				begin
					NORTH = 1'b1;
					SOUTH = 1'b1;
					EAST = 1'b0;
					WEST = 1'b0;
					reset  = 1'b0;
					reset1 = 1'b1;
					if(timer) 
						begin
							if(waitWalk) 
								begin
								next = WALK; //moves on to the WALK state
								end
							else 
								begin 
								next = EWLANE; //moves on to the OFF state
								end
						end // if(timer)
					else 
						begin
						next = NSLANE; // stays in the loop
						end 
			end // ON state
				
			EWLANE:	
				begin
					NORTH = 1'b0;
					SOUTH = 1'b0;
					EAST = 1'b1;
					WEST = 1'b1;
					reset  = 1'b0;
					reset1 = 1'b1;
					if(timer)
						begin
							if(waitWalk) 
								begin
								next = WALK;
								end
					else 
						begin 
						next = NSLANE;
						end
					end // if(timer)
					else 
						begin
						next = EWLANE;
						end 	
				end // START state
				
		WALK: 
			begin
				NORTH = 1'b0;
				SOUTH = 1'b0;
				EAST = 1'b0;
				WEST = 1'b0;
				reset  = 1'b1;
				reset1 = 1'b0;
					if(timer1)
						begin
							if(sCheck) 
								begin
								next = NSLANE;
								end
							else 
								begin 
								next = EWLANE;
								end
					end // if(timer1)
					else 
						begin
						next = WALK;
						end 	
			end // WALK state
				
		default: 
			begin
				NORTH = 1'b0;
				SOUTH = 1'b0;
				EAST = 1'b0;
				WEST = 1'b0;
				reset  = 1'b1;
				reset1 = 1'b0;
				next = EWLANE;
			end
		
	endcase
end

// --------------------------------------
// Timer instantiation
// --------------------------------------
timer_st #( .NBITS(NBITS) ) timerst(
	.timer(timer), .clk(clk), .reset(reset),
	.cnt_ini(cnt_ini), .cnt_rst(cnt_rst)
);


timer_st #( .NBITS(NBITS) ) timerst1(
	.timer(timer1), .clk(clk), .reset(reset1),
	.cnt_ini(cnt_ini1), .cnt_rst(cnt_rst1)
);

endmodule
//#########################################################################

//#########################################################################
module flopr #( parameter NBITS = 16 )(
	input clk, input reset,
	input [NBITS-1:0] cnt_ini, input [NBITS-1:0] nextq,
	output[NBITS-1:0] q
);

reg [NBITS-1:0] iq ;
always @(posedge clk) 
	begin 
		if(reset) 
			begin
			iq <= cnt_ini ;
			end
		else 
			begin
			iq <= nextq;
			end
	end
	
	assign q = iq ;
	
endmodule
//#########################################################################


//#########################################################################
module comparatorgen_st #( parameter NBITS = 16 )(
	output wire r , input wire[NBITS-1:0] a , input wire[NBITS-1:0] b 
);

	wire [NBITS-1:0] iresult ;
	genvar k ;
generate
	for (k=0; k < NBITS; k = k+1)
	begin : blk
	xor c1 (iresult[k], a[k], b[k] ) ;
end
endgenerate
// Reduction plus negation
assign r = ~(|iresult);
endmodule
//#########################################################################


//#########################################################################
module fulladder_st(
output wire r,
output wire cout,
input wire a,
input wire b,
input wire cin
) ;
assign r = (a ^ b) ^ (cin) ;
assign cout = (a & b) | ( a & cin ) | ( b & cin ) ;
endmodule
//#########################################################################


//#########################################################################
module addergen_st #( parameter NBITS = 16 )(
output wire[NBITS-1:0] r ,
output wire cout ,
input wire[NBITS-1:0] a ,
input wire[NBITS-1:0] b ,
input wire cin ) ;
wire [NBITS:0] carry;
assign carry[0]= cin ;
genvar k ;
generate
for (k=0; k < NBITS; k = k+1)
begin : blk
fulladder_st FA (
.r(r[k]),
.cout(carry[k+1]),
.a(a[k]),
.b(b[k]),
.cin(carry[k]) ) ;
end
endgenerate
assign cout = carry[NBITS] ;
endmodule
//#########################################################################


//#########################################################################
module adder #( parameter NBITS = 16 )(
input [NBITS-1:0] q ,
input [NBITS-1:0] cnt_ini ,
input [NBITS-1:0] cnt_rst ,
output[NBITS-1:0] nextq,
output tick
);
wire same ;
wire[NBITS-1:0] inextq;
// ------------------------------------------------
// inextq = q + 1 ;
// ------------------------------------------------
addergen_st #(.NBITS(NBITS))
nextval ( .r(inextq), // Next value

.cout(), // Carry out - Don't use
.a(q), // Current value
.b(16'b0000_0001), // Plus One
.cin(16'b0000_0000) ) ; // No carry in

// ------------------------------------------------
// Are inextq and cnt_rst equal ?
// ------------------------------------------------
comparatorgen_st #(.NBITS(NBITS))
comparator (

.r(same) ,
.a(inextq),
.b(cnt_rst) );

// -----------------------------------------------------------------
// If they are the same produce a tick and set the value for nextq
// -----------------------------------------------------------------
assign tick = (same) ? 'd1 : 'd0 ;
assign nextq = (same) ? cnt_ini : inextq ;
endmodule
//#########################################################################


//#########################################################################
module timer_st #(
parameter NBITS = 32
)
(
output wire timer ,
input wire clk ,
input wire reset,
input [NBITS-1:0] cnt_ini ,
input [NBITS-1:0] cnt_rst
);
wire [NBITS-1:0] q ;
wire [NBITS-1:0] qnext ;
// Compute the next value
adder #( .NBITS(NBITS ) )
c1 (.q(q),
.cnt_ini(cnt_ini),
.cnt_rst(cnt_rst),
.nextq(qnext),
.tick(timer) );
// Save the next state
flopr #( .NBITS(NBITS ) )
c2 (.clk(clk),
.reset(reset),
.cnt_ini(cnt_ini),
.nextq(qnext),
.q(q) );
endmodule
//#########################################################################
