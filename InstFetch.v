// Module Name:    InstFetch 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module does not actually fetch the actual code
// It is responsible for providing which line number will be read next


	 
module InstFetch(Reset,Start,Clk,BranchEn, BranchOnFlag, branch_flag, Target,ProgCtr);

  input              Reset,			   // reset, init, etc. -- force PC to 0 
                     Start,			   // begin next program in series
                     Clk,			   // PC can change on pos. edges only
                     BranchEn,	       // jump unconditionally to Target value	 
					 BranchOnFlag,   
                     branch_flag;		   // flag from ALU, tells that cmp function worked and can branch
  input       [10:0] Target;		       // jump ... "how high?"
  output reg[10:0] ProgCtr ;            // the program counter register itself
  
  
  //// program counter can clear to 0, increment, or jump
	always @ (posedge Clk)
	begin 
		if(Reset)
		  ProgCtr <= 0;				        // for first program; want different value for 2nd or 3rd
		else if(Start)						// hold while start asserted; commence when released
		  ProgCtr <= ProgCtr;
		else if(BranchEn && (branch_flag == BranchOnFlag))		// conditional absolute jump
		  ProgCtr <= Target;
		else
		  ProgCtr <= ProgCtr+'b1; 	        // default increment (no need for ARM/MIPS +4. Pop quiz: why?)
	end
	
endmodule

/* Note about Start: if your programs are spread out, with a gap in your machine code listing, you will want 
to make Start cause an appropriate jump. If your programs are packed sequentially, such that program 2 begins 
right after Program 1 ends, then you won't need to do anything special here. 
*/