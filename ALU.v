// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// 
	 
module ALU(InputA,InputB,funct,OP, imm, carry_in,Out,carry_out,branch);

	input [ 7:0] InputA;	// accumulator register value
	input [ 7:0] InputB;	// operand register or immediate
	input [ 1:0] funct;	// funct
	input [ 3:0] OP;	// opcode 4 bits
	input [1:0] imm;	// immediate value
	input carry_in;		// carry in 1 bit
	output reg [7:0] Out; 	// logic in SystemVerilog
	output reg carry_out,				// need to rename zero in other files
			   branch;

	always@* // always_comb in systemverilog
	begin
		Out = 0;
		carry_out = carry_in;
		case (OP)
		// 4'b0000: //unused LOAD
		// 4'b0001: //unused STORE
		4'b0010: begin
			Out <= InputB << (imm+1);  	// could be bad
			carry_out <= InputB[7-imm]; 	// 0100 0000 << 2
			end
		4'b0011: begin
			Out <= InputB >> (imm+1);  	// same as above
			carry_out <= InputB[imm]; 		// 0000 0001 >> 1 
			end
		4'b0100: begin	// add/sub
				if( funct == 2'b00 ) begin
					{carry_out, Out} <= InputA + InputB;
				end
				else if ( funct == 2'b01 ) begin
					{carry_out, Out} <= InputA + InputB + carry_in;
				end
				else if ( funct == 2'b10 ) begin
					{carry_out, Out} <= InputB - InputA;
				end 
				else if ( funct == 2'b11 ) begin		// possible error here, swap Out/carry_out
					{carry_out, Out} <= InputB - InputA - carry_in;
				end
			end
		4'b0101: begin
			if (funct == 2'b00) //OR
				Out <= InputA | InputB;
			else if (funct == 2'b01) //AND
				Out <= InputA & InputB;
			else if (funct == 2'b10) //XOR
				Out <= InputA ^ InputB;
			else if (funct == 2'b11) //NAND
				Out <=  ~(InputA & InputB);
		end
		4'b0110: begin	// compare		
			if (funct == 2'b00)
				branch <= (InputA == InputB) ? 1'b1 : 1'b0;
			else if (funct == 2'b01)
				branch <= (InputA < InputB) ? 1'b1 : 1'b0;
			else if (funct == 2'b10) 
				branch <= (InputA > InputB) ? 1'b1 : 1'b0;
		end
		4'b1011: begin	// movi, movo, swap 
			if ( funct == 2'b00 ) begin
				Out <= InputA;
			end else begin
				Out <= InputB;
			end
		end
		4'b1100: begin //shift with carry
			if (funct == 2'b00) begin
				Out <= {InputB[6:0], carry_in};
				carry_out <= InputB[7]; 
			end	else if (funct == 2'b01) begin
				Out <= {carry_in, InputB[7:1]};
				carry_out <= InputB[0];
			end
		end
		4'b1101: //add immediate
			Out <= InputB + (imm+1);
		4'b1110: // subtract immediate
			Out <= InputB - (imm+1);

		default: begin
			Out = 0;
			carry_out = carry_in;
			// branch = 0;
		end
	  endcase
	end 

	// always@*							  // assign Zero = !Out;
	// begin
	//	case(Out)
	//		'b0     : Zero = 1'b1;
	//		default : Zero = 1'b0;
    //  endcase
	// end

endmodule