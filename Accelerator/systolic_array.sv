module systolic_array
#(
parameter BITS = 8,
parameter DIM = 32
)
(
input clk,rst_n,en,
// input WrEn,
input signed [BITS-1:0] A [DIM-1:0],
input signed [BITS-1:0] B [DIM-1:0],
// input [$clog2(DIM):0] row,
output signed [BITS*2-1:0] Cout [DIM-1:0][DIM-1:0]
);

logic signed [BITS-1:0] MACAin[DIM-1:0][DIM-1:0],
MACBin[DIM-1:0][DIM-1:0],
MACAout[DIM-1:0][DIM-1:0],
MACBout[DIM-1:0][DIM-1:0];
logic signed [BITS*2-1:0] MACCin[DIM-1:0][DIM-1:0],
MACCout[DIM-1:0][DIM-1:0];
logic signed MACWrEn[DIM-1:0][DIM-1:0];

assign Cout = MACCout;

tpumac iDUT[DIM-1:0][DIM-1:0] (
.clk(clk), .rst_n(rst_n), .WrEn(MACWrEn), .en(en),
.Ain(MACAin), .Bin(MACBin), .Cin(MACCin),
.Aout(MACAout), .Bout(MACBout), .Cout(MACCout)
);

// assign Cout = MACCout[Crow];

// always_comb begin : CrowManager
//     for (int i = 0 ; i < DIM ; i++) begin
//         for (int j = 0 ; j < DIM ; j++) begin
//             if (Crow == i) MACWrEn[i][j] = WrEn;
//             else MACWrEn[i][j] = 0;
//             MACCin[i][j] = Cin[j];
//         end
//     end
// end

always_comb begin : ABCManager
    for (int i = 0 ; i < DIM ; i++) begin
        MACAin[i][0] = A[i];
        MACBin[0][i] = B[i];
    end
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 1 ; j < DIM ; j++) begin
            MACAin[i][j] = MACAout[i][j-1];
        end
    end
    for (int i = 1 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            MACBin[i][j] = MACBout[i-1][j]; 
        end
    end
end

endmodule