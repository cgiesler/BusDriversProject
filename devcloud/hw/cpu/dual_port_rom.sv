// Quartus Prime Verilog Template
// Dual Port ROM

module dual_port_rom
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=9)
(
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file dual_port_rom_init.txt.  Without this file,
	// this design will not compile.
	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file.
	int fd;
	string line;
	initial
	begin
		
		$readmemh("dual_port_rom_init.mif", rom);
		fd = $fopen("dual_port_rom_init.mif","r");
		$display("opened:%d\n",fd);
		while(!$feof(fd)) begin
			$fgets(line,fd);
			$display("line:%s",line);
		end
		/*
		rom[0] = 32'h 60405000;
		rom[1] = 32'h 60800001;
		rom[2] = 32'h 70820000;
		rom[3] = 32'h f8000000;
		*/
	end

	always @ (posedge clk)
	begin
		q_a <= rom[addr_a/4];
		q_b <= rom[addr_b/4];
	end

endmodule
