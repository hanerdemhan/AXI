module uart_axifull_custom #(
    // Users to add parameters here
    // MBA START
    parameter integer c_clkfreq = 100_000_000,
    parameter integer c_baudrate = 115_200,
    parameter integer c_stopbit = 2,
    // MBA END
    // User parameters ends

    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4,

    // Parameters of Axi Slave Bus Interface S01_AXI
    parameter integer C_S01_AXI_ID_WIDTH = 1,
    parameter integer C_S01_AXI_DATA_WIDTH = 32,
    parameter integer C_S01_AXI_ADDR_WIDTH = 10,
    parameter integer C_S01_AXI_AWUSER_WIDTH = 1,
    parameter integer C_S01_AXI_ARUSER_WIDTH = 1,
    parameter integer C_S01_AXI_WUSER_WIDTH = 1,
    parameter integer C_S01_AXI_RUSER_WIDTH = 1,
    parameter integer C_S01_AXI_BUSER_WIDTH = 1
) (
    // Users to add ports here
    output wire tx_o,
    // User ports ends

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr,
    input wire [2:0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1:0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr,
    input wire [2:0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata,
    output wire [1:0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready,

    // Ports of Axi Slave Bus Interface S01_AXI
    input wire s01_axi_aclk,
    input wire s01_axi_aresetn,
    input wire [C_S01_AXI_ID_WIDTH-1:0] s01_axi_awid,
    input wire [C_S01_AXI_ADDR_WIDTH-1:0] s01_axi_awaddr,
    input wire [7:0] s01_axi_awlen,
    input wire [2:0] s01_axi_awsize,
    input wire [1:0] s01_axi_awburst,
    input wire s01_axi_awlock,
    input wire [3:0] s01_axi_awcache,
    input wire [2:0] s01_axi_awprot,
    input wire [3:0] s01_axi_awqos,
    input wire [3:0] s01_axi_awregion,
    input wire [C_S01_AXI_AWUSER_WIDTH-1:0] s01_axi_awuser,
    input wire s01_axi_awvalid,
    output wire s01_axi_awready,
    input wire [C_S01_AXI_DATA_WIDTH-1:0] s01_axi_wdata,
    input wire [(C_S01_AXI_DATA_WIDTH/8)-1:0] s01_axi_wstrb,
    input wire s01_axi_wlast,
    input wire [C_S01_AXI_WUSER_WIDTH-1:0] s01_axi_wuser,
    input wire s01_axi_wvalid,
    output wire s01_axi_wready,
    output wire [C_S01_AXI_ID_WIDTH-1:0] s01_axi_bid,
    output wire [1:0] s01_axi_bresp,
    output wire [C_S01_AXI_BUSER_WIDTH-1:0] s01_axi_buser,
    output wire s01_axi_bvalid,
    input wire s01_axi_bready,
    input wire [C_S01_AXI_ID_WIDTH-1:0] s01_axi_arid,
    input wire [C_S01_AXI_ADDR_WIDTH-1:0] s01_axi_araddr,
    input wire [7:0] s01_axi_arlen,
    input wire [2:0] s01_axi_arsize,
    input wire [1:0] s01_axi_arburst,
    input wire s01_axi_arlock,
    input wire [3:0] s01_axi_arcache,
    input wire [2:0] s01_axi_arprot,
    input wire [3:0] s01_axi_arqos,
    input wire [3:0] s01_axi_arregion,
    input wire [C_S01_AXI_ARUSER_WIDTH-1:0] s01_axi_aruser,
    input wire s01_axi_arvalid,
    output wire s01_axi_arready,
    output wire [C_S01_AXI_ID_WIDTH-1:0] s01_axi_rid,
    output wire [C_S01_AXI_DATA_WIDTH-1:0] s01_axi_rdata,
    output wire [1:0] s01_axi_rresp,
    output wire s01_axi_rlast,
    output wire [C_S01_AXI_RUSER_WIDTH-1:0] s01_axi_ruser,
    output wire s01_axi_rvalid,
    input wire s01_axi_rready
);

    // Signal declarations
    reg [9:0] data_length = 0;
    reg sent_trig = 0;

    // Instantiation of Axi Bus Interface S00_AXI
    uart_axifull_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) uart_axifull_v1_0_S00_AXI_inst (
        .data_length_o(data_length),
        .sent_trig_o(sent_trig),
        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );

    // Instantiation of Axi Bus Interface S01_AXI
    uart_axifull_v1_0_S01_AXI #(
        .c_clkfreq(c_clkfreq),
        .c_baudrate(c_baudrate),
        .c_stopbit(c_stopbit),
        .C_S_AXI_ID_WIDTH(C_S01_AXI_ID_WIDTH),
        .C_S_AXI_DATA_WIDTH(C_S01_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S01_AXI_ADDR_WIDTH),
        .C_S_AXI_AWUSER_WIDTH(C_S01_AXI_AWUSER_WIDTH),
        .C_S_AXI_ARUSER_WIDTH(C_S01_AXI_ARUSER_WIDTH),
        .C_S_AXI_WUSER_WIDTH(C_S01_AXI_WUSER_WIDTH),
        .C_S_AXI_RUSER_WIDTH(C_S01_AXI_RUSER_WIDTH),
        .C_S_AXI_BUSER_WIDTH(C_S01_AXI_BUSER_WIDTH)
    ) uart_axifull_v1_0_S01_AXI_inst (
        .data_length_i(data_length),
        .sent_trig_i(sent_trig),
        .tx_o(tx_o),
        .S_AXI_ACLK(s01_axi_aclk),
        .S_AXI_ARESETN(s01_axi_aresetn),
        .S_AXI_AWID(s01_axi_awid),
        .S_AXI_AWADDR(s01_axi_awaddr),
        .S_AXI_AWLEN(s01_axi_awlen),
        .S_AXI_AWSIZE(s01_axi_awsize),
        .S_AXI_AWBURST(s01_axi_awburst),
        .S_AXI_AWLOCK(s01_axi_awlock),
        .S_AXI_AWCACHE(s01_axi_awcache),
        .S_AXI_AWPROT(s01_axi_awprot),
        .S_AXI_AWQOS(s01_axi_awqos),
        .S_AXI_AWREGION(s01_axi_awregion),
        .S_AXI_AWUSER(s01_axi_awuser),
        .S_AXI_AWVALID(s01_axi_awvalid),
        .S_AXI_AWREADY(s01_axi_awready),
        .S_AXI_WDATA(s01_axi_wdata),
        .S_AXI_WSTRB(s01_axi_wstrb),
        .S_AXI_WLAST(s01_axi_wlast),
        .S_AXI_WUSER(s01_axi_wuser),
        .S_AXI_WVALID(s01_axi_wvalid),
        .S_AXI_WREADY(s01_axi_wready),
        .S_AXI_BID(s01_axi_bid),
        .S_AXI_BRESP(s01_axi_bresp),
        .S_AXI_BUSER(s01_axi_buser),
        .S_AXI_BVALID(s01_axi_bvalid),
        .S_AXI_BREADY(s01_axi_bready),
        .S_AXI_ARID(s01_axi_arid),
        .S_AXI_ARADDR(s01_axi_araddr),
        .S_AXI_ARLEN(s01_axi_arlen),
        .S_AXI_ARSIZE(s01_axi_arsize),
        .S_AXI_ARBURST(s01_axi_arburst),
        .S_AXI_ARLOCK(s01_axi_arlock),
        .S_AXI_ARCACHE(s01_axi_arcache),
        .S_AXI_ARPROT(s01_axi_arprot),
        .S_AXI_ARQOS(s01_axi_arqos),
        .S_AXI_ARREGION(s01_axi_arregion),
        .S_AXI_ARUSER(s01_axi_aruser),
        .S_AXI_ARVALID(s01_axi_arvalid),
        .S_AXI_ARREADY(s01_axi_arready),
        .S_AXI_RID(s01_axi_rid),
        .S_AXI_RDATA(s01_axi_rdata),
        .S_AXI_RRESP(s01_axi_rresp),
        .S_AXI_RLAST(s01_axi_rlast),
        .S_AXI_RUSER(s01_axi_ruser),
        .S_AXI_RVALID(s01_axi_rvalid),
        .S_AXI_RREADY(s01_axi_rready)
    );

endmodule
