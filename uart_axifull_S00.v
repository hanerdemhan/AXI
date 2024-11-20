module uart_axifull_v1_0_S00_AXI #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 4
)(
    // Kullanıcı Portları
    output [9:0] data_length_o,
    output sent_trig_o,

    // AXI Portları
    input S_AXI_ACLK,
    input S_AXI_ARESETN,
    input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input [2:0] S_AXI_AWPROT,
    input S_AXI_AWVALID,
    output reg S_AXI_AWREADY,
    input [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input S_AXI_WVALID,
    output reg S_AXI_WREADY,
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,
    input S_AXI_BREADY,
    input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input [2:0] S_AXI_ARPROT,
    input S_AXI_ARVALID,
    output reg S_AXI_ARREADY,
    output reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input S_AXI_RREADY
);

module uart_axifull_v1_0_S00_AXI #(
    // Kullanıcı parametreleri
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)(
    // Kullanıcı portları
    output wire [9:0] data_length_o,
    output wire sent_trig_o,

    // Sistem portları
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,

    // AXI4-Lite yazma portları
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input wire [2:0] S_AXI_AWPROT,
    input wire S_AXI_AWVALID,
    output reg S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output reg S_AXI_WREADY,
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,
    input wire S_AXI_BREADY,

    // AXI4-Lite okuma portları
    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input wire [2:0] S_AXI_ARPROT,
    input wire S_AXI_ARVALID,
    output reg S_AXI_ARREADY,
    output reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input wire S_AXI_RREADY
);

    // write adress
    always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_awready <= 1'b0;
        axi_awaddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        aw_en <= 1'b1;
    end else begin
        if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
            // Geçerli yazma adresi alınıyor
            axi_awready <= 1'b1;
            axi_awaddr <= S_AXI_AWADDR;
            aw_en <= 1'b0;
        end else if (S_AXI_BREADY && axi_bvalid) begin
            // Yazma işlemi tamamlandığında izin ver
            aw_en <= 1'b1;
            axi_awready <= 1'b0;
        end else begin
            axi_awready <= 1'b0;
        end
    end
end

    // write data
    always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_wready <= 1'b0;
    end else begin
        if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
            // Geçerli yazma verisi kabul ediliyor
            axi_wready <= 1'b1;
        end else begin
            axi_wready <= 1'b0;
        end
    end
end

    //write respone
    always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_bvalid <= 1'b0;
        axi_bresp <= 2'b0;
    end else begin
        if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
            axi_bvalid <= 1'b1;
            axi_bresp <= 2'b0; // Normal tamamlama
        end else if (S_AXI_BREADY && axi_bvalid) begin
            // Master yanıtı kabul etti
            axi_bvalid <= 1'b0;
        end
    end
end

    //read adress
    always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_arready <= 1'b0;
        axi_araddr <= {C_S_AXI_ADDR_WIDTH{1'b0}};
    end else begin
        if (~axi_arready && S_AXI_ARVALID) begin
            // Okuma adresi kabul ediliyor
            axi_arready <= 1'b1;
            axi_araddr <= S_AXI_ARADDR;
        end else begin
            axi_arready <= 1'b0;
        end
    end
end

      //read data
      always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_rvalid <= 1'b0;
        axi_rresp <= 2'b0;
    end else begin
        if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
            // Okuma verisi hazırlanıyor
            axi_rvalid <= 1'b1;
            axi_rresp <= 2'b0; // Normal durum
            case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                2'h0: axi_rdata <= slv_reg0;
                2'h1: axi_rdata <= slv_reg1;
                2'h2: axi_rdata <= slv_reg2;
                2'h3: axi_rdata <= slv_reg3;
                default: axi_rdata <= {C_S_AXI_DATA_WIDTH{1'b0}};
            endcase
        end else if (axi_rvalid && S_AXI_RREADY) begin
            // Master veriyi kabul etti
            axi_rvalid <= 1'b0;
        end
    end
end
