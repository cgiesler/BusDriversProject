module col2mtx_tb ();

localparam BITS = 8;
localparam DIM = 32;

logic clk, rst_n, en;
logic [$clog2(DIM):0] m, n;
logic [DIM-1:0] IN;
logic [BITS-1:0] DATA [DIM-1:0][DIM-1:0];

col2mtx #(BITS, DIM) iDUT(.*);
endmodule