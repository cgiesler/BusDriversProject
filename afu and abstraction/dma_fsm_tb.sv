module dma_fsm_tb (
);
    localparam  CL_SIZE_WIDTH = 512;
    localparam  WORD_SIZE = 32;

    logic clk, rst_n;
    integer errors, mycycle;
    logic empty;
    logic full;
    logic [CL_SIZE_WIDTH-1:0] dma_rd_data;
    reg [31:0] data_to_host;
    reg [31:0] data_to_mem;
    reg [CL_SIZE_WIDTH-1:0] line_buffer;
    reg DMAEn;
    reg DMAWrEn;
    logic host_rd_ready;
    logic host_wr_ready;
    logic wr_ready;
    integer i;
    logic [CL_SIZE_WIDTH-1:0] lines;
    logic [31:0] DMAAddr;
    logic [31:0] DMAData;
    //logic [31:0] DMAOut;
    logic cpu_init;
    logic DMAValid;

    always #5 begin 
        clk = ~clk;
        mycycle++;
    end

    dma_fsm #(.CL_SIZE_WIDTH(CL_SIZE_WIDTH),.WORD_SIZE(WORD_SIZE))
    DUT(.*);

    memory_controller #(.DATA_WIDTH(32),.ADDR_WIDTH(28))
    mem(.clk(clk),.rst_n(rst_n),.CPUEn(0),.CPUWrEn(0),.AclWrEn(0),.AclEn(0),.DMAEn(DMAEn),.DMAWrEn(DMAWrEn),
      .DMAAddr(DMAAddr),.DMAData(data_to_mem),.DMAOut(data_to_host),.DMAValid(DMAValid));

    initial begin
        clk = 0;
        rst_n = 0;
        empty = 1;
        full = 0;
        dma_rd_data = 0;
        data_to_host = 0;
        wr_ready = 0;
        i = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        empty = 0;
        dma_rd_data = {{32'd0},{32'd1},{32'd2},{32'd3},{32'd4},
                       {32'd5},{32'd6},{32'd7},{32'd8},
                       {32'd9},{32'd10},{32'd11},{32'd12},
                       {32'd13},{32'd14},{32'd15}};
        @(posedge clk);
        @(posedge clk);
        for ( i = 15; i >0; i--) begin
            @(posedge clk);
            $display("expected:%d, got:%d.",i,data_to_mem);
        end
        empty = 1;
        @(posedge clk);
        $display("expected:0, got:%d.",data_to_mem);
        @(posedge clk);

        wr_ready = 1;
        @(posedge clk);
        for( i = 15; i>=0; i--) begin
            //data_to_host = i;
            lines[32*i+31-:32] = i;
            @(posedge clk);
        end
        wr_ready = 0;
        $display("expected:%d, got:%d.",dma_rd_data,line_buffer);
        @(posedge clk);
        full = 1;
        @(posedge clk);

        $stop;
    end

endmodule