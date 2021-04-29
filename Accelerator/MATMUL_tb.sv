module MATMUL_tb ();

localparam BITS = 8; // bit number of each pixel of input data
localparam DIM = 32; // Maximum dimension of any feature map

logic clk, rst_n, en, WrEn;
logic [$clog2(DIM):0] m, n, p;
logic [BITS-1:0] matrixDataA [DIM-1:0][DIM-1:0];
logic [BITS-1:0] matrixDataB [DIM-1:0][DIM-1:0];
logic [BITS*2-1:0] dataOut [DIM-1:0][DIM-1:0];
logic done;


MATMUL iDUT(.*);


always #5 clk = ~clk; 

initial begin
    clk = 0;
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    // m = 32;
    // n = 32;
    // p = 32;

    // for (int i = 0 ; i < DIM ; i++) begin
    //     for (int j = 0 ; j < DIM ; j++) begin
    //         matrixDataA[i][j] = 1;
    //         matrixDataB[i][j] = 1;
    //     end
    // end
    // en = 1;

    // repeat (DIM*3-2) @(posedge clk);

    // en = 0;
    // $display("done is %d", done);
    randomtest(5,5,5);
    $stop;
end

task randomtest(input int x,y,z);
    automatic int temp [DIM-1:0][DIM-1:0];
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    m = x;
    n = y;
    p = z;

    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            matrixDataA[i][j] = $urandom_range(100);
            matrixDataB[i][j] = $urandom_range(100);
        end
    end

    en = 1;
    for (int i = 0 ; i < DIM*3-2 ; i++) begin
        @(posedge clk);
        if (done) break;
    end 
    en = 0;

    $display("matrixDataA: ");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            $write("%d ", matrixDataA[i][j]);
        end
        $write("\n");
    end
    
    $display("matrixDataB: ");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            $write("%d ", matrixDataB[i][j]);
        end
        $write("\n");
    end

    $display("Result: ");
    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
            $write("%d ", dataOut[i][j]);
        end
        $write("\n");
    end

    $display("Expected: ");
    for (int i = 0 ; i < x ; i++) begin
        for (int j = 0 ; j < y ; j++) begin
            for (int k = 0 ; k < z ; k++) begin
               temp[i][j] += matrixDataA[i][k]*matrixDataB[k][j];
            end
        end
    end

    for (int i = 0 ; i < DIM ; i++) begin
        for (int j = 0 ; j < DIM ; j++) begin
              $write("%d ", temp[i][j]);
        end
        $write("\n");
    end
    
    
endtask 
endmodule