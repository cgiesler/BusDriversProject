module MATMUL_tb ();

localparam BITS = 8; // bit number of each pixel of input data
localparam DIM = 32; // Maximum dimension of any feature map

logic clk, rst_n, en, WrEn;
logic [$clog2(DIM):0] m, n, p;
logic [BITS-1:0] matrixDataA [DIM-1:0][DIM*2-2:0];
logic [BITS-1:0] matrixDataB [DIM*2-2:0][DIM-1:0];
logic [BITS-1:0] dataOut [DIM-1:0][DIM-1:0];

MATMUL iDUT(.*);




endmodule