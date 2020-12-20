// Module Name:    Ctrl 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is the control decoder (combinational, not clocked)
// Out of all the files, you'll probably write the most lines of code here
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
// There may be more outputs going to other modules

module Ctrl (Instruction, BranchEn, BranchOnFlag, WriteEn, RegEn, Done, RegWriteBack);


  input[ 8:0] Instruction;	   // machine code
  output reg BranchEn, BranchOnFlag, WriteEn, RegEn, Done, RegWriteBack;

	// jump on right shift that generates a zero
	always@*
	begin 
	
	//0010 (shiftl), 0011(shiftr), 0100(arith), 0101(logical), 1011(reg movement), 1100(shiftc), 1101(addi), 1110(subi)
	// not included: load, store, compare, branch, jump, halt, loadi
	
		if( Instruction[8:5] == 4'b0000 ) begin				// load	[reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0001 ) begin	// store [reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 1;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0010 ) begin	// shiftl [reg] [imm]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;	
			RegWriteBack = 1;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0011 ) begin	// shiftr [reg] [imm]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 1;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0100 ) begin	// arithmetic [reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0101 ) begin	// logical [reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0110 ) begin	// compare [reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b0111 ) begin	// bne [imm]
			BranchEn = 1;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1000 ) begin	// beq [imm]
			BranchEn = 1;
			BranchOnFlag = 1;
			WriteEn = 0;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1001 ) begin	// jump [imm]
			// not used
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1010 ) begin	// loadi [imm]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 0;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1011 ) begin	// register movement [reg]
			BranchEn = 0;		
			BranchOnFlag = 0;	
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = (Instruction[1:0] == 2'b00); // MOVI writes to $r#	 MOVO, SWAP writes to r0
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1100 ) begin	// shift with carry [reg]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 1;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1101 ) begin	// addi [reg] [imm]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 1;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1110 ) begin	// subi [reg] [imm]
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 1;
			RegWriteBack = 1;
			Done = 0;
		end	else if( Instruction[8:5] == 4'b1111 ) begin	// halt
			Done = 1;
		end else begin
			BranchEn = 0;
			BranchOnFlag = 0;
			WriteEn = 0;
			RegEn = 0;
			RegWriteBack = 0;
			Done = 0;
		end
	end


endmodule