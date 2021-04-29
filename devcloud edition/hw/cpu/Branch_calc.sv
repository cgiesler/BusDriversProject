//Version 1.0
module Branch_calc (
	input [31:0] PC, Reg0Out, Reg1Out, imm,
	input B, BEQ, JMP, RET,
	output [31:0] BrPC, nBrPC,
	output Branch, notBranch
);

assign BrPC = RET ? (Reg0Out) : (PC + imm + 4);
assign notBranch = (B | BEQ) & (~Branch);
assign nBrPC = PC + 4;
assign Branch = B ? Reg0Out != Reg1Out :
				BEQ ? Reg0Out == Reg1Out :
				(JMP | RET) ? 1'b1 : 1'b0;

/*always_comb begin
	if(B) begin
		Branch = Reg0Out != Reg1Out;
	end else if(BEQ) begin
		Branch = Reg0Out == Reg1Out;
	end else if(JMP | RET) begin
		Branch = 1'b1;
	end else begin
		Branch = 1'b0;
	end
end */

endmodule
