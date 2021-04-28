/*
   CS/ECE 552 Spring '21
  
   Filename        : Fetch.v
   Description     : First State of the 5-Stage Processor
*/


// TODO: Branch prediction and funcitonality with LastPC which involved the pipelined verison of the CPU
module fetch #(parameter N=32) 
(
	
	output [N-1:0] inst,	// The line of instruction fetched from the instruction memory. 
											// It will be decoded to check if it is a branch instruction in 
											// order to perform branch prediction 

	output reg [N-1:0] PC,			// The incremented PC which will be stored in the IFDE pipeline 
											// register should the necessity of a branch not taken flush arise 

	input [N-1:0] LastPC,			// If branch weren’t taken, flush the branch PC and revert to the 
											// previous PC 
	input [N-1:0] BrPC,

	input rst_n, clk, Branch, halt, F_en, 	// Reset PC register on low 
	input [1:0] Interrupt,
	output [1:0] inter_o
);
	
	logic [31:0] nextPC, PCInc4, mem_out;
	
	// PC Register
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			PC <= 32'h00000000;
		end else if(F_en) begin
			PC <= nextPC;
		end else begin
			PC <= PC;
		end
	end
	
	assign inst = Interrupt[1] ? 32'hA7C00000 : //Offset to be determined
				Interrupt[0] ? 32'hA7C00000 : mem_out;
	// Instruction Memory
	memory2c instr_mem(.data_out(mem_out), .data_in(32'h0), .addr(PC >> 2 /*temp fix*/), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(~rst_n));

	// Sign Extension of Branch Offset (used in multistage)
	//assign BranchOffset = {15{{Instruction[16]}}, Instruction[16:0]};

	assign PCInc4 = PC + 4;

	// Mux right after the 2 adders
	assign nextPC = (Branch)?(BrPC):(PCInc4);
	assign inter_o = Interrupt;

	// Mux right after the 2 adders (used in multistage)
	//assign adderMuxOutput = (Flush)?(LastPC):(pcBranch);
   
endmodule
