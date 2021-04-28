module Forwarding_Unit(
  input [4:0] d_op, d_regIn0, d_regIn1,
  		x_op, x_regX, x_regIn0, x_regIn1,
		m_op, m_regX, m_regExe, m_regData,
		w_op, w_regOut,
  input valid,
  output X_D_r0, X_D_r1, M_D_r0, M_D_r1, FD_stall,
	  X_X_r0, X_X_r1, DX_stall, XM_stall,
	  M_X_r0, M_X_r1, M_M_r, SP_forw,
	  W_X_r0, W_X_r1, W_M_r1
);

logic X_D_r0t, X_D_r1t, M_D_r0t, M_D_r1t, M_D_stallt, FD_stallt,
	  X_X_r0t, X_X_r1t, M_X_stallt, XM_stallt, DX_stallt,
	  M_X_r0t, M_X_r1t, M_M_rt, xALUop, mALUop, wALUop,
	  W_M_r1t, W_X_r0t, W_X_r1t, SP_forwt, xALUopM;

assign xALUop = x_op[4:3] == 2'b00 | x_op[4:1] == 4'b0100 | x_op == 5'b01100;
assign xALUopM = x_op[4:3] == 2'b00 | x_op[4:1] == 4'b0100;
assign mALUop = m_op[4:3] == 2'b00 | m_op[4:1] == 4'b0100 | m_op == 5'b01100;
assign wALUop = w_op[4:3] == 2'b00 | w_op[4:1] == 4'b0100 | w_op == 5'b01100;
assign w_wEn = (w_op[4:3] == 2'b00) | (w_op[3:1] == 3'b100) | 
		(w_op == 5'b01100) | (w_op == 5'b01101) | (w_op == 5'b10000) | (w_op == 5'b10100);
assign x_wEn = (x_op[4:3] == 2'b00) | (x_op[3:1] == 3'b100) | 
		(x_op == 5'b01100) | (x_op == 5'b01101) | (x_op == 5'b10000) | (x_op == 5'b10100);

//XM stall (Mem read to X)
always_comb begin
	XM_stallt = 1'b0;
	if((m_op == 5'b01101 | m_op == 5'b10000) & x_wEn) begin //memrd
		if(m_regData == x_regIn0 | m_regData == x_regIn1) begin
			XM_stallt = 1'b1;
		end
		if(!valid) begin
			XM_stallt = 1'b1;
		end
	end
end
assign XM_stall = XM_stallt;

//DX stall (Mem read to D)
always_comb begin
	DX_stallt = 1'b0;
	if((m_op == 5'b01101 | m_op == 5'b10000) & (d_op == 5'b10001 | d_op == 5'b10010 | d_op == 5'b10100 | d_op == 5'b10110)) begin //memrd
		if(m_regData == d_regIn0 | m_regData == d_regIn1) begin
			DX_stallt = 1'b1;
		end
	end
end
assign DX_stall = DX_stallt | XM_stall;

//FD stall
always_comb begin
	FD_stallt = 1'b0;
end
assign FD_stall = FD_stallt | DX_stall;

//Forward to store data
always_comb begin
	W_M_r1t = 1'b0;
	if(w_wEn & (m_op == 5'b01110 | m_op == 5'b01111)) begin
		if(w_regOut == m_regData) begin
			W_M_r1t = 1'b1;
		end
	end
end
assign W_M_r1 = W_M_r1t;

//Forward to ALU inputs
always_comb begin
	M_X_r0t = 1'b0;
	if(mALUop & (m_regX == x_regIn0) & !(x_op == 5'b01100)) begin
		M_X_r0t = 1'b1;
	end
	if((m_op == 5'b01100) & (m_regX == x_regIn0) & !(x_op == 5'b01100)) begin
		M_X_r0t = 1'b1;
	end
end
assign M_X_r0 = M_X_r0t;

always_comb begin
	M_X_r1t = 1'b0;
	if(mALUop & (m_regX == x_regIn1) & !(x_op == 5'b01100)) begin
		M_X_r1t = 1'b1;
	end
	if((m_op == 5'b01100) & (m_regX == x_regIn1) & !(x_op == 5'b01100)) begin
		M_X_r1t = 1'b1;
	end
end
assign M_X_r1 = M_X_r1t;

always_comb begin
	W_X_r0t = 1'b0;
	if(w_wEn & (w_regOut == x_regIn0) & !(x_op == 5'b01100)) begin
		W_X_r0t = 1'b1;
	end
end
assign W_X_r0 = W_X_r0t;

always_comb begin
	W_X_r1t = 1'b0;
	if(w_wEn & (w_regOut == x_regIn1) & !(x_op == 5'b01100)) begin
		W_X_r1t = 1'b1;
	end
end
assign W_X_r1 = W_X_r1t;

//Stack Pointer forwarding
always_comb begin
	SP_forwt = 1'b0;
	if(m_op == 5'b01111 | m_op == 5'b10000) begin
		if(x_op == 5'b01111 | x_op == 5'b10000) begin
			SP_forwt = 1'b1;
		end
	end
end
assign SP_forw = SP_forwt;

//ALU output to Branch module
always_comb begin
	X_D_r0t = 1'b0;
	if(d_op == 5'b10001 | d_op == 5'b10010 | d_op == 5'b10100 | d_op == 5'b10110) begin
		if(xALUop) begin
			if(d_regIn0 == x_regX) begin
				X_D_r0t = 1'b1;
			end
		end
	end
end
assign X_D_r0 = X_D_r0t;

always_comb begin	
	X_D_r1t = 1'b0;
	if(d_op == 5'b10001 | d_op == 5'b10010 | d_op == 5'b10100 | d_op == 5'b10110) begin
		if(xALUop) begin
			if(d_regIn1 == x_regX) begin
				X_D_r1t = 1'b1;
			end
		end
	end
end
assign X_D_r1 = X_D_r1t;

//ALU output (from mem) to Branch module
always_comb begin	
	M_D_r0t = 1'b0;
	if(d_op == 5'b10001 | d_op == 5'b10010 | d_op == 5'b10100 | d_op == 5'b10110) begin
		if(mALUop) begin
			if(d_regIn1 == m_regX) begin
				M_D_r0t = 1'b1;
			end
		end
	end
end
assign M_D_r0 = M_D_r0t;

always_comb begin
	M_D_r1t = 1'b0;
	if(d_op == 5'b10001 | d_op == 5'b10010 | d_op == 5'b10100 | d_op == 5'b10110) begin
		if(mALUop) begin
			if(d_regIn1 == m_regX) begin
				M_D_r1t = 1'b1;
			end
		end
	end
end
assign M_D_r1 = M_D_r1t;

endmodule

