`timescale 1ns/ 1ps

//Test bench
//InstFetch PC counter

module InstFetch_tb;

reg Reset;			   // reset, init, etc. -- force PC to 0 
reg Start;			   // begin next program in series
reg Clk;			   // PC can change on pos. edges only
reg BranchEn;	       // jump unconditionally to Target value	 
reg BranchOnFlag;   
reg branch_flag;		   // flag from ALU, tells that cmp function worked and can branch
reg [9:0] Target;		       // jump to absolute target
wire [9:0] ProgCtr ;            // the program counter register itself

InstFetch uut(
	.Reset       (Reset   ) , 
	.Start       (Start   ) ,  
	.Clk         (Clk     ) ,  
	.BranchEn (BranchEn) ,  // branch enable
	.BranchOnFlag(BranchOnFlag), // branch if equal to branch flag
	.branch_flag (branch_flag) ,
    .Target      (Target ) ,
	.ProgCtr     (ProgCtr  )	   // program count = index to instruction memory
);

// clock generator
always
begin
    #10;
    Clk = 1'b1;
    #10
    Clk = 1'b0;
end

integer i;
initial begin
	Reset = 1;
	Start = 0;
	BranchEn = 0;
	BranchOnFlag = 0;
	branch_flag = 0;
	Target = 0;

	#10;
	for(i = 0; i < 2; i = i + 1) begin // reset ProgCtr to 0
		@(posedge Clk);
		test_InstFetch_func;
	end
	Reset = 0;
	#10;
	for(i = 0; i < 10; i = i + 1) begin // increment ProgCtr multiple times
		@(posedge Clk);
		test_InstFetch_func;
	end
	Start = 1;
	#10;
	for(i = 0; i < 5; i = i + 1) begin // test Start properly prevents PC from changing
		@(posedge Clk);
		test_InstFetch_func;
	end

	Start = 0;
	BranchEn = 1;
	BranchOnFlag = 1;
	branch_flag = 1;
	Target = 1000; // test branch to given target
	@(posedge Clk);
	test_InstFetch_func;
	
	BranchEn = 1;
	BranchOnFlag = 1;
	branch_flag = 0;
	Target = 300;
	
	// test increments after branching, and does not branch without proper flags set
	for (i = 0; i < 5; i = i + 1) begin 
		@ (posedge Clk);
		test_InstFetch_func;
	end
    
	$stop;

end

task test_InstFetch_func;
	begin
	$display("ProgCtr = %d, reset = %b, start = %b, Clk = %b, BranchEn = %b, BranchOnFlag = %b, branch_flag = %b, Target = %d.", 
	ProgCtr, Reset, Start, Clk, BranchEn, BranchOnFlag, branch_flag, Target);
	end
	endtask
endmodule