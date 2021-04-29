//Version 1.0
module imm_extender (
	input [1:0] imm_sel,
	input [26:0] inst,
	output [31:0] imm_out
);

assign imm_out = imm_sel == 2'b00 ? ({{15{inst[16]}}, inst[16:0]}) :
				imm_sel == 2'b01 ? ({{10{inst[21]}}, inst[21:0]}) :
				({{5{inst[26]}}, inst[26:0]});

endmodule
