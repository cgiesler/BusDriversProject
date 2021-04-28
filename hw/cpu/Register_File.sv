//Version 0.1
module Register_File(
  input[4:0] Reg0, Reg1, wReg,
  input clk, rst_n, wEn,
  input[31:0] wData,
  output[31:0] Reg0Out, Reg1Out
);

reg [31:0] registers [31:0];

//TODO: Implement bypassing for pipelined CPU
assign Reg0Out = ((Reg0 == wReg) & wEn) ? wData : registers[Reg0];
assign Reg1Out = ((Reg1 == wReg) & wEn) ? wData : registers[Reg1];

always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(int i = 0; i < 32; i=i+1) begin
			registers[i] <= 32'h00000000;
		end
	end else if (wEn) begin
		registers[wReg] <= wData;
	end else begin
		for(int i = 0; i < 32; i=i+1) begin
			registers[i] <= registers[i];
		end
	end
end

endmodule

