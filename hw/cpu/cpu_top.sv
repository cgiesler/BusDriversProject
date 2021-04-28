module cpu_top(
	input clk, rst_n, nextTransaction, go/*read-done*/,
	input [1:0] Interrupt,
	output ack, en, halt /*done signal*/,
	output [31:0] memDataOut, memAddr, PC //DMA FSM stuff (tbt)
);

logic [31:0] Reg0Out, Reg1Out, imm, BrPC, SPout, SPin, exeOut, addrOut, wData, PC_o;
logic [31:0] inst, LastPC, D_nBrPC, D_SPout, D_Reg0Out;
logic [31:0] FD_PC, FD_inst;
logic [31:0] RegData1_o, RegData0, RegData1;
logic [31:0] Addr, MemDataIn, MemOut;
logic [31:0] WbData;
logic [31:0] PCInc4, W_wData;
logic [4:0] Rx, LR, WbReg, W_wReg;
logic valid, F_en, go_r, F_Flush, D_Branch, M_MemInSel, MW_stall;
logic Branch, MemInSel, memwr, memrd, WbRegSel, SPwe_o, wEn, wEn_o, SPwe_in, CPUValid;
logic [4:0] wReg;
logic [1:0] WbDataSel, ALU_A_SEL, ALU_B_SEL, inter_o, FD_inter, D_ALU_A, D_ALU_B, D_WbDataSel;

logic X_D_r0, X_D_r1, M_D_r0, M_D_r1, FD_stall,
	  X_X_r0, X_X_r1, DX_stall, XM_stall,
	  M_X_r0, M_X_r1, M_M_r, SP_forw,
	  W_X_r0, W_X_r1, W_M_r1;

logic [31:0] M_exeOut, M_addrOut, M_Reg1Out, M_PC4, W_SPin, D_Reg1Out, D_imm;
logic M_memwr, M_memrd, M_WbRegSel, M_SPwe, M_wEn, W_wEn;
logic [1:0] M_WbDataSel;
logic [4:0] m_op, m_regX, m_regExe, m_regData; //Forwarding stuff

logic [31:0] X_Reg0Out, X_Reg1Out, X_imm, X_SPout, X_PC, X_PC4;
logic X_MemInSel, X_memwr, X_memrd, X_WbRegSel, X_SPwe, X_wEn;
logic [1:0] X_WbDataSel, X_ALU_A, X_ALU_B;
logic [4:0] x_op, x_regX, x_regIn0, x_regIn1; //Forwarding stuff

//DMA FSM
assign memDataOut = 32'h0;
assign memAddr = 32'h0;
assign en = 1'b0;
assign LastPC = D_nBrPC;

//Forwarding Unit (pipelined)
Forwarding_Unit fu(.*);

//Interrupt handler in Fetch
assign ack = |FD_inter;

//Fetch
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		go_r <= 1'b0;
	end else if (go) begin
		go_r <= 1'b1;
	end else if (&inst[31:27]) begin
		go_r <= 1'b0;
	end
end
assign F_en = go_r & !(FD_stall) & !(&inst[31:27]);
fetch fetch_stage(.*);

//F_D Pipeline

assign F_Flush = Branch;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n | F_Flush) begin
		FD_PC <= 32'h00000000;
		FD_inst <= 32'h50000000; //NOP opcode
		FD_inter <= 2'b00;
	end else if (FD_stall) begin
		//hold vals (en low)
		FD_PC <= FD_PC;
		FD_inst <= FD_inst;
		FD_inter <= FD_inter;
	end else begin
		//take vals from F stage
		FD_PC <= PC;
		FD_inst <= inst;
		FD_inter <= inter_o;
	end
end

//Decode
logic [4:0] d_op, d_rx, d_regIn0, d_regIn1; //Forwarding stuff
assign d_op = FD_inst[31:27];
assign d_rx = FD_inst[26:22];
/*assign D_ry = inst[21:17];
assign D_rz = inst[16:12]; 
assign wEn = wEn_o;
assign SPwe_in = SPwe_o;
assign SPin = exeOut;
assign wReg = WbReg;
assign wData = WbData; */

