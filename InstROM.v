module InstROM (InstAddress, InstOut) ;
	input [11-1:0] InstAddress;
	output reg[8:0] InstOut;
	reg[8:0] inst_rom[(2**11)-1:0];
	always@* InstOut = inst_rom[InstAddress];
	initial begin
		$readmemb("machine_codeP3.txt",inst_rom);
	end
endmodule
