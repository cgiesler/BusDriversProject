/*
    Fits the incoming data into a square matrix for use
    It will discard any incoming data after full, so it must be rst every time before using
    FIXME: Regions outside needed will be X unless written before
*/
module col2mtx
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input clk, rst_n, en,
    input [$clog2(DIM):0] m, n,
    input [DIM-1:0] IN,
    output logic [BITS-1:0] OUT [DIM-1:0][DIM-1:0],
    output logic full
);
logic [$clog2(DIM)+1:0] countCol, countRow;
logic [$clog2(DIM)+1:0] row, col;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        countCol <= 0;
        countRow <= 0;
    end else if (countCol + 4 > m) begin
        countCol <= countCol + 4 - m;
        countRow <= countRow + 1;
    end else begin
        countCol <= countCol + 4;
        countRow <= countRow;
    end
end

always @(posedge clk, negedge rst_n) begin : DATAwrite
    for (row = 0 ; row < m ; row++) begin
        for (col = 0 ; col < n ; col++) begin
            if (!rst_n) begin
                OUT[row][col] = 0;
            end else if (en) begin
                if (col + row * m == countCol + countRow * m) begin
                    OUT[row][col] = IN[31:24];
                end else if (col + row * m == countCol + countRow * m + 1) begin
                    OUT[row][col] = IN[23:16];
                end else if (col + row * m == countCol + countRow * m + 2 ) begin
                    OUT[row][col] = IN[15:8];
                end else if (col + row * m == countCol + countRow * m + 3 ) begin
                    OUT[row][col] = IN[7:0];
                end
            end
        end    
    end
end

assign full = countCol + 4 >= m && countRow >= n - 1 ? 1 : 0;

endmodule