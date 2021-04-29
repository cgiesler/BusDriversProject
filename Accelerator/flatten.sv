/*
    Fits the incoming m*n sqaure into multiple 32bit line
    FIXME: Regions outside needed will be X unless written before
*/
module flatten
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input [$clog2(DIM):0] m, n,
    input [BITS-1:0] IN [DIM-1:0][DIM-1:0],
    output logic [BITS-1:0] OUT [DIM*DIM-1:0]
);
// logic [$clog2(DIM)+1:0] countCol, countRow;
// logic [$clog2(DIM)+1:0] row, col;
always_comb begin : DataFit
    for (int row = 0 ; row < DIM ; row++) begin
        for (int col = 0 ; col < DIM ; col++) begin
            if (row < m && col < n) begin
                OUT[col + row * DIM] = IN[row][col];
            end else begin
                OUT[col + row * DIM] = 0;
            end
        end
    end
end

endmodule