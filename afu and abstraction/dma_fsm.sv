
module dma_fsm 
#(
  parameter CL_SIZE_WIDTH = 512,
  parameter WORD_SIZE = 32)
(
    input wire clk, rst_n,
    input logic empty, //dma.empty
    input logic full,  //dma.full
    input [CL_SIZE_WIDTH-1:0] dma_rd_data, //dma.rd_data
    output wire cpu_init,

    input reg [31:0] data_to_host, // input from mem
    input wire wr_ready, // from cpu
    output reg [31:0] data_to_mem,
    output reg [CL_SIZE_WIDTH-1:0] line_buffer, //dma.wr_data
    output reg DMAEn,
    output reg DMAWrEn,
    output logic host_rd_ready, //dma.rd_en
    output logic host_wr_ready,  //dma.wr_en
    output logic [31:0] DMAAddr
);

    localparam FILL_COUNT = CL_SIZE_WIDTH / WORD_SIZE;
	localparam FILL_BITS = $clog2(FILL_COUNT);
    logic [FILL_BITS-1:0] fill_count;
    logic [WORD_SIZE-1:0] line_out [FILL_COUNT-1:0];

    typedef enum reg [1:0]{
        IDLE = 2'b0,
        READ = 2'b01,
        WRITE = 2'b10
    } state_t;

    state_t state;

    assign rd_ready = !empty;

	genvar gv;
	generate
		for(gv = 0; gv < FILL_COUNT; ++gv) begin
			assign line_out[gv] = line_buffer[((gv + 1)*WORD_SIZE)-1:gv*WORD_SIZE];
		end
	endgenerate

    always@(posedge clk, negedge rst_n) begin
        host_rd_ready <= 0;
        if (!rst_n) begin
            for(integer i = 0; i < 16; ++i)
                line_buffer[i] <= '0;
            state <= IDLE;
            fill_count <= '0;
            DMAAddr <= 32'h 5000-4;
            //wr_fill <= '0;
        end
        else begin
            case(state)
                IDLE: begin
                    host_rd_ready <= 0;
                    host_wr_ready <= 0;
                    DMAWrEn <= 1'b0;
                    line_buffer <= 0;
                    
                    if (rd_ready) begin
                        state <= READ; 
                        line_buffer <= dma_rd_data;
                    end
                    else if (wr_ready) begin

                        state <= WRITE;
                        DMAAddr <= 32'h 5000-4;

                        //line_buffer[32*fill_count+31-:32]<=data_to_host;
                        //fill_count++;
                    end
                end
                READ: begin
                    data_to_mem <= line_out[fill_count];
                    if (& fill_count ==1'b1 && rd_ready) begin
                        // read buffer is filled
                        DMAEn <= 1'b1;
                        DMAWrEn <= 1'b1;
                        host_rd_ready <= 1'b1;
                        fill_count++;
                        state <= IDLE; // this is the correct implementation
                        DMAAddr <= DMAAddr + 4;
                    end 
                    else if (rd_ready) begin
                        // keep filling
                        DMAEn <= 1'b1;
                        DMAWrEn <= 1'b1;
                        host_rd_ready <= 1'b0;
                        fill_count++;
                        DMAAddr <= DMAAddr + 4;
                    end
                end

                WRITE: begin
                    DMAEn <= 1'b1;
                    DMAWrEn <= 1'b0;
                    line_buffer[32*fill_count+31-:32]<=data_to_host;
                    if (& fill_count ==1'b1) begin
                        // read buffer is filled
                        if (!full) begin
                            host_wr_ready <= 1'b1;
                            state <= IDLE;
                            fill_count++;
                            DMAAddr <= DMAAddr + 4;
                        end
                    end 
                    else begin
                        // keep filling
                        host_wr_ready <= 1'b0;
                        fill_count++;
                        DMAAddr <= DMAAddr + 4;
                    end
                end
            endcase
        end
    end

endmodule