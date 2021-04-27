module MATMUL 
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input clk, rst_n, en,
    input [$clog2(DIM):0] m, n, p,
    input [BITS-1:0] matrixDataA [DIM-1:0][DIM*2-2:0],
    input [BITS-1:0] matrixDataB [DIM*2-2:0][DIM-1:0],
    output logic [BITS*2-1:0] dataOut [DIM-1:0][DIM-1:0],
    output done
);

logic [6:0] count;
logic [BITS-1:0] Ain[DIM-1:0], Bin[DIM-1:0];
logic signed [BITS*2-1:0] Cout [DIM-1:0][DIM-1:0];


always @(posedge clk, negedge rst_n) begin
    if (!rst_n || count > DIM*2-2) begin
        count <= 0;
    end else if (en == 1) begin
        count <= count + 1;
    end
end

systolic_array #(.BITS(BITS), .DIM(DIM))
SysArrayDUT (.*, .A(Ain), .B(Bin), .Cout(Cout));

always_comb begin : DataFeeder
    for (int i = 0 ; i < DIM ; i++) begin
        Ain[i] = matrixDataA[i][DIM*2-2-count];
        Bin[i] = matrixDataB[DIM*2-2-count][i];
    end
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            dataOut[i][j] = Cout[i][j] > 0 ? Cout[i][j] : 0; // ReLu
        end
    end
end

assign done = count == DIM*2-2 ? 1 : 0;

endmodule