decode dec_stage(.clk(clk), .rst_n(rst_n), .wEn(W_wEn), .SPwe_in(X_SPwe),
				.inst(FD_inst), .wData(W_wData), .SPin(exeOut), .PC(FD_PC),
				.wReg(W_wReg), .Reg0Out(D_Reg0Out), .Reg1Out(D_Reg1Out),
				.imm(D_imm), .BrPC(BrPC), .nBrPC(D_nBrPC), .SPout(D_SPout),
				.Branch(Branch), .notBranch(notBranch), .MemInSel(D_MemInSel),
				.memwr(D_memwr), .memrd(D_memrd), .WbRegSel(D_WbRegSel), .SPwe_o(D_SPwe),
				.wEn_o(D_wEn), .WbDataSel(D_WbDataSel), .ALU_A_SEL(D_ALU_A), .ALU_B_SEL(D_ALU_B),
				.Reg0In(d_regIn0), .Reg1In(d_regIn1), .inter(|FD_inter),
				.M_D_r0(M_D_r0), .M_D_r1(M_D_r1), .X_D_r0(X_D_r0), .X_D_r1(X_D_r1),
				.exeOut(exeOut), .M_exeOut(M_exeOut));

//D_X Pipeline
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X_Reg0Out <= 32'h00000000;
		X_Reg1Out <= 32'h00000000;
		X_imm <= 32'h00000000;
		X_SPout <= 32'h00000000;
		X_PC <= 32'h00000000;
		X_PC4 <= 32'h00000000;
		X_MemInSel <= 1'b0;
		X_memwr <= 1'b0;
		X_memrd <= 1'b0;
		X_WbRegSel <= 1'b0;
		X_SPwe <= 1'b0;
		X_wEn <= 1'b0;
		X_WbDataSel <= 2'b00;
		X_ALU_A <= 2'b00;
		X_ALU_B <= 2'b00;
		x_op <= 5'b01010;
		x_regX <= 5'b00000;
		x_regIn0 <= 5'b00000;
		x_regIn1 <= 5'b00000;
	end else if (DX_stall) begin
		//hold vals (en low)
		X_Reg0Out <= X_Reg0Out;
		X_Reg1Out <= X_Reg1Out;
		X_imm <= X_imm;
		X_SPout <= X_SPout;
		X_PC <= X_PC;
		X_PC4 <= X_PC4;
		X_MemInSel <= X_MemInSel;
		X_memwr <= X_memwr;
		X_memrd <= X_memrd;
		X_WbRegSel <= X_WbRegSel;
		X_SPwe <= X_SPwe;
		X_wEn <= X_wEn;
		X_WbDataSel <= X_WbDataSel;
		X_ALU_A <= X_ALU_A;
		X_ALU_B <= X_ALU_B;
		x_op <= x_op;
		x_regX <= x_regX;
		x_regIn0 <= x_regIn0;
		x_regIn1 <= x_regIn1;
	end else begin
		//take vals from D stage
		X_Reg0Out <= D_Reg0Out;
		X_Reg1Out <= D_Reg1Out;
		X_imm <= D_imm;
		X_SPout <= D_SPout;
		X_PC <= FD_PC;
		X_PC4 <= D_nBrPC;
		X_MemInSel <= D_MemInSel;
		X_memwr <= D_memwr;
		X_memrd <= D_memrd;
		X_WbRegSel <= D_WbRegSel;
		X_SPwe <= D_SPwe;
		X_wEn <= D_wEn;
		X_WbDataSel <= D_WbDataSel;
		X_ALU_A <= D_ALU_A;
		X_ALU_B <= D_ALU_B;
		x_op <= d_op;
		x_regX <= d_rx;
		x_regIn0 <= d_regIn0;
		x_regIn1 <= d_regIn1;
	end
end

//Execute
assign RegData0 = Reg0Out;
assign RegData1 = Reg1Out;
execute exe_stage(.RegData0(X_Reg0Out), .RegData1(X_Reg1Out), .SPout(X_SPout), .imm(X_imm), .opcode(x_op),
				.ALU_A_SEL(X_ALU_A), .ALU_B_SEL(X_ALU_B), .MemInSel(X_MemInSel), .PC(X_PC), 
				.exeOut(exeOut), .addrOut(addrOut), .RegData1_o(RegData1_o), 
				.M_X_r0(M_X_r0), .M_X_r1(M_X_r1), .W_X_r0(W_X_r0), .W_X_r1(W_X_r1), 
				.SP_forw(SP_forw), .M_exeOut(M_exeOut), .WbData(W_wData));

