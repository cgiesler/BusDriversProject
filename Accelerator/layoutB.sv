/*
    This is a pure combinational module that gets data in a matrix 
    ready to go through systolic array
*/

module layoutB
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input [BITS-1:0] INB [DIM-1:0][DIM-1:0],
    input [$clog2(DIM):0] n, p, 
    output logic [BITS-1:0] OUTB [DIM*2-2:0][DIM-1:0]
);

always_comb begin : ConnectionsB
    for (int row = 0 ; row < DIM ; row++) begin
        for (int col = 0 ; col < DIM*2-1 ; col++) begin
            if (col >= DIM*2-1-p-row && col <= DIM*2-2-row && row < n) begin
                OUTB[col][row] = INB[DIM*2-2-col-row][row];
            end else begin
                OUTB[col][row] = 0;
            end
        end
    end
end

    
endmodule