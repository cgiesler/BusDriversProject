module maxpool_tb();

localparam BITS = 8;
localparam DIM = 32;

logic clk, rst_n;
logic unsigned [BITS-1:0] dataIn [DIM-1:0][DIM-1:0];
logic unsigned [BITS-1:0] dataOut [DIM/2-1:0][DIM/2-1:0];

always #5 clk = ~clk; 


maxpool #(BITS, DIM) iDUT
(
.clk(clk), .rst_n(rst_n), .dataIn(dataIn), // 1kB
// input [31:0] m, p, // m*p is the dimension of the matrix coming in
.dataOut(dataOut) // 256B
);

initial begin
    clk = 0;
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    $display("dataIn: ");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            dataIn[i][j] = $urandom;
            $write("%d ",dataIn[i][j]);
        end
        $write("\n");
    end
    $write("\n");
    @(posedge clk);
    $display("dataOut: ");
    for (int i = 0 ; i < DIM/2 ; i++) begin
        for (int j = 0 ; j < DIM/2 ; j++) begin
            $write("%d ",dataOut[i][j]);
        end
        $write("\n");
    end
    @(posedge clk);
    $stop;
end
endmodule