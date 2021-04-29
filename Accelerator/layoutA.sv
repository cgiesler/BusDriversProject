/*
    This is a pure combinational module that gets data in a matrix 
    ready to go through systolic array
*/

module layoutA
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input [BITS-1:0] INA [DIM-1:0][DIM-1:0],
    input [$clog2(DIM):0] m, n, 
    output logic [BITS-1:0] OUTA [DIM-1:0][DIM*2-2:0]
);

always_comb begin : ConnectionsA
    for (int row = 0 ; row < DIM ; row++) begin
        for (int col = 0 ; col < DIM*2-1 ; col++) begin
            if (col >= DIM*2-1-n-row && col <= DIM*2-2-row && row < m) begin
                OUTA[row][col] = INA[row][DIM*2-2-col-row];
            end else begin
                OUTA[row][col] = 0;
            end
        end
    end
end

    
endmodule