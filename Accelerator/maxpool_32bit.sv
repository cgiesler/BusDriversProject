module maxpool_32bit
#(
    parameter BITS = 8,
    parameter DIM = 32
)
(
    input clk, rst_n, en, WrEn,
    input [31:0] dataIn,
    input [31:0] m, p, // m*p is the dimension of the matrix coming in
    output [31:0] dataOut
);
// if en & WrEn, keep writing DATA until a row is filled
// if en & ~WrEn, start calculating dataOut
logic [BITS-1:0] DATA [DIM-1:0][DIM-1:0]; // 1kB
logic [BITS-1:0] after [DIM/2-1:0][DIM/2-1:0]; // 256B
// logic [63:0] maxcount = m*p;
logic [6:0] countm, countp;
integer x, y;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        countm <= 0;
        countp <= 0;
    end else if (countm + 4 > m) begin
        countm <= countm + 4 - m;
        countp <= countp + 1;
    end else begin
        countm <= countm + 4;
        countp <= countp;
    end
end

genvar i, j;
generate
    for (i = 0 ; i < DIM/2 ; i = i + 2) begin
        for (j = 0 ; j < DIM/2 ; j = j + 2) begin
            ds2by2unit #(.BITS(BITS)) dsing(.IN({{DATA[i][j],DATA[i][j+1]},{DATA[i+1][j],DATA[i+1][j+1]}}),.OUT(after[i/2][j/2]));
        end
    end
endgenerate

always_comb begin : DATAwrite
    for (x = 0 ; x < m ; x++) begin
        for (y = 0 ; y < p ; y++) begin
            // if the respective cell in DATA
            // TODO: endianess affect write order?
            if (en & WrEn) begin
                if (x + y * m == countm + countp * m) begin
                    DATA[x][y] = dataIn[31:24];
                end else if (x + y * m == countm + countp * m + 1) begin
                    DATA[x][y] = dataIn[23:16];
                end else if (x + y * m == countm + countp * m + 2) begin
                    DATA[x][y] = dataIn[15:8];
                end else if (x + y * m == countm + countp * m + 3) begin
                    DATA[x][y] = dataIn[7:0];
                end
            end
        end
    end
end

    

    
endmodule