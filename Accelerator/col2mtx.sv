/*
    Fits the incoming data into a square matrix for use
    It will discard any incoming data after full, so it must be rst every time before using
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
logic [$clog2(DIM)+1:0] countX, countY;
integer x, y;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        countX <= 0;
        countY <= 0;
    end else if (countX + 4 > m) begin
        countX <= countX + 4 - m;
        countY <= countY + 1;
    end else begin
        countX <= countX + 4;
        countY <= countY;
    end
end

always_comb begin : DATAwrite
    for (x = 0 ; x < m ; x++) begin
        for (y = 0 ; y < n ; y++) begin
            // if the respective cell in DATA
            // TODO: endianess affect write order?
            // (x, y) for cell number, m is the number of rows to be used
            if (en) begin
                if (x + y * m == countX + countY * m) begin
                    OUT[x][y] = IN[31:24];
                end else if (x + y * m == countX + countY * m + 1) begin
                    OUT[x][y] = IN[23:16];
                end else if (x + y * m == countX + countY * m + 2) begin
                    OUT[x][y] = IN[15:8];
                end else if (x + y * m == countX + countY * m + 3) begin
                    OUT[x][y] = IN[7:0];
                end
            end
        end    
    end
    full = 0;
    if (countX >= m && countY >= n) begin
        full = 1;
    end
end

endmodule