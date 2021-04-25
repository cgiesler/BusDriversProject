`include "cci_mpf_if.vh"
module afu (
    input clk,
    input rst,
	    mmio_if.user mmio,
	    dma_if.peripheral dma
);

  localparam int CL_ADDR_WIDTH = $size(t_ccip_clAddr);

  // I want to just use dma.count_t, but apparently
  // either SV or Modelsim doesn't support that. Similarly, I can't
  // just do dma.SIZE_WIDTH without getting errors or warnings about
  // "constant expression cannot contain a hierarchical identifier" in
  // some tools. Declaring a function within the interface works just fine in
  // some tools, but in Quartus I get an error about too many ports in the
  // module instantiation.
  typedef logic [CL_ADDR_WIDTH:0] count_t;   
  count_t 	size;
  logic 	go; // host_init
  logic 	done;

  // Software provides 64-bit virtual byte addresses.
  // Again, this constant would ideally get read from the DMA interface if
  // there was widespread tool support.
  localparam int VIRTUAL_BYTE_ADDR_WIDTH = 64;

  logic [VIRTUAL_BYTE_ADDR_WIDTH-1:0] rd_addr, wr_addr;

  //

  wire valid;
  wire [31:0] DMAOut;
  wire cpu_init;
  wire [31:0] DMAData;
  wire DMAEn;
  wire DMAWrEn;
  logic [31:0] DMAAddr;

  // Instantiate the memory map, which provides the starting read/write
  // 64-bit virtual byte addresses, a transfer size (in cache lines), and a
  // go signal. It also sends a done signal back to software.
  dma_memory_map
  #(
  .ADDR_WIDTH(VIRTUAL_BYTE_ADDR_WIDTH),
  .SIZE_WIDTH(CL_ADDR_WIDTH+1)
  )
  dma_memory_map (.*);

  //cpu cpu(.*);

  //accelerator acl(.*);

  //memory_controller (.*);
  memory_controller #(.DATA_WIDTH(32),.ADDR_WIDTH(28))
  mem(.clk(clk),.rst_n(!rst),.CPUEn(0),.AclEn(0),.DMAEn(DMAEn),.DMAWrEn(DMAWrEn),
      .DMAAddr(DMAAddr),.DMAData(DMAData),.DMAOut(DMAOut),.DMAValid(valid));

  dma_fsm #(.CL_SIZE_WIDTH = 512, .WORD_SIZE = 32)
  dma_fsm(
    .clk(clk), 
    .rst_n(!rst),
    .empty(dma.empty), //dma.empty
    .full(dma.full),  //dma.full
    .dma_rd_data(dma.rd_data), //dma.rd_data
    .cpu_init(cpu_init),

    .data_to_host(DMAOut), // input from mem
    .wr_ready(0), // from cpu
    .data_to_mem(DMAData),
    .line_buffer(dma.wr_data), //dma.wr_data
    .DMAEn(DMAEn),
    .DMAWrEn(DMAWrEn),
    .host_rd_ready(dma.rd_en), //dma.rd_en
    .host_wr_ready(dma.wr_en)  //dma.wr_en
  );



  // Assign the starting addresses from the memory map.
  assign dma.rd_addr = rd_addr;
  assign dma.wr_addr = wr_addr;

  // Use the size (# of cache lines) specified by software.
  assign dma.rd_size = size;
  assign dma.wr_size = size;

  // Start both the read and write channels when the MMIO go is received.
  // Note that writes don't actually occur until dma.wr_en is asserted.
  assign dma.rd_go = go;
  assign dma.wr_go = go;

  // Read from the DMA when there is data available (!dma.empty) and when
  // it is safe to write data (!dma.full).
  //assign dma.rd_en = !dma.empty && !dma.full;

  // Since this is a simple loopback, write to the DMA anytime we read.
  // For most applications, write enable would be asserted when there is an
  // output from a pipeline. In this case, the "pipeline" is a wire.

  // FIXME wr_en should come from cpu fsm
  //assign dma.wr_en = valid; //& !bubble;

  // Write the data that is read.
  
  // FIXME, write the result back to host
  //assign dma.wr_data = out;

  // The AFU is done when the DMA is done writing size cache lines.
  assign done = dma.wr_done;
/*
  always@(posedge clk, negedge !rst)begin
    if (rst) bubble <= 1'b0;
    if (valid & !dma.full) bubble <= bubble+1;
  end
*/
endmodule
