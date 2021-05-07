module rom_tb (
);

    logic clk, rst_n;

    logic [7:0] addr_a, addr_b;
    logic [31:0] q_a, q_b;

    dual_port_rom DUT(.*);

    always #5 begin 
        clk = ~clk;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        addr_a <= 0;
        @(posedge clk);
        addr_a <= 4;
        @(posedge clk);
        addr_a <= 8;
        @(posedge clk);
        addr_a <= 12;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $stop;
    end
endmodule