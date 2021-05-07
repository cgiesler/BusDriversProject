module imm_extender_tb();

logic [1:0] imm_sel;
logic [26:0] inst;
logic [31:0] imm_out;

imm_extender DUT(.*);

int errors = 0;

initial begin
	imm_sel = 2'b00;
	inst = 27'h0010000;
	#5;
	if(imm_out != 32'hFFFF0000) begin
		$display("17 bit immediate sign not extended\n");
		errors++;
	end
	inst = 27'h0008000;
	#5;
	if(imm_out != 32'h0008000) begin
		$display("17 bit immediate sign extended with 0 sign bit\n");
		errors++;
	end
	imm_sel = 2'b01;
	inst = 27'h0200000;
	#5;
	if(imm_out != 32'hFFE00000) begin
		$display("22 bit immediate sign not extended\n");
		errors++;
	end
	inst = 27'h0100000;
	#5;
	if(imm_out != 32'h00100000) begin
		$display("22 bit immediate sign extended with 0 sign bit\n");
		errors++;
	end
	imm_sel = 2'b11;
	inst = 27'h4000000;
	#5;
	if(imm_out != 32'hFC000000) begin
		$display("26 bit immediate sign not extended\n");
		errors++;
	end
	inst = 27'h2000000;
	#5;
	if(imm_out != 32'h0100000) begin
		$display("26 bit immediate sign extended with 0 sign bit\n");
		errors++;
	end
	#5;
	if(errors > 0) begin
		$display("Test Failed! Errors found\n");
	end else begin
		$display("Test Passed!");
	end
	$display("Simulation over\n");
	$stop();
end

endmodule
