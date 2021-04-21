module execute(
  input[31:0] RegData0, RegData1, SPout, imm, PC,
  input[4:0] opcode,
  input MemInSel,
  input [1:0] ALU_A_SEL, ALU_B_SEL,
  output [31:0] exeOut, RegData1_o, addrOut
);

//Instantiate modules//
//Determine inputs
logic [31:0] ALU_A_in, ALU_B_in, ALUOut;
assign ALU_A_in = (ALU_A_SEL == 2'b00) ? RegData0 : 
					(ALU_A_SEL == 2'b01) ? SPout : PC;
assign ALU_B_in = (ALU_B_SEL == 2'b10) ? 32'h00000004 : 
				(ALU_B_SEL == 2'b01) ? imm : RegData1;

//ALU
alu ALU(.*);

//Determine outputs
assign exeOut = ALUOut;
assign addrOut = MemInSel ? SPout : ALUOut;
assign RegData1_o = RegData1;

endmodule

