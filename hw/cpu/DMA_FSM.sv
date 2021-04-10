//Module to initiate DMA controller transactions (Read layer inputs, images,
//etc.)
module DMA_FSM(
  input clk, rst_n, nextTransaction,
  output en,
  output [31:0] MemDataOut, MemAddr
);

//Transaction order:
//Weights
//Biases ?
//Image inputs
	//States NOT final yet, need to discuss with DMA
typedef enum {INIT, WEIGHTS, DIMENSIONS, BIASES, IMAGES} state_t;
reg [2:0] currState;
logic [2:0] nextState;

//state control
always_comb begin
	nextState = INIT; 
	case(currState) 
		INIT: break;
		WEIGHTS: break;
		DIMENSIONS: break;
		BIASES: break;
		IMAGES: break;
		default: break;
	endcase
end

//load next state
always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		currState <= INIT;
	end else begin
		currState <= nextState;
	end
end

endmodule

