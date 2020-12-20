`timescale 1ns/ 1ps



//Test bench
//Arithmetic Logic Unit
/*
* INPUT: A, B
* op: 00, A PLUS B
* op: 01, A AND B
* op: 10, A OR B
* op: 11, A XOR B
* OUTPUT A op B
* equal: is A == B?
* even: is the output even?
*/


module ALU_tb;
reg [ 7:0] INPUTA;     	  // data inputs
reg [ 7:0] INPUTB;
reg [ 1:0] funct;
reg carry_in;
reg [ 3:0] op;		// ALU opcode, part of microcode
wire[ 7:0] OUT;		  
wire carry_out;
wire Zero;    
 
reg [ 7:0] expected;
 
// CONNECTION
ALU uut(
  .InputA(INPUTA),      	  
  .InputB(INPUTB),
  .funct(funct),
  .OP(op),
  .carry_in(carry_in),
  .Out(OUT),
  .carry_out(carry_out)
    );
	 
initial begin
	
	INPUTA = 1;
	INPUTB = 0;
	carry_in = 0;
	op= 'b0101; // OR
	funct = 2'b00;
	test_alu_func; // void function call
	#5;

	INPUTA = 1;
	INPUTB = 1;
	carry_in = 0;
	op= 'b0101; // AND
	funct = 2'b01;
	test_alu_func; // void function call
	#5;

	INPUTA = 1;
	INPUTB = 1;
	carry_in = 0;
	op= 'b0101; // XOR
	funct = 2'b10;
	test_alu_func; // void function call
	#5;

	INPUTA = 0;
	INPUTB = 0;
	carry_in = 0;
	op= 'b0101; // NAND
	funct = 2'b11;
	test_alu_func; // void function call
	#5;
	
	INPUTA = 4;
	INPUTB = 1;
	carry_in = 1;
	op= 4'b0100; // ADD
	funct = 2'b00;
	test_alu_func; // void function call
	#5;

	INPUTA = 8'b10101010;
	INPUTB = 8'b10000000;
	carry_in = 1;
	op= 4'b0100; // ADD, check if carry bit is set
	funct = 2'b00;
	test_alu_func; // void function call
	#5;

	INPUTA = 4;
	INPUTB = 5;
	carry_in = 1;
	op= 4'b0100; // ADDC
	funct = 2'b01;
	test_alu_func; // void function call
	#5;

	INPUTA = 4;
	INPUTB = 1;
	carry_in = 0;
	op= 4'b0100; // SUB
	funct = 2'b10;
	test_alu_func; // void function call
	#5

	INPUTA = 'b10000000;
	INPUTB = 'b11111111;
	carry_in = 1;
	op= 4'b0100; // SUB, check if borrow bit is set
	funct = 2'b10;
	test_alu_func; // void function call
	#5;

	INPUTA = 4;
	INPUTB = 1;
	carry_in = 1;
	op= 4'b0100; // SUBC <- not done yet
	funct = 2'b11;
	test_alu_func; // void function call
	#5;

	INPUTA = 8'b10000111;
	INPUTB = 1;
	carry_in = 1;
	op = 2; // SHIFTL
	test_alu_func;
	#5;

	INPUTA = 8'b10001110;
	INPUTB = 1;
	carry_in = 1;
	op = 3; // SHIFTR
	test_alu_func;
	#5;

	INPUTA = 8'b10000111;
	INPUTB = 1;
	carry_in = 1;
	op = 12; // SHIFTLC
	funct = 0;
	test_alu_func;
	#5;

	INPUTA = 8'b10000111;
	INPUTB = 1;
	carry_in = 1;
	op = 12; // SHIFTRC
	funct = 1;
	test_alu_func;
	#5;

	INPUTA = 5;
	INPUTB = 2;
	op = 13;
	test_alu_func;

	INPUTA = 5;
	INPUTB = 2;
	op = 14;
	test_alu_func;

	end
	
	task test_alu_func;
	begin
	  case (op)
		2: expected = INPUTA << (INPUTB+1);
		3: expected = INPUTA >> (INPUTB+1);
		4: begin
		  case (funct)
		    0: expected = INPUTA + INPUTB;
			1: expected = INPUTA + INPUTB + carry_in;
			2: expected = INPUTA - INPUTB;
			3: expected = INPUTA - INPUTB - carry_in;
		  endcase
		end
		5: begin
			case (funct) 
				0: expected = INPUTA | INPUTB;
				1: expected = INPUTA & INPUTB;
				2: expected = INPUTA ^ INPUTB;
				3: expected = ~(INPUTA & INPUTB);
			endcase
		end
		6: begin
			case (funct)
				0: expected = (INPUTA == INPUTB) ? 1'b1 : 1'b0;
				1: expected = (INPUTA < INPUTB) ? 1'b1 : 1'b0;
				2: expected = (INPUTA >INPUTB) ? 1'b1 : 1'b0;
			endcase
		end
		12:	begin
			case (funct)
				0: expected = {INPUTA[6:0], carry_in};
				1: expected = {carry_in,INPUTA[7:1]};
			endcase
		end

		13: begin
			expected = INPUTA + INPUTB;
		end

		14: begin
			expected = INPUTA - INPUTB;
		end

	  endcase
	  #1; if(expected == OUT)
		begin
			$display("%t YAY!! inputs = %h, %h, output = %h, opcode = %b, Carryout %b",$time, INPUTA,INPUTB, OUT, op, carry_out);
		end
	    else begin $display("%t FAIL! inputs = %h, %h, output = %h, opcode = %b, Carryout %b",$time, INPUTA,INPUTB, OUT, op, carry_out);
		end
	end
	endtask

endmodule