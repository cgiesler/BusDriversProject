module Branch_calc_tb();

logic [31:0] PC, Reg0Out, Reg1Out, imm, BrPC;
logic B, BEQ, JMP, RET, Branch;

Branch_calc DUT(.*);

int errors = 0;

initial begin
	PC = 32'h00000000;
	Reg0Out = 32'h00000000;
	Reg1Out = 32'h00000000;
	imm = 32'h00000000;
	B = 1'b0;
	BEQ = 1'b0;
	JMP = 1'b0;
	RET = 1'b0;
	#5;
	if(Branch == 1'b1) begin
		$display("Branch signal high with no branch inst\n");
		errors++;
	end
	PC = 32'h00000100;
	imm = 32'h0000F000;
	B = 1'b1;
	#5;
	if(Branch == 1'b1) begin
		$display("Branch signal high on B signal with equal regs\n");
		errors++;
	end
	Reg0Out = 32'h0000000F;
	Reg1Out = 32'h000000F0;
	#5;
	if(Branch == 1'b0) begin
		$display("Branch signal low on B signal with inequal regs\n");
		errors++;
	end
	B = 1'b0;
	BEQ = 1'b1;
	#5;
	if(Branch == 1'b1) begin
		$display("Branch signal high on BEQ signal with inequal regs\n");
		errors++;
	end
	Reg0Out = 32'h000000F0;
	Reg1Out = 32'h000000F0;
	#5;
	if(Branch == 1'b0) begin
		$display("Branch signal low on BEQ signal with equal regs\n");
		errors++;
	end
	BEQ = 1'b0;
	JMP = 1'b1;
	#5;
	if(Branch == 1'b0) begin
		$display("Branch signal low on JMP signal\n");
		errors++;
	end
	if(BrPC != 32'h0000F100) begin //PC must be equal to PC + imm (Pipelined version)
		$display("BrPC not equal to Reg0 on a RET signal\n");
		errors++;
	end
	JMP = 1'b0;
	RET = 1'b1;
	#5;
	if(Branch == 1'b0) begin
		$display("Branch signal low on RET signal\n");
		errors++;
	end
	if(BrPC != 32'h000000F0) begin //PC must be equal to R0
		$display("BrPC not equal to Reg0 on a RET signal\n");
		errors++;
	end
	#5;
	if(errors > 0) begin
		$display("ERROR: tesbench not passed\n");
	end else begin
		$display("Test Passed!");
	end
	$display("Simulation end\n");
	$stop();
end

endmodule
