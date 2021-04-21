module decode(
  input clk, rst_n, wEn, SPwe_in, 
  input [31:0] inst, wData, SPin, PC, 
  input [4:0] wReg,
  output [31:0] Reg0Out, Reg1Out, imm, BrPC, PC_o,
  output reg [31:0] SPout,
  output Branch, MemInSel, memwr, memrd, WbRegSel, SPwe_o, wEn_o,
  output [1:0] WbDataSel, ALU_A_SEL, ALU_B_SEL
);

//Instantiate modules//
//Reg File

logic[4:0] Reg0In, Reg1In;
logic[1:0] Reg0Sel;
logic Reg1Sel;

//Determine RegFile inputs
always_comb begin
	case(Reg0Sel) 
		(2'b00): begin //Rx
			Reg0In = inst[26:22];
		end
		(2'b01): begin //Ry
			Reg0In = inst[21:17];
		end
		(2'b10): begin //LR
			Reg0In = 5'b11110;
		end
		(2'b11): begin //ILR
			Reg0In = 5'b11111;
		end
		default: begin //default to Ry
			Reg0In = inst[21:17];
		end
	endcase
end

assign Reg1In = Reg1Sel ? (inst[26:22]) : (inst[16:12]); //Rx : Rz
Register_File regFile(.clk(clk), .rst_n(rst_n), .wEn(wEn), .Reg0(Reg0In),
			.Reg1(Reg1In), .Reg0Out(Reg0Out), .Reg1Out(Reg1Out), .wReg(wReg), .wData(wData));

//Immediate Extender
logic [31:0] imm_out;
logic [1:0] imm_sel;
imm_extender immExt(.imm_sel(imm_sel), .inst(inst[26:0]), .imm_out(imm_out));
assign imm = imm_out;

//Branch
logic B, BEQ, JMP, RET;
Branch_calc br_mod(.Reg0Out(Reg0Out), .Reg1Out(Reg1Out), .PC(PC), .imm(imm_out), 
		.B(B), .BEQ(BEQ), .JMP(JMP), .RET(RET), .BrPC(BrPC), .Branch(Branch));

//Control
Control con_sig(.opcode(inst[31:27]), .Reg1Sel(Reg1Sel), .wEn(wEn_o), 
	.ALU_A_SEL(ALU_A_SEL), .ALU_B_SEL(ALU_B_SEL), .B(B), .BEQ(BEQ), 
	.JMP(JMP), .RET(RET), .MemInSel(MemInSel), .memwr(memwr), .memrd(memrd), .WbDataSel(WbDataSel), 
	.WbRegSel(WbRegSel), .SPwe(SPwe_o), .Reg0Sel(Reg0Sel), .imm_sel(imm_sel));

//Stack Pointer
always_ff@(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		SPout <= 32'h00003000; //Start of stack
	end else if (SPwe_in) begin
		SPout <= SPin;
	end
end

endmodule
