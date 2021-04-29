module execute_tb();

logic[31:0] RegData0, RegData1, SPout, imm, exeOut, RegData1_o, PC;
logic MemInSel;
logic [4:0] opcode;
logic [1:0] ALU_A_SEL, ALU_B_SEL;

logic[1:0] A_SEL_TEMP;
always_comb begin
	if((opcode == 5'b01111) | (opcode == 5'b10000)) begin //PUSH and POP
		A_SEL_TEMP = 2'b01;
	end else if (opcode == 5'b10100) begin //Save PC+4 Val (FUN and INT)
		A_SEL_TEMP = 2'b10;
	end else begin
		A_SEL_TEMP = 2'b00;
	end
end
assign ALU_A_SEL = A_SEL_TEMP; //PUSH and POP
logic [1:0] B_SEL_TEMP;
always_comb begin
	if( (opcode == 5'b00001) | (opcode == 5'b00010) |
			(opcode[4:1] == 4'b0010) | (opcode == 5'b00110) |
			(opcode[4:1] == 4'b0110) | (opcode == 5'b01110)) begin //Imm
		B_SEL_TEMP = 2'b01;
	end else if ((opcode == 5'b10000) | (opcode == 5'b01111)) begin //4
		B_SEL_TEMP = 2'b10;
	end else begin //Reg1
		B_SEL_TEMP = 2'b00;
	end
end
assign ALU_B_SEL = B_SEL_TEMP;
assign MemInSel = (opcode == 5'b01111); //Memory address select PUSH

execute DUT(.*);

int errors;

//Simple testbench, check multiplexer paths
initial begin
	RegData0 = 1;
	SPout = 4;
	RegData1 = 2;
	PC = 8;
	imm = 3;
	opcode = 5'h00;
	#5;
	if(exeOut != 3) begin
		$display("Error on ADD operation");
		errors++;
	end
	opcode = 5'h01;
	#5;
	if(exeOut != 4) begin
		$display("Error on ADD imm operation");
		errors++;
	end
	opcode = 5'h10;
	#5;
	if(exeOut != 0) begin
		$display("Error on POP operation, SPOut not decrementing");
		errors++;
	end
	opcode = 5'h0F;
	#5;
	if(exeOut != 4) begin
		$display("Error on PUSH operation, SPOut not passing through");
		errors++;
	end
	
	
	if(errors > 0) begin
		$display("Test failed, errors found: $d", errors);
	end else begin
		$display("Test passed!");
	end
	$display("Simulation complete");
	$stop();
end

endmodule

