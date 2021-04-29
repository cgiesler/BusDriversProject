module layoutB_tb ();

localparam BITS = 8; // bit number of each pixel of input data
localparam DIM = 32; // Maximum dimension of any feature map

logic clk;
logic [BITS-1:0] INB [DIM-1:0][DIM-1:0];
logic [$clog2(DIM):0] n, p;
logic [BITS-1:0] OUTB [DIM*2-2:0][DIM-1:0];


layoutB iDUT(.*);

always #5 clk = ~clk; 

initial begin
    clk = 0;
    randomized(32, 32);
    @(posedge clk);
    randomized(14, 14);
    @(posedge clk);
    randomized(5, 5);
    @(posedge clk);
    $stop;
end

task randomized(input int x, y);
for (int i = 0 ; i < DIM ; i++) begin
    for (int j = 0 ; j < DIM ; j++) begin
        INB[i][j] = $urandom;
    end
end
n = x;
p = y;
endtask

endmodule