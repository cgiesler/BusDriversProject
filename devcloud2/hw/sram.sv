// Asynch no reset, but at higher level it is accessed in synchronous
// Little endian, Byte addressable
// Total space = 2**32 * 8
// Never write to addr lower than 1000
// Unwritten addr will output x
module sram
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=18)
(
    input [(DATA_WIDTH-1):0] data_a, data_b,
    input [(ADDR_WIDTH-1):0] addr_a, addr_b,
    input we_a, we_b, clk,
    output reg [(DATA_WIDTH-1):0] q_a, q_b
);
 // Declare the RAM variable
    reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
/*
    // Port A
    always @ (posedge clk) begin
        if (we_a) begin
	    ram[addr_a] = data_a;
            
	    ram[addr_a]   = data_a[7:0];
            ram[addr_a+1] = data_a[15:8];
            ram[addr_a+2] = data_a[23:16];
            ram[addr_a+3] = data_a[31:24];
	    
        end
	q_a = ram[addr_a];
        q_a = {ram[addr_a+3],ram[addr_a+2],ram[addr_a+1],ram[addr_a]};
    end
// Port B
    always @ (posedge clk) begin
        if (we_b) begin
		ram[addr_b] = data_b;
		
            ram[addr_b]   = data_b[7:0];
            ram[addr_b+1] = data_b[15:8];
            ram[addr_b+2] = data_b[23:16];
            ram[addr_b+3] = data_b[31:24];
	    
        end
	q_b = ram[addr_b];
        q_b = {ram[addr_b+3],ram[addr_b+2],ram[addr_b+1],ram[addr_b]};
    end
    */
// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end
   endmodule
