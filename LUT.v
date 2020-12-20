// Module Name:    LUT
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This is the lookup table
// Leverage a few-bit pointer to a wider number
// It is optional
// You may increase the Addr, but you are not allowed to go over 32 elements (5 bits)
// You could use it for anything you want. Ex. possible lookup table for PC target
// Lookup table acts like a function: here Target = f(Addr);
//  in general, Output = f(Input);
module LUT(Addr, Target);
	input	[ 4:0] Addr;
	output reg	[ 10:0] Target;

	always @*
		case(Addr)
			5'b00000:	Target = 11'd19;
			5'b00001:	Target = 11'd27;
			5'b00010:	Target = 11'd34;
			5'b00011:	Target = 11'd39;
			5'b00100:	Target = 11'd51;
			5'b00101:	Target = 11'd74;
			5'b00110:	Target = 11'd76;
			5'b00111:	Target = 11'd83;
			default:	Target = 11'h000;
		endcase
endmodule
