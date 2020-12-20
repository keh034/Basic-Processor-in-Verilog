// Module Name:    CPU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This is the TopLevel of your project
// Testbench will create an instance of your CPU and test it
// You may add a LUT if needed
// Set Ack to 1 to alert testbench that your CPU finishes doing a program or all 3 programs

module CPU(Reset, Start, Clk, Ack);
	input Reset;		// init/reset, active high
	input Start;		// start next program
	input Clk;			// clock -- posedge used inside design
	output reg Ack;		// done flag from DUT
	
	wire [ 10:0] PgmCtr,			// program counter
			    PCTarg;
	wire [ 8:0] Instruction;	// our 9-bit instruction
	wire [ 3:0] Instr_opcode;	// out 4-bit opcode
	wire [ 1:0]	funct;			// 2-bit function 
	wire [ 7:0] ReadA, ReadB;	// reg_file outputs
	wire [ 7:0] InA, InB, 		// ALU operand inputs
				DataAddr,		// address for read/writing data to memory
				ALU_out;		// ALU result
	wire [ 2:0] Write_Reg;		// address of the reg data will be wrote to	
	wire [ 7:0] RegWriteValue,	// data in to reg file
				MemWriteValue,	// data in to data_memory
				MemReadValue;	// data out from data_memory
	wire		MemWrite,		// data_memory write enable
				RegWrEn,	    // reg_file write enable
				carry_flag,		// carry flag from the ALU, indicates overflow
				branch_flag,    // branch flag from the ALU, indicates cmp instruction was set
				Jump,	        // to program counter: jump 
				BranchEn,		// to program counter: branch enable
				BranchOnFlag,	// to program counter: branch if equal to ALU flag
				LoadInst,		// flag to load data from memory to register 
				LoadImm,		// flag to load immediate to register
				RegWB,			// to regfile: Tells file to write back into the instruction reg, not the accumulator 
				Done;
	reg  [15:0] CycleCt;	    // standalone; NOT PC!
	reg carry_in;
	reg branch;	  // to InstFetch: indicates whether ALU cmp was set or not

	// Fetch = Program Counter + Instruction ROM
	// Program Counter
  InstFetch IF1 (
	.Reset       (Reset   ) , 
	.Start       (Start   ) ,  
	.Clk         (Clk     ) ,  
	.BranchEn (BranchEn) ,  // branch enable
	.BranchOnFlag(BranchOnFlag), // branch if equal to branch flag
	.branch_flag (branch) ,
    .Target      (PCTarg  ) ,
	.ProgCtr     (PgmCtr  )	   // program count = index to instruction memory
	);	

	// Control decoder
  Ctrl Ctrl1 (
	.Instruction  (Instruction),    // from instr_ROM
	.BranchEn     (BranchEn),		// to PC
	.BranchOnFlag (BranchOnFlag),	// to PC
	.WriteEn      (MemWrite),
	.RegEn        (RegWrEn),
	.Done		  (Done),
	.RegWriteBack (RegWB)
  );
  
	// instruction ROM
  InstROM IR1(
	.InstAddress   (PgmCtr), 
	.InstOut       (Instruction)
	);
	
	LUT lut(
	  .Addr(Instruction[4:0]), 
	  .Target(PCTarg)
	);

	assign LoadInst = Instruction[8:5]==4'b0000;  // calls out load specially
	assign LoadImm = Instruction[8:5] == 4'b1010; // calls out load immediate
	
	always@*
	begin
		Ack = Done;  // Update this to the condition you want to set done to true
	end
	

	assign Write_Reg = RegWB ? Instruction[4:2] : 3'b000;  
	
	// Reg file
	// Modify D = *Number of bits you use for each register*
	// Width of register is 8 bits, do not modify
	RegFile #(.W(8),.D(3)) RF1 (
		.Clk       (Clk)		,
		.WriteEn   (RegWrEn)    , 
		.Raddr     (Instruction[4:2]),
		.Waddr     (Write_Reg),
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 )
	);
	
	assign InA = ReadA;						                     // connect RF out to ALU in
	assign InB = ReadB;
	assign Instr_opcode = Instruction[8:5];
	// assign MemWrite = (Instruction[8:5] == 4'b0001);             // mem_store command
	assign RegWriteValue = LoadInst ? MemReadValue : (LoadImm ? { 3'b000, Instruction[4:0]} : ALU_out);    // 2:1 switch into reg_file
	assign MemWriteValue = InA;

	assign DataAddr = MemWrite ? ReadB : ReadA;

	always @(posedge Clk) begin
		carry_in <= carry_flag;
		branch <= branch_flag;
	end

	// Arithmetic Logic Unit
	ALU ALU1(
	  .InputA(InA),      	  
	  .InputB(InB),
	  .imm(Instruction[1:0]),
	  .funct(Instruction[1:0]),	
	  .OP(Instruction[8:5]),
	  .carry_in(carry_in),			  
	  .Out(ALU_out),		  			
	  .carry_out(carry_flag),
	  .branch(branch_flag)
	);
	 
	 // Data Memory
	 DataMem DM1(
		.DataAddress  (DataAddr)    , 
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue)  , 
		.Clk 		  (Clk)     ,
		.Reset		  (Reset)
	);

// count number of instructions executed
// Help you with debugging
	always @(posedge Clk)
	  if (Start == 1)	   // if(start)
		 CycleCt <= 0;
	  else if(Ack == 0)   // if(!halt)
		 CycleCt <= CycleCt+16'b1;

endmodule