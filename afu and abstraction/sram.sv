// Asynch no reset, but at higher level it is accessed in synchronous
// Little endian, Byte addressable
// Total space = 2**32 * 8
// Never write to addr lower than 1000
// Unwritten addr will output x
module sram
#(parameter DATA_WIDTH=512, parameter ADDR_WIDTH)
(
    input [(512-1):0] data_a, data_b,
    input [(ADDR_WIDTH-1):0] addr_a, addr_b,
    input we_a, we_b, clk,
    output reg [(DATA_WIDTH-1):0] q_a, q_b
);
 // Declare the RAM variable
    reg [512-1:0] ram[2**ADDR_WIDTH-1:0];
// Port A
    always @ (posedge clk) begin
        if (we_a) begin
            ram[addr_a]   = data_a[511:0];
        end
        q_a = ram[addr_a];
    end
// Port B
    always @ (posedge clk) begin
        if (we_b) begin
            ram[addr_b]   = data_b[511:0];
        end
        q_b = ram[addr_b];
    end
endmodule
