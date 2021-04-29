module flatten_tb ();
    
localparam BITS = 8; // bit number of each pixel of input data
localparam DIM = 32; // Maximum dimension of any feature map

logic clk;
logic [$clog2(DIM):0] m, n;
logic [BITS-1:0] IN [DIM-1:0][DIM-1:0];
logic [BITS-1:0] OUT [DIM*DIM-1:0];

flatten iDUT(.*);

always #5 clk = ~clk; 

initial begin
    clk = 0;
    randomized(32, 32);
    @(posedge clk);
    // randomized(14, 14);
    // @(posedge clk);
    randomized(5, 5);
    @(posedge clk);
    $stop;
end

task randomized(input int x, y);
for (int i = 0 ; i < DIM ; i++) begin
    for (int j = 0 ; j < DIM ; j++) begin
        IN[i][j] = $urandom;
    end
end
m = x;
n = y;
endtask
    
endmodule