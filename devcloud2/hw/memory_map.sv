// Provide mapping based on addr input.
// specific addr smaller than 1000 = mmio reg
// addr larger than and equal to 1000 = sram 
 
 module memory_map
 #(parameter DATA_WIDTH, parameter ADDR_WIDTH) 
 (
    input clk, rst_n,
    input [(DATA_WIDTH-1):0] data_a, data_b,
    input [(ADDR_WIDTH-1):0] addr_a, addr_b,
    input we_a, we_b,
    output logic signed [(DATA_WIDTH-1):0] q_a, q_b
 );

    logic [DATA_WIDTH-1:0] reg_a, reg_b;

    // sram signals

    logic ram_en_a;
    logic ram_en_b;
    wire ram_wr_a;
    wire ram_wr_b;
    wire [DATA_WIDTH-1:0] out_a, out_b;

    // mmio registers

    reg [32-1:0]MATMUL_A_In;
    reg [32-1:0]MATMUL_B_In;
    reg [32-1:0]MATMUL_C_Out;

    reg [32-1:0]MATVEC_A_In;
    reg [32-1:0]MATVEC_B_In;
    reg [32-1:0]MATVEC_C_Out;

    reg [DATA_WIDTH-1:0]Dim_M;  // rows of A, rows of C
    reg [DATA_WIDTH-1:0]Dim_N;  // cols of A, rows of B
    reg [DATA_WIDTH-1:0]Dim_P;  // cols of B, cols of C

    reg [32-1:0]MP_Addr;

    reg [DATA_WIDTH-1:0]MATMUL_Flag;
    reg [DATA_WIDTH-1:0]MATVEC_Flag;
    reg [DATA_WIDTH-1:0]MP_Flag;
    reg [32-1:0]Bias_Addr;
      
    sram #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
    ram(.data_a(data_a),.data_b(data_b),.addr_a(addr_a),.addr_b(addr_b),
    .we_a(we_a&ram_wr_a),.we_b(we_b&ram_wr_b),.clk(clk),.q_a(out_a),.q_b(out_b));

    assign ram_wr_a = (|(addr_a[ADDR_WIDTH-1:12])) & we_a;
    assign ram_wr_b = (|(addr_b[ADDR_WIDTH-1:12])) & we_b;
    assign q_a = ram_en_a?out_a:reg_a;
    assign q_b = ram_en_b?out_b:reg_b;
/*
    always@(posedge clk,negedge rst_n) begin
        // mmio register reset
        if (!rst_n) begin
            MATMUL_A_In <= 0;
            MATMUL_B_In <= 0;
            MATMUL_C_Out <= 0;
            MATVEC_A_In <= 0;
            MATVEC_B_In <= 0;
            MATVEC_C_Out <= 0;

            Dim_M <= 0;  // rows of A, rows of C
            Dim_N <= 0;  // cols of A, rows of B
            Dim_P <= 0;  // cols of B, cols of C

            MP_Addr <= 0;

            MATMUL_Flag <= 0;
            MATVEC_Flag <= 0;
            MP_Flag <= 0;
            Bias_Addr <= 0;
        end
    end
*/
    always@(posedge clk,negedge rst_n) begin     
          // mmio register reset
        if (!rst_n) begin
            MATMUL_A_In <= 0;
            MATMUL_B_In <= 0;
            MATMUL_C_Out <= 0;
            MATVEC_A_In <= 0;
            MATVEC_B_In <= 0;
            MATVEC_C_Out <= 0;

            Dim_M <= 0;  // rows of A, rows of C
            Dim_N <= 0;  // cols of A, rows of B
            Dim_P <= 0;  // cols of B, cols of C

            MP_Addr <= 0;

            MATMUL_Flag <= 0;
            MATVEC_Flag <= 0;
            MP_Flag <= 0;
            Bias_Addr <= 0;
        end
	ram_en_a <= 1;
        ram_en_b <= 1;

        case (addr_a)
            32'h 0: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATMUL_A_In <= data_a;
                    reg_a <= MATMUL_A_In;
                end
            32'h 100: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATMUL_B_In <= data_a;
                    reg_a <= MATMUL_B_In;
                end
            32'h 200: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATMUL_C_Out <= data_a;
                    reg_a <= MATMUL_C_Out;
                end
            32'h 300: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATVEC_A_In <= data_a;
                    reg_a <= MATVEC_A_In;
                end
            32'h 400: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATVEC_B_In <= data_a;
                    reg_a <= MATVEC_B_In;
                end
            32'h 500: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATVEC_C_Out <= data_a;
                    reg_a <= MATVEC_C_Out;
                end
            32'h 600: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        Dim_M <= data_a;
                    reg_a <= Dim_M;
                end
            32'h 700: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        Dim_N <= data_a;
                    reg_a <= Dim_N;
                end
            32'h 800: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        Dim_P <= data_a;
                    reg_a <= Dim_P;
                end
            32'h 900: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MP_Addr <= data_a;
                    reg_a <= MP_Addr;
                end
            32'h A00: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATMUL_Flag <= data_a;
                    reg_a <= MATMUL_Flag;
                end
            32'h B00: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MATVEC_Flag <= data_a;
                    reg_a <= MATVEC_Flag;
                end
            32'h C00: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        MP_Flag <= data_a;
                    reg_a <= MP_Flag;
                end
            32'h D00: 
                begin
                    ram_en_a <= 0;
                    if (we_a)
                        Bias_Addr <= data_a;
                    reg_a <= Bias_Addr;
                end
        endcase

        case (addr_b)
            32'h 0: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATMUL_A_In <= data_b;
                    reg_b <= MATMUL_A_In;
                end
            32'h 100: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATMUL_B_In <= data_b;
                    reg_b <= MATMUL_B_In;
                end
            32'h 200: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATMUL_C_Out <= data_b;
                    reg_b <= MATMUL_C_Out;
                end
            32'h 300: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATVEC_A_In <= data_b;
                    reg_b <= MATVEC_A_In;
                end
            32'h 400: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATVEC_B_In <= data_b;
                    reg_b <= MATVEC_B_In;
                end
            32'h 500: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATVEC_C_Out <= data_b;
                    reg_b <= MATVEC_C_Out;
                end
            32'h 600: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        Dim_M <= data_b;
                    reg_b <= Dim_M;
                end
            32'h 700: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        Dim_N <= data_b;
                    reg_b <= Dim_N;
                end
            32'h 800: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        Dim_P <= data_b;
                    reg_b <= Dim_P;
                end
            32'h 900: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MP_Addr <= data_b;
                    reg_b <= MP_Addr;
                end
            32'h A00: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATMUL_Flag <= data_b;
                    reg_b <= MATMUL_Flag;
                end
            32'h B00: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MATVEC_Flag <= data_b;
                    reg_b <= MATVEC_Flag;
                end
            32'h C00: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        MP_Flag <= data_b;
                    reg_b <= MP_Flag;
                end
            32'h D00: 
                begin
                    ram_en_b  <= 0;
                    if (we_b)
                        Bias_Addr <= data_b;
                    reg_b <= Bias_Addr;
                end    
        endcase
    end
endmodule           
            
