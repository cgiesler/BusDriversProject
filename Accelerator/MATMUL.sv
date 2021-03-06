module MATMUL 
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input clk, rst_n, en,
    input [$clog2(DIM):0] m, n, p,
    input [BITS-1:0] matrixDataA [DIM-1:0][DIM-1:0],
    input [BITS-1:0] matrixDataB [DIM-1:0][DIM-1:0],
    output logic [BITS-1:0] dataOut [DIM-1:0][DIM-1:0],
    // output logic [BITS*2-1:0] dataOut [DIM-1:0][DIM-1:0],
    output logic done
);

logic [$clog2(DIM*4):0] count;
logic [BITS-1:0] Ain[DIM-1:0], Bin[DIM-1:0];
logic signed [BITS*2-1:0] Cout [DIM-1:0][DIM-1:0];
logic [BITS-1:0] OUTA [DIM-1:0][DIM*2-2:0];
logic [BITS-1:0] OUTB [DIM*2-2:0][DIM-1:0];


layoutA #(.BITS(BITS), .DIM(DIM))
LayoutADUT (.INA(matrixDataA),.m(m),.n(n),.OUTA(OUTA));

layoutB #(.BITS(BITS), .DIM(DIM))
LayoutBDUT (.INB(matrixDataB),.n(n),.p(p),.OUTB(OUTB));

systolic_array #(.BITS(BITS), .DIM(DIM))
SysArrayDUT (.*, .A(Ain), .B(Bin), .Cout(Cout));

always @(posedge clk, negedge rst_n) begin
    if (!rst_n || done) begin
        count <= 0;
    end else if (en == 1) begin
        count <= count + 1;
    end
end


always_comb begin : DataFeeder
    for (int i = 0 ; i < DIM ; i++) begin
        if (count <= DIM*2-2) begin
            Ain[i] = OUTA[i][DIM*2-2-count];
            Bin[i] = OUTB[DIM*2-2-count][i];
        end else begin
            Ain[i] = 0;
            Bin[i] = 0;
        end
    end
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            dataOut[i][j] = Cout[i][j] >> BITS; //> 0 ? Cout[i][j] : 0; // ReLu
        end
    end
end

always_comb begin : howdone
    done = 0;
    if (m > p) done = count == m*3-2 ? 1 : 0;
    else done = count == p*3-2 ? 1 : 0;
end

endmodule