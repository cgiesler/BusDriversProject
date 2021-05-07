module execute(
  input[31:0] RegData0, RegData1, SPout, imm, PC, M_exeOut, WbData,
  input[4:0] opcode,
  input MemInSel, M_X_r0, M_X_r1, W_X_r0, W_X_r1, SP_forw,
  input [1:0] ALU_A_SEL, ALU_B_SEL,
  output [31:0] exeOut, RegData1_o, addrOut
);

//Instantiate modules//
//Determine inputs
logic [31:0] ALU_A_in, ALU_B_in, ALUOut, ALURData0, ALURData1, SPexe;
assign ALURData0 = M_X_r0 ? M_exeOut : 
					W_X_r0 ? WbData : RegData0;
assign ALURData1 = M_X_r1 ? M_exeOut : 
					W_X_r1 ? WbData : RegData1;
					
assign SPexe = SP_forw ? M_exeOut : SPout;

assign ALU_A_in = (ALU_A_SEL == 2'b00) ? ALURData0 : 
					(ALU_A_SEL == 2'b01) ? SPexe : PC;
assign ALU_B_in = (ALU_B_SEL == 2'b10) ? 32'h00000004 : 
				(ALU_B_SEL == 2'b01) ? imm : ALURData1;

//ALU
alu ALU(.*);

//Determine outputs
assign exeOut = ALUOut;
assign addrOut = MemInSel ? SPexe : ALUOut;
assign RegData1_o = ALURData1;

endmodule