//X_M Pipeline

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		M_addrOut <= 32'h00000000;
		M_exeOut <= 32'h00000000;
		M_Reg1Out <= 32'h00000000;
		M_PC4 <= 32'h00000000;
		M_memwr <= 1'b0;
		M_memrd <= 1'b0;
		M_WbRegSel <= 1'b0;
		M_wEn <= 1'b0;
		M_WbDataSel <= 2'b00;
		m_op <= 5'b01010;
		m_regX <= 5'b00000;
		m_regExe <= 5'b00000;
		m_regData <= 5'b00000;
	end else if (XM_stall) begin
		//hold vals (en low)
		M_addrOut <= M_addrOut;
		M_exeOut <= M_exeOut;
		M_Reg1Out <= M_Reg1Out;
		M_PC4 <= M_PC4;
		M_memwr <= M_memwr;
		M_memrd <= M_memrd;
		M_WbRegSel <= M_WbRegSel;
		M_wEn <= M_wEn;
		M_WbDataSel <= M_WbDataSel;
		m_op <= m_op;
		m_regX <= m_regX;
		m_regExe <= m_regExe;
		m_regData <= m_regData;
	end else begin
		//take vals from X stage
		M_addrOut <= addrOut;
		M_exeOut <= exeOut;
		M_Reg1Out <= RegData1_o;
		M_PC4 <= X_PC4;
		M_MemInSel <= X_MemInSel;
		M_memwr <= X_memwr;
		M_memrd <= X_memrd;
		M_WbRegSel <= X_WbRegSel;
		M_wEn <= X_wEn;
		M_WbDataSel <= X_WbDataSel;
		m_op <= x_op;
		m_regX <= x_regX;
		m_regExe <= x_regIn0;
		m_regData <= x_regIn1;
	end
end

//Mem
//logic valid;
assign Addr = addrOut;
assign MemDataIn = RegData1_o;
memory mem_stage(.clk(clk), .rst_n(rst_n), .halt(&m_op), .memrd(M_memrd), 
				.memwr(M_memwr), .Addr(M_addrOut), .MemDataIn(M_Reg1Out), .MemOut(MemOut),
				.valid(valid), .CPUValid(CPUValid));

//M_W Pipeline
logic [31:0] W_exeOut, W_memOut, W_PC4;
logic [1:0] W_WbDataSel;
logic W_WbRegSel;
logic [4:0] w_op, w_regOut;
assign MW_stall = !valid & M_memrd;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		W_exeOut <= 32'h00000000;
		W_memOut <= 32'h00000000;
		W_PC4 <= 32'h00000000;
		W_WbDataSel <= 2'b00;
		W_WbRegSel <= 1'b0;
		W_wEn <= 1'b0;
		w_op <= 5'b01010;
		w_regOut <= 5'b00000;
	end else if (MW_stall) begin
		//hold vals (en low)
		W_exeOut <= W_exeOut;
		W_memOut <= W_memOut;
		W_PC4 <= W_PC4;
		W_WbDataSel <= W_WbDataSel;
		W_WbRegSel <= W_WbRegSel;
		W_wEn <= W_wEn;
		w_op <= w_op;
		w_regOut <= w_regOut;
	end else begin
		//take vals from F stage
		W_exeOut <= M_exeOut;
		W_memOut <= MemOut;
		W_PC4 <= M_PC4;
		W_WbDataSel <= M_WbDataSel;
		W_WbRegSel <= M_WbRegSel;
		W_wEn <= M_wEn;
		w_op <= m_op;
		w_regOut <= m_regX;
	end
end

//Writeback

assign Rx = w_regOut;
assign LR = w_regOut;
assign PCInc4 = W_PC4; //temp hold
write_back wb_stage(.exeOut(W_exeOut), .MemOut(W_memOut), .PCInc4(PCInc4),
				.Rx(Rx), .LR(LR), .WbDataSel(W_WbDataSel), .WbRegSel(W_WbRegSel),
				.WbReg(W_wReg), .WbData(W_wData));

assign halt = &w_op;

endmodule

