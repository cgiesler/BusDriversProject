`include "memmap.sv"
/*
Accelerator top level will take care of all address processing and reading and writing form the memory.
Individual modules will take care of specific operations as specified below.
Matrices’ dimension (m, n, p) will first be read, then the module will read the dataset.
*/
module accelerator 
#(
    parameter BITS = 8, // bit number of each pixel of input data
    parameter DIM = 32 // Maximum dimension of any feature map
)
(
    input [31:0] MMIOAddr,
    input MMIOEn, MMIOWrEn, clk, rst_n,
    input [31:0] MemRdData,
    output logic [31:0] MemAddr,
    output logic [31:0] MemWrData,
    output logic MemEn, MemWrEn
);
typedef enum bit[2:0] {IDLE, RDADDR, RDDATAA, RDDATAB, CALC, WRDATA} accelSTATE;
accelSTATE state, next_state;

logic [5:0] count;
logic cntrst;
logic [BITS-1:0] cacheA [DIM-1:0][DIM-1:0], cacheB [DIM-1:0][DIM-1:0];
logic [$clog2(DIM):0] m, n, p, MACm, MACn, MACp;

logic MACen;
logic [31:0] MACDataAAddr, MACDataBAddr, MACDataOutAddr;
logic [BITS-1:0] MACDataA [DIM-1:0][DIM*2-2:0], MACDataB [DIM*2-2:0][DIM-1:0];
logic [BITS*2-1:0] MACDataOut [DIM-1:0][DIM-1:0];
logic MACdone;
MATMUL #(BITS, DIM) MACDUT0 // expand to more if needed
(
    .clk(clk), .rst_n(rst_n && !MACrst), .en(MACen),
    .m(MACm), .n(MACn), .p(MACp),
    .matrixDataA(MACDataA), .matrixDataB(MACDataB),
    .dataOut(MACDataOut),.done(MACdone)
);
assign MACm = m;
assign MACn = n;
assign MACp = p;

logic [BITS-1:0] MAXPDataIn [DIM-1:0][DIM-1:0], MAXPDataOut [DIM/2-1:0][DIM/2-1:0];
maxpool #(BITS, DIM) MAXPDUT0
(
    .clk(clk), .rst_n(rst_n),
    .dataIn(MAXPDataIn), .dataOut(MAXPDataOut)
);

logic COL2MTXen, COL2MTXfull, COL2MTXrst;
logic [$clog2(DIM):0] COL2MTXm, COL2MTXn;
logic [DIM-1:0] COL2MTXIN;
logic [BITS-1:0] COL2MTXOUT [DIM-1:0][DIM-1:0];
col2mtx #(BITS, DIM) COL2MTXDUT0
(
    .clk(clk), .rst_n(rst_n && !COL2MTXrst), .en(COL2MTXen),
    .m(COL2MTXm), .n(COL2MTXn),
    .IN(COL2MTXIN),
    .OUT(COL2MTXOUT),
    .full(COL2MTXfull)
);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n || count > 6 || state == IDLE) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

always_comb begin : MMIOTranslation
    next_state = IDLE;
    if (MMIOAddr == `MATMULF && MMIOEn && MMIOWrEn) begin // MATMUL Flag Reg write
        next_state = RDADDR;
    end else if (MMIOAddr == 32'h00000B00 && MMIOEn && MMIOWrEn) begin
        
    end else if (MMIOAddr == `MAXPOLF && MMIOEn && MMIOWrEn) begin
        
    end

    MemAddr = 0;
    MemWrData = 0;
    MemEn = 0;
    MemWrEn = 0;
    cntrst = 0;
    COL2MTXen = 0;
    COL2MTXrst = 0;
    case(state)
        RDADDR: begin
            case (count) // A 6-cycle state machine to read all predefined address
                6'd0: begin
                    MemAddr = `MATDIMM;
                    MemEn = 1;
                end
                6'd1: begin
                    MemAddr = `MATDIMN;
                    MemEn = 1;
                    m = MemRdData;
                end
                6'd2: begin
                    MemAddr = `MATDIMP;
                    MemEn = 1;
                    n = MemRdData;
                end
                6'd3: begin
                    MemAddr = `MATMULA;
                    MemEn = 1;
                    p = MemRdData;
                end
                6'd4: begin
                    MemAddr = `MATMULB;
                    MemEn = 1;
                    MACDataAAddr = MemRdData;
                end
                6'd5: begin
                    MemAddr = `MATMULC;
                    MemEn = 1;
                    MACDataBAddr = MemRdData;
                end
                6'd6: begin
                    MACDataOutAddr = MemRdData;
                    next_state = RDDATAA;
                    cntrst = 1;
                    COL2MTXrst = 1;
                end
                default: begin
                    
                end
            endcase
        end
        RDDATAA: begin
            MemAddr = MACDataAAddr + count * 4;
            MemEn = 1;
            COL2MTXm = m;
            COL2MTXn = n;
            if (count > 0) begin
                COL2MTXIN = MemRdData;
                COL2MTXen = 1;
            end
            if (COL2MTXfull) begin
                cacheA = COL2MTXOUT;
                next_state = RDDATAB;
                COL2MTXrst = 1;
                cntrst = 1;
            end
        end
        RDDATAB: begin
            MemAddr = MACDataBAddr + count * 4;
            MemEn = 1;
            COL2MTXm = n;
            COL2MTXn = p;
            if (count > 0) begin
                COL2MTXIN = MemRdData;
                COL2MTXen = 1;
            end
            if (COL2MTXfull) begin
                cacheB = COL2MTXOUT;
                next_state = CALC;
                COL2MTXrst = 1;
                cntrst = 1;
            end
        end
        CALC: begin
            for (int i = 0 ; i < DIM ; i++) begin
                for (int j = 0 ; j < DIM*2-1 ; j++) begin
                    if (j > DIM*2-1-DIM-i && j < DIM*2-1-i) begin
                        MACDataA[i][j] = cacheA[i][j-DIM*2-1-DIM-i];
                    end else MACDataA[i][j] = 0;
                end
            end
            for (int i = 0 ; i < DIM*2-1 ; i++) begin
                for (int j = 0 ; j < DIM ; j++) begin
                    if (i > DIM*2-1-DIM-j && i < DIM*2-1-j) begin
                        MACDataB[i][j] = cacheB[i][j-DIM*2-1-DIM-i];
                    end else MACDataB[i][j] = 0;
                end
            end
            MACen = 1;
            if (MACdone) begin
                MACen = 0;
                next_state = WRDATA;
            end
        end
        default: begin
            
        end
        
    endcase
end
endmodule