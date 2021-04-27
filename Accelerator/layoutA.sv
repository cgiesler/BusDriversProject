/*
    This is a pure combinational module that gets data in a matrix ready to go through
    systolic array
*/

module layoutA
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input [BITS-1:0] INA [DIM-1:0][DIM-1:0],
    output [BITS-1:0] OUTA [DIM-1:0][DIM*2-2:0]
);
    
endmodule