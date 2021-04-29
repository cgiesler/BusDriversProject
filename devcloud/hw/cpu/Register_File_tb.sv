module Register_File_tb();

logic clk, rst_n, wEn;
logic [4:0] Reg0, Reg1, wReg;
logic [31:0] wData, Reg0Out, Reg1Out;

Register_File DUT(.*);

int errors;
initial begin
	clk = 0;
	rst_n = 0;
	wEn = 0;
	Reg0 = 0;
	Reg1 = 0;
	wReg = 0;
	wData = 0;
	@(negedge clk);
	if(Reg0Out != 32'h0 | Reg1Out != 32'h0) begin
		$display("ERROR: Register file not reset properly");
		errors++;
	end
	rst_n = 1;
	wEn = 1;
	//Write registers
	for(int i = 0; i < 32; i++) begin
		wReg = i;
		wData = i;
		@(negedge clk);
	end
	wEn = 0;
	@(negedge clk);
	//Check
	for(int i = 0; i < 32; i++) begin
		Reg0 = i;
		Reg1 = 31-i;
		@(negedge clk);
		if(Reg0Out != i) begin
			$display("ERROR: Reg0Out incorrect - %h", Reg0Out);
			errors++;
		end
		if(Reg1Out != 31 - i) begin
			$display("ERROR: Reg1Out incorrect - %h", Reg1Out);
			errors++;
		end
	end

	//Fake Write registers (wEn low)
	for(int i = 0; i < 32; i++) begin
		wReg = i;
		wData = 32'hBEEEBEEE;
		@(negedge clk);
	end
	
	//Simulatneous Check
	for(int i = 0; i < 32; i++) begin
		Reg0 = i;
		Reg1 = i;
		@(negedge clk);
		if(Reg0Out != i) begin
			$display("ERROR: Reg0Out incorrect - %h", Reg0Out);
			errors++;
		end
		if(Reg1Out != i) begin
			$display("ERROR: Reg1Out incorrect - %h", Reg1Out);
			errors++;
		end
	end

	if(errors > 0) begin
		$display("Test failed, errors found: $d", errors);
	end else begin
		$display("Test passed!");
	end
	$display("Simulation complete");
	$stop();
end

always begin
	#5 clk = ~clk;
end

endmodule

