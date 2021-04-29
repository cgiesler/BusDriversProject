module maxpool 
#(
    parameter BITS = 8,
    parameter DIM = 32
)
(
    input clk, 
    input [BITS*2-1:0] dataIn [DIM-1:0][DIM-1:0], // 1kB
    // input [31:0] m, p, // m*p is the dimension of the matrix coming in
    output [BITS*2-1:0] dataOut [DIM/2-1:0][DIM/2-1:0] // 256B
);
// if en & WrEn, keep writing DATA until a row is filled
// if en & ~WrEn, start calculating dataOut

genvar i, j;
generate
    for (i = 0 ; i < DIM ; i = i + 2) begin
        for (j = 0 ; j < DIM ; j = j + 2) begin
            ds2by2unit #(.BITS(BITS)) dsing(.IN({{dataIn[i][j],dataIn[i][j+1]},{dataIn[i+1][j],dataIn[i+1][j+1]}}),.OUT(dataOut[i/2][j/2]));
        end
    end
endgenerate
    
endmodule