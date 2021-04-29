/*
   CS/ECE 554 Spring '21
  
   Filename        : write_back.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/

// Should stay the same, subject to change for the pipelined version of the processor
module write_back 
	#(parameter N = 32)
(
	input	[N-1:0]	exeOut, 	//  Output from the ALU
	input	[N-1:0]	MemOut, 	//  MemOut signal is instantiated outside of the CPU, 
								//  comes from the memory controller. 

	input	[N-1:0]	PCInc4, 	//  Indicates if the current PC needs. 
	input	[4:0]	Rx, 		//  Register number that comes from the Op Code 
								//  from the current Instruction. 
	input	[4:0]	LR, 		//  Link Register Address 
	input	[1:0]	WbDataSel,	//  Selects if Write Back should be enabled or not 
								//  depending on the Instruction via what data is sent out

	input			WbRegSel, 	//  Selects if Write Back should be enabled or not depending 
								//  on the Instruction via what register the data should be written to 

	output	[N-1:0]	WbData, 	//  Write back data to be sent to the Register File within Decode 
	output	[4:0]	WbReg 	//  The register the Write back data should be written to within 
								//  the Register File in Decode 
);

	// 2:1 Mux
	assign WbReg = (WbRegSel)?(/* 1 */ LR):(/* 0 */ Rx);

	// 4:1 Mux
	assign WbData = (WbDataSel[1])?( 
					(WbDataSel[0])?(exeOut /* 11 */):(MemOut/* 10 */)  
					):(PCInc4 /* 01 or 00 */);
   
endmodule
