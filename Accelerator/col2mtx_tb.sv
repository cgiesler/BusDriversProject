module col2mtx_tb ();

localparam BITS = 8;
localparam DIM = 32;

logic clk, rst_n, en;
logic [$clog2(DIM):0] m, n;
logic [DIM-1:0] IN;
logic [BITS-1:0] OUT [DIM-1:0][DIM-1:0];
logic full;



col2mtx #(BITS, DIM) iDUT(.*);

always #5 clk = ~clk; 

initial begin
    clk = 0;
    rst_n = 0;
    @(posedge clk);
    @(posedge clk);
    rst_n = 1;
    // test(32, 32);
    // test(28, 28);
    // test(14, 14);
    test(10, 10);
    testodd(5, 5);

    $stop;
end


task test(input int x, y);
    automatic int tempCol = 0;
    automatic int tempRow = 0;
    automatic logic [BITS-1:0] temp [DIM-1:0][DIM-1:0];
    automatic int passed = 1;
    m = x;
    n = y;
    en = 1;
    for (int i = 0 ; i < m*n/4 ; i++) begin
        IN = $random;
        tempCol = (i*4) % m;
        tempRow = (i*4) / m;
        temp[tempRow][tempCol] = IN[31:24];
        if (tempCol + 1 >= m) begin
            temp[tempRow+1][tempCol+1-m] = IN[23:16];
        end else begin
            temp[tempRow][tempCol+1] = IN[23:16];
        end
        if (tempCol + 2 >= m) begin
            temp[tempRow+1][tempCol+2-m] = IN[15:8];
        end else begin
            temp[tempRow][tempCol+2] = IN[15:8];
        end
        if (tempCol + 3 >= m) begin
            temp[tempRow+1][tempCol+3-m] = IN[7:0];
        end else begin
            temp[tempRow][tempCol+3] = IN[7:0];
        end
        $display("%d: %h", i, IN[31:0]);

        @(posedge clk);
    end
    @(posedge clk);
    en = 0;
    $display("Expected:");
    for (int j = 0 ; j < DIM ; j++) begin
        for (int k = 0 ; k < DIM ; k++) begin
            $write("%h ", temp[j][k]);
        end
        $write("\n");
    end

    $display("Actual:");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            $write("%h ", OUT[i][j]);
            if (OUT[i][j] != temp[i][j]) begin
                passed = 0;
            end
        end
        $write("\n");
    end
    $display("full is %b", full);
    $display("test passed = %d", passed);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    
endtask

task testodd(input int x, y);
    automatic int tempCol = 0;
    automatic int tempRow = 0;
    automatic logic [BITS-1:0] temp [DIM-1:0][DIM-1:0];
    automatic int passed = 1;
    m = x;
    n = y;
    en = 1;
    for (int i = 0 ; i < m*n/4 + 1 ; i++) begin
        IN = $random;
        tempCol = (i*4) % m;
        tempRow = (i*4) / m;
        temp[tempRow][tempCol] = IN[31:24];
        if (tempCol + 1 >= m) begin
            temp[tempRow+1][tempCol+1-m] = IN[23:16];
        end else begin
            temp[tempRow][tempCol+1] = IN[23:16];
        end
        if (tempCol + 2 >= m) begin
            temp[tempRow+1][tempCol+2-m] = IN[15:8];
        end else begin
            temp[tempRow][tempCol+2] = IN[15:8];
        end
        if (tempCol + 3 >= m) begin
            temp[tempRow+1][tempCol+3-m] = IN[7:0];
        end else begin
            temp[tempRow][tempCol+3] = IN[7:0];
        end
        $display("%d: %h", i, IN[31:0]);

        @(posedge clk);
    end
    @(posedge clk);
    en = 0;
    $display("Expected:");
    for (int j = 0 ; j < DIM ; j++) begin
        for (int k = 0 ; k < DIM ; k++) begin
            $write("%h ", temp[j][k]);
        end
        $write("\n");
    end

    $display("Actual:");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            $write("%h ", OUT[i][j]);
            if (OUT[i][j] != temp[i][j]) begin
                passed = 0;
            end
        end
        $write("\n");
    end
    $display("full is %b", full);
    $display("test passed = %d", passed);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    
endtask

endmodule