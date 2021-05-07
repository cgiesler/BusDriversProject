module dma_fsm 
#(
  parameter CL_ADDR_WIDTH,
  parameter CL_SIZE_WIDTH = 512,
  parameter WORD_SIZE = 32)
(
    input wire clk, rst_n,
    input logic empty, //dma.empty
    input logic full,  //dma.full
    input [CL_SIZE_WIDTH-1:0] dma_rd_data, //dma.rd_data

    input wire [CL_ADDR_WIDTH-1:0] rd_size,
    input wire DMAValid,
    input reg [31:0] data_to_host, // input from mem
    input wire wr_ready, // from cpu
    output reg [31:0] data_to_mem,
    output reg [CL_SIZE_WIDTH-1:0] out, //dma.wr_data
    output reg DMAEn,
    output reg DMAWrEn,
    output logic host_rd_ready, //dma.rd_en
    output logic host_wr_ready,  //dma.wr_en
    output logic [31:0] DMAAddr,

    output logic rd_done
);

    localparam FILL_COUNT = CL_SIZE_WIDTH / WORD_SIZE;
	localparam FILL_BITS = $clog2(FILL_COUNT);
    logic [FILL_BITS-1:0] fill_count;
    wire [WORD_SIZE-1:0] line_out [FILL_COUNT-1:0];
    reg [CL_SIZE_WIDTH-1:0] line_buffer;
    logic [CL_ADDR_WIDTH-1:0] size;
    logic wr_done;


    typedef enum reg [2:0]{
        IDLE = 3'd0,
        READ = 3'd1,
        WRITE = 3'd2,
        WRITE_WAIT = 3'd3
    } state_t;

    state_t state;


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
            host_rd_ready <= 0;
            host_wr_ready <= 0;
            rd_done <= 0;
            size <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    //host_rd_ready <= 0;
                    host_wr_ready <= 0;
                    DMAWrEn <= 1'b0;
                    if (!empty) begin
                        //rd_ready <= 1;
                        state <= READ;
                        line_buffer <= dma_rd_data;
                    end
                    
                    if( wr_ready/*wr_ready&&!wr_delay*/) begin
                        DMAEn<=1;
                        DMAWrEn <= 1'b0;
                        state <= WRITE_WAIT;
			            DMAAddr <= 32'h 5000;

                        //line_buffer[32*fill_count+31-:32]<=data_to_host;
                        //fill_count++;
                    end
                    
                end
                WRITE_WAIT: begin
                    state <= WRITE;
                    DMAAddr <= DMAAddr + 4;
                end

		        READ: begin
                    data_to_mem <= line_out[fill_count];
                    if (& fill_count ==1'b1 /*&& rd_ready*/) begin
                        // read buffer is filled
                        DMAEn <= 1'b1;
                        DMAWrEn <= 1'b1;
                        fill_count++;
                        state <= IDLE; // this is the correct implementation
			            DMAAddr <= DMAAddr + 4;
			            host_rd_ready <= 1'b1;
                        size++;
                        //out[32*fill_count+31-:32] <= data_to_mem;
                        if (size == rd_size) begin
                            rd_done <= 1;
                        end
			            //rd_done <= 1;
                    end 
                    else /*if (rd_ready)*/ begin
                        // keep filling
                        DMAEn <= 1'b1;
                        DMAWrEn <= 1'b1;
                        host_rd_ready <= 1'b0;
                        fill_count++;
                        DMAAddr <= DMAAddr + 4;
                        //out[32*fill_count+31-:32] <= data_to_mem;
                    end
                end
                WRITE: begin
                    DMAEn <= 1'b1;
                    DMAWrEn <= 1'b0;
                    host_wr_ready <= 1'b0;
                    //if (!full) begin
                        out[32*fill_count+31-:32] <= data_to_host;
                        if(!full)begin
                            if (& fill_count ==1'b1) begin
                                // read buffer is filled
                                //if (!full) begin
                                    host_wr_ready <= 1'b1&&!full;
                                    //state <= IDLE;
                                    fill_count++;
                                    DMAAddr <= DMAAddr + 4;
                                //end
                            end 
                            else begin
                                // keep filling
                                host_wr_ready <= 1'b0;
                                fill_count++;
                                DMAAddr <= DMAAddr + 4;
                            end
                        end
                        else
                            DMAAddr <= DMAAddr;

                    //end
                 end
            endcase
        end
    end

endmodule
