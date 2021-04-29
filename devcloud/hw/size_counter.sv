module size_counter 
#(
    parameter CL_ADDR_WIDTH = 64
)
(
    input wire clk,
    input wire rst_n,
    input wire [CL_ADDR_WIDTH-1:0] size,
    input wire local_rd_en,
    input wire local_wr_en,
    output logic wr_init,
    output logic rd_done,
    output logic wr_done
);
    logic [CL_ADDR_WIDTH] rd_cnt;
    logic [CL_ADDR_WIDTH] wr_cnt;

    typedef enum reg [2:0]{
        IDLE = 3'd0,
        READ = 3'd1,
        WRITE = 3'd2,
	    END = 3'd3,
	    READ_WAIT = 3'd4
    } state_t;

    state_t state;

    always@(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            wr_init <= 0;
            rd_cnt <= 0;
            wr_cnt <= 0;
            rd_done <= 0;
            wr_done <= 0;
            state <= READ;
        end 
        else begin
            case(state)
                READ: begin
                    if (local_rd_en) begin
                        rd_cnt++;
                        if(rd_cnt == size)begin
                            //wr_init <= 1;
                            rd_done <= 1;
                            state <= WRITE;
                        end
                    end
                end
                WRITE: begin
                    wr_init <= 1;
                    if (local_wr_en) begin
                        wr_cnt++;
                        if(wr_cnt == size)begin
                            wr_done <= 1;
                            state <= END;
                        end
                    end    
                end
                END: begin
                    
                end 
            endcase
        end
    end 

endmodule