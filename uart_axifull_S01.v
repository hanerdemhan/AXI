module uart_axifull_S01 #(
    // Users to add parameters here
    // MBA START
    parameter c_clkfreq = 100_000_000,
    parameter c_baudrate = 115_200,
    parameter c_stopbit = 2,
    // MBA END
    // User parameters ends
    // Do not modify the parameters beyond this line
    // Width of ID for write address, write data, read address, and read data
    parameter C_S_AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter C_S_AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter C_S_AXI_ADDR_WIDTH = 10,
    // Width of optional user-defined signal in write address channel
    parameter C_S_AXI_AWUSER_WIDTH = 0,
    // Width of optional user-defined signal in read address channel
    parameter C_S_AXI_ARUSER_WIDTH = 0,
    // Width of optional user-defined signal in write data channel
    parameter C_S_AXI_WUSER_WIDTH = 0,
    // Width of optional user-defined signal in read data channel
    parameter C_S_AXI_RUSER_WIDTH = 0,
    // Width of optional user-defined signal in write response channel
    parameter C_S_AXI_BUSER_WIDTH = 0
) (
    // Users to add ports here
    // MBA START
    input [9:0] data_length_i,
    input sent_trig_i,
    output tx_o,
    // MBA END
    // Global Clock Signal
    input S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input S_AXI_ARESETN,
    // Write Address ID
    input [C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID,
    // Write address
    input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    // Burst length
    input [7:0] S_AXI_AWLEN,
    // Burst size
    input [2:0] S_AXI_AWSIZE,
    // Burst type
    input [1:0] S_AXI_AWBURST,
    // Lock type
    input S_AXI_AWLOCK,
    // Memory type
    input [3:0] S_AXI_AWCACHE,
    // Protection type
    input [2:0] S_AXI_AWPROT,
    // Quality of Service
    input [3:0] S_AXI_AWQOS,
    // Region identifier
    input [3:0] S_AXI_AWREGION,
    // Optional User-defined signal in the write address channel
    input [C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER,
    // Write address valid
    input S_AXI_AWVALID,
    // Write address ready
    output S_AXI_AWREADY,
    // Write Data
    input [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    // Write strobes
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    // Write last
    input S_AXI_WLAST,
    // Optional User-defined signal in the write data channel
    input [C_S_AXI_WUSER_WIDTH-1:0] S_AXI_WUSER,
    // Write valid
    input S_AXI_WVALID,
    // Write ready
    output S_AXI_WREADY,
    // Response ID tag
    output [C_S_AXI_ID_WIDTH-1:0] S_AXI_BID,
    // Write response
    output [1:0] S_AXI_BRESP,
    // Optional User-defined signal in the write response channel
    output [C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER,
    // Write response valid
    output S_AXI_BVALID,
    // Response ready
    input S_AXI_BREADY,
    // Read address ID
    input [C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID,
    // Read address
    input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    // Burst length
    input [7:0] S_AXI_ARLEN,
    // Burst size
    input [2:0] S_AXI_ARSIZE,
    // Burst type
    input [1:0] S_AXI_ARBURST,
    // Lock type
    input S_AXI_ARLOCK,
    // Memory type
    input [3:0] S_AXI_ARCACHE,
    // Protection type
    input [2:0] S_AXI_ARPROT,
    // Quality of Service
    input [3:0] S_AXI_ARQOS,
    // Region identifier
    input [3:0] S_AXI_ARREGION,
    // Optional User-defined signal in the read address channel
    input [C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER,
    // Write address valid
    input S_AXI_ARVALID,
    // Read address ready
    output S_AXI_ARREADY,
    // Read ID tag
    output [C_S_AXI_ID_WIDTH-1:0] S_AXI_RID,
    // Read Data
    output [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    // Read response
    output [1:0] S_AXI_RRESP,
    // Read last
    output S_AXI_RLAST,
    // Optional User-defined signal in the read address channel
    output [C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER,
    // Read valid
    output S_AXI_RVALID,
    // Read ready
    input S_AXI_RREADY
);

    // AXI4FULL signals
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1:0] axi_bresp;
    reg [C_S_AXI_BUSER_WIDTH-1:0] axi_buser;
    reg axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg [1:0] axi_rresp;
    reg axi_rlast;
    reg [C_S_AXI_RUSER_WIDTH-1:0] axi_ruser;
    reg axi_rvalid;
    // aw_wrap_en determines wrap boundary and enables wrapping
    reg aw_wrap_en;
    // ar_wrap_en determines wrap boundary and enables wrapping
    reg ar_wrap_en;
    // aw_wrap_size is the size of the write transfer
    reg [31:0] aw_wrap_size;
    // ar_wrap_size is the size of the read transfer
    reg [31:0] ar_wrap_size;
    // The axi_awv_awr_flag flag marks the presence of write address valid
    reg axi_awv_awr_flag;
    // The axi_arv_arr_flag flag marks the presence of read address valid
    reg axi_arv_arr_flag;
    // The axi_awlen_cntr internal write address counter
    reg [7:0] axi_awlen_cntr;
    // The axi_arlen_cntr internal read address counter
    reg [7:0] axi_arlen_cntr;
    reg [1:0] axi_arburst;
    reg [1:0] axi_awburst;
    reg [7:0] axi_arlen;
    reg [7:0] axi_awlen;

    // Local parameters for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    localparam ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam OPT_MEM_ADDR_BITS = 7;
    localparam USER_NUM_MEM = 1;
    localparam low = {C_S_AXI_ADDR_WIDTH{1'b0}};
    
    // Signals for user logic memory space example
    reg [OPT_MEM_ADDR_BITS-1:0] mem_address;
    // MBA START
    reg [OPT_MEM_ADDR_BITS-1:0] mba_mem_address;
    // MBA END
    reg [USER_NUM_MEM-1:0] mem_select;
    reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out [0:USER_NUM_MEM-1];
    // MBA START
    reg [C_S_AXI_DATA_WIDTH-1:0] mba_mem_data_out [0:USER_NUM_MEM-1];
    // MBA END

    // Signals for UART transmission
    reg [7:0] din;
    reg tx_start;
    reg tx_done_tick;
    reg sending;
    reg [9:0] cntr;

    // Instantiate uart_tx component
    uart_tx #(
        .c_clkfreq(c_clkfreq),
        .c_baudrate(c_baudrate),
        .c_stopbit(c_stopbit)
    ) uart_tx_inst (
        .clk(S_AXI_ACLK),
        .din_i(din),
        .tx_start_i(tx_start),
        .tx_o(tx_o),
        .tx_done_tick_o(tx_done_tick)
    );

    // AXI signal assignments
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP = axi_bresp;
    assign S_AXI_BUSER = axi_buser;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA = axi_rdata;
    assign S_AXI_RRESP = axi_rresp;
    assign S_AXI_RLAST = axi_rlast;
    assign S_AXI_RUSER = axi_ruser;
    assign S_AXI_RVALID = axi_rvalid;
    assign S_AXI_AWADDR = axi_awaddr;
    assign S_AXI_ARADDR = axi_araddr;

    // Write operations (Address + Data)
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            axi_wready <= 1'b0;
            axi_bvalid <= 1'b0;
            axi_bresp <= 2'b00;
        end else begin
            if (S_AXI_AWVALID && !axi_awready) begin
                axi_awready <= 1'b1;
            end else if (S_AXI_AWVALID && axi_awready) begin
                axi_awready <= 1'b0;
            end

            if (S_AXI_WVALID && !axi_wready) begin
                axi_wready <= 1'b1;
            end else if (S_AXI_WVALID && axi_wready) begin
                axi_wready <= 1'b0;
            end

            if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end else if (S_AXI_WLAST && axi_wready) begin
                axi_bvalid <= 1'b1;
                axi_bresp <= 2'b00;
            end
        end
    end

    // Read operations (Address + Data)
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_rvalid <= 1'b0;
        end else begin
            if (S_AXI_ARVALID && !axi_arready) begin
                axi_arready <= 1'b1;
                axi_rvalid <= 1'b1;
                axi_araddr <= S_AXI_ARADDR;
            end else if (S_AXI_ARVALID && axi_arready) begin
                axi_arready <= 1'b0;
            end

            if (S_AXI_RREADY && axi_rvalid) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    // UART Transmission Control Logic
    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            tx_start <= 1'b0;
            sending <= 1'b0;
            cntr <= 10'b0;
        end else begin
            if (sent_trig_i && !sending) begin
                sending <= 1'b1;
                din <= data_length_i;
                tx_start <= 1'b1;
            end else if (tx_done_tick) begin
                tx_start <= 1'b0;
                cntr <= cntr + 1;
                if (cntr == data_length_i) begin
                    sending <= 1'b0;
                    cntr <= 10'b0;
                end
            end
        end
    end

endmodule

module axi_slave_interface(
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
    input wire S_AXI_AWVALID,
    input wire S_AXI_WVALID,
    input wire S_AXI_WLAST,
    input wire S_AXI_BREADY,
    input wire S_AXI_ARVALID,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input wire [3:0] S_AXI_ARBURST,
    input wire [3:0] S_AXI_ARLEN,
    input wire S_AXI_RREADY,
    output reg axi_awready,
    output reg axi_wready,
    output reg axi_bvalid,
    output reg [1:0] axi_bresp,
    output reg axi_rvalid,
    output reg [1:0] axi_rresp,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata
);

// Flags for controlling ready signals and write operations
reg axi_awv_awr_flag;
reg axi_arv_arr_flag;
reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
reg [3:0] axi_awburst;
reg [3:0] axi_awlen;
reg [3:0] axi_awlen_cntr;
reg axi_rlast;
reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
reg [3:0] axi_arburst;
reg [3:0] axi_arlen;
reg [3:0] axi_arlen_cntr;
reg axi_buser;
reg [C_S_AXI_DATA_WIDTH-1:0] mem_data_out;

// Write address ready signal
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_awready <= 0;
        axi_awv_awr_flag <= 0;
    end else begin
        if (axi_awready == 0 && S_AXI_AWVALID == 1 && axi_awv_awr_flag == 0 && axi_arv_arr_flag == 0) begin
            axi_awv_awr_flag <= 1;
            axi_awready <= 1;
        end else if (S_AXI_WLAST == 1 && axi_wready == 1) begin
            axi_awv_awr_flag <= 0;
        end else begin
            axi_awready <= 0;
        end
    end
end

// Address latching for write transactions
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_awaddr <= 0;
        axi_awburst <= 0;
        axi_awlen <= 0;
        axi_awlen_cntr <= 0;
    end else begin
        if (axi_awready == 0 && S_AXI_AWVALID == 1 && axi_awv_awr_flag == 0) begin
            axi_awaddr <= S_AXI_AWADDR;
            axi_awlen_cntr <= 0;
            axi_awburst <= S_AXI_AWBURST;
            axi_awlen <= S_AXI_AWLEN;
        end else if (axi_awlen_cntr <= axi_awlen && axi_wready == 1 && S_AXI_WVALID == 1) begin
            axi_awlen_cntr <= axi_awlen_cntr + 1;
            case (axi_awburst)
                2'b00: axi_awaddr <= axi_awaddr;  // Fixed burst
                2'b01: axi_awaddr <= axi_awaddr + 1;  // Incremental burst
                2'b10: axi_awaddr <= axi_awaddr - 1;  // Wrapping burst
                default: axi_awaddr <= axi_awaddr + 1;  // Reserved
            endcase
        end
    end
end

// Write ready signal generation
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_wready <= 0;
    end else begin
        if (axi_wready == 0 && S_AXI_WVALID == 1 && axi_awv_awr_flag == 1) begin
            axi_wready <= 1;
        end else if (S_AXI_WLAST == 1 && axi_wready == 1) begin
            axi_wready <= 0;
        end
    end
end

// Write response logic generation
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_bvalid <= 0;
        axi_bresp <= 2'b00;  // OKAY response
        axi_buser <= 0;
    end else begin
        if (axi_awv_awr_flag == 1 && axi_wready == 1 && S_AXI_WVALID == 1 && axi_bvalid == 0 && S_AXI_WLAST == 1) begin
            axi_bvalid <= 1;
            axi_bresp <= 2'b00;  // OKAY response
        end else if (S_AXI_BREADY == 1 && axi_bvalid == 1) begin
            axi_bvalid <= 0;
        end
    end
end

// Read address ready signal generation
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_arready <= 0;
        axi_arv_arr_flag <= 0;
    end else begin
        if (axi_arready == 0 && S_AXI_ARVALID == 1 && axi_awv_awr_flag == 0 && axi_arv_arr_flag == 0) begin
            axi_arready <= 1;
            axi_arv_arr_flag <= 1;
        end else if (axi_rvalid == 1 && S_AXI_RREADY == 1 && (axi_arlen_cntr == axi_arlen)) begin
            axi_arv_arr_flag <= 0;
        end else begin
            axi_arready <= 0;
        end
    end
end

// Read address latching
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_araddr <= 0;
        axi_arburst <= 0;
        axi_arlen <= 0;
        axi_arlen_cntr <= 0;
        axi_rlast <= 0;
    end else begin
        if (axi_arready == 0 && S_AXI_ARVALID == 1 && axi_arv_arr_flag == 0) begin
            axi_araddr <= S_AXI_ARADDR;
            axi_arlen_cntr <= 0;
            axi_rlast <= 0;
            axi_arburst <= S_AXI_ARBURST;
            axi_arlen <= S_AXI_ARLEN;
        end else if (axi_arlen_cntr <= axi_arlen && axi_rvalid == 1 && S_AXI_RREADY == 1) begin
            axi_arlen_cntr <= axi_arlen_cntr + 1;
            case (axi_arburst)
                2'b00: axi_araddr <= axi_araddr;
                2'b01: axi_araddr <= axi_araddr + 1;
                2'b10: axi_araddr <= axi_araddr - 1;
                default: axi_araddr <= axi_araddr + 1;
            endcase
        end
    end
end

// Read valid signal generation
always @(posedge S_AXI_ACLK) begin
    if (S_AXI_ARESETN == 0) begin
        axi_rvalid <= 0;
        axi_rresp <= 2'b00;
    end else begin
        if (axi_arv_arr_flag == 1 && axi_rvalid == 0) begin
            axi_rvalid <= 1;
            axi_rresp <= 2'b00;  // OKAY response
        end else if (axi_rvalid == 1 && S_AXI_RREADY == 1) begin
            axi_rvalid <= 0;
        end
    end
end

endmodule
