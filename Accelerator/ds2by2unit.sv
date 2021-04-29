// Downsampling 2 by 2 unit
module ds2by2unit 
#(
    parameter BITS = 8
)
(   
    input [BITS*2-1:0] IN [1:0][1:0],
    output logic [BITS*2-1:0] OUT 
);

always_comb begin
    OUT = 0;
    if(IN[0][0] >= IN[0][1] && IN[0][0] >= IN[1][0] && IN[0][0] >= IN[1][1]) begin
        OUT = IN[0][0];
    end else if (IN[0][1] >= IN[0][0] && IN[0][1] >= IN[1][0] && IN[0][1] >= IN[1][1]) begin
        OUT = IN[0][1];
    end else if (IN[1][0] >= IN[0][0] && IN[1][0] >= IN[0][1] && IN[1][0] >= IN[1][1]) begin
        OUT = IN[1][0];
    end else begin
        OUT = IN[1][1];
    end
end
    
endmodule