module vector_regfile 
import rrv64_core_vec_param_pkg::*;
(
    input                                       clk,
    input                                       rstn,

    //read port
    input   prf_pipereg_t                       vdq_vrf_read_packet,
    output  logic                               busy,
    output  prf_rdata_t                         vrf_rs_packet,

    //write port
    input   logic                                     wr0_vld,
    output  logic                                     wr0_conflict,
    input   logic [VREG_ADDR_WIDTH-1:0]               waddr0,
    input   logic [VFULEN-1:0]                        wdata0,
    input   logic                                     wr1_vld,
    output  logic                                     wr1_conflict,
    input   logic [VREG_ADDR_WIDTH-1:0]               waddr1,
    input   logic [VFULEN-1:0]                        wdata1
);

/******************************** BUG ********************************/
prf_pipereg_t                                                                   prf_pipereg, prf_pipereg_w;
logic           [VRF_BANK_NUM-1:0]                                              read_select_ff;
logic           [VRF_BANK_NUM-1:0]                                              read_select_next;
logic           [VRF_BANK_NUM-1:0]                                              read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_RPORT_NUM-1:0]                           bank_read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][PERBANK_ROW_SIZE-1:0] raddr_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][VFULEN-1:0]           bank_data_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][VRF_RPORT_NUM-1:0]    rd_prio_idx_w;

logic           [VRF_BANK_NUM-1:0][VREG_ADDR_WIDTH-1:0]                         vreg_waddr_w;
logic           [VRF_BANK_NUM-1:0][VFULEN-1:0]                                  vreg_wdata_w;
logic           [VRF_BANK_NUM-1:0]                                              write_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_WPORT_NUM-1:0]                           bank_write_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][PERBANK_ROW_SIZE-1:0] waddr_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0]                       wen_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][VFULEN-1:0]           wdata_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][VRF_WPORT_NUM-1:0]    wr_prio_idx_w;
/******************************** BUG ********************************/

always @(posedge clk) begin
    if (~rstn) begin
        for (integer i = 0; i < 5; i++) begin
            prf_pipereg[i].vld  <= 0;
            prf_pipereg[i].done <= 0;
        end
    end else if (~busy) begin
        prf_pipereg = vdq_vrf_read_packet;
    end 
end

assign prf_pipereg_w = prf_pipereg;

always_ff @(posedge clk) begin
    if (~rstn) begin
        read_select_ff <= 0;
    end else if (~busy) begin
        read_select_ff <= ~vdq_vrf_read_packet.vld;
    end else begin
        read_select_ff <= read_select_next;
    end
end

//read arbiter
assign read_select_next = read_select_ff | read_select_w;
assign read_select_w    = bank_read_select_w[2'b00] | bank_read_select_w[2'b01] | bank_read_select_w[2'b10] | bank_read_select_w[2'b11];
assign busy             = &read_select_next;

bank_read_arbiter #(
    .X_Y                (2'b00),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b00]),
    .addr               (raddr_w[2'b00]),
    .prio_idx           (rd_prio_idx_w[2'b00])
);

bank_read_arbiter #(
    .X_Y                (2'b01),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b01]),
    .addr               (raddr_w[2'b01]),
    .prio_idx           (rd_prio_idx_w[2'b01])
);

bank_read_arbiter #(
    .X_Y                (2'b10),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b10]),
    .addr               (raddr_w[2'b10]),
    .prio_idx           (rd_prio_idx_w[2'b10])
);

bank_read_arbiter #(
    .X_Y                (2'b11),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b11]),
    .addr               (raddr_w[2'b11]),
    .prio_idx           (rd_prio_idx_w[2'b11])
);

/******************************** BUG ********************************/
always_comb begin
    vrf_rs_packet.vld           = 0;
    vrf_rs_packet.data          = 0;
    vrf_rs_packet.rs_idx        = 0;
    vrf_rs_packet.rs_field_idx  = 0;
    for (int i = 0; i < VRF_RPORT_NUM; i++) begin
        vrf_rs_packet.rs_idx[i]         = prf_pipereg_w.rs_idx[i];
        vrf_rs_packet.rs_field_idx[i]   = prf_pipereg_w.rs_field_idx[i];
        for (int j = 0; j < VRF_BANK_NUM; j++) begin
            for (int k = 0; k < VRF_PREBANK_RPORT; k++) begin
                vrf_rs_packet.vld[i]            |= rd_prio_idx_w[j][k][i];
                if (rd_prio_idx_w[j][k][i]) begin
                    vrf_rs_packet.data[i]       = bank_data_w[j][k];
                end
            end
        end
    end
end
/******************************** BUG ********************************/

// write arbiter
assign vreg_waddr_w[0]      = waddr0;
assign vreg_waddr_w[1]      = waddr1;
assign write_select_w[0]    = wr0_vld;
assign write_select_w[1]    = wr1_vld;
assign vreg_wdata_w[0]      = wdata0;
assign vreg_wdata_w[1]      = wdata1;

assign wr0_conflict            = wr0_vld & ~(wr_prio_idx_w[2'b00][0][0] | wr_prio_idx_w[2'b01][0][0] | wr_prio_idx_w[2'b10][0][0] | wr_prio_idx_w[2'b11][0][0]);
assign wr1_conflict            = wr1_vld & ~(wr_prio_idx_w[2'b00][0][1] | wr_prio_idx_w[2'b01][0][1] | wr_prio_idx_w[2'b10][0][1] | wr_prio_idx_w[2'b11][0][1]);
bank_write_arbiter #(
    .X_Y                (2'b00),
    .PORT_NUM           (VRF_WPORT_NUM),
    .WRITE_BANK_PORT    (VRF_PREBANK_WPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select[2'b00]),
    .addr               (waddr_w[2'b00]),
    .prio_idx           (wr_prio_idx_w[2'b00])
); 

bank_write_arbiter #(
    .X_Y                (2'b01),
    .PORT_NUM           (VRF_WPORT_NUM),
    .WRITE_BANK_PORT    (VRF_PREBANK_WPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select[2'b01]),
    .addr               (waddr_w[2'b01]),
    .prio_idx           (wr_prio_idx_w[2'b01])
); 

bank_write_arbiter #(
    .X_Y                (2'b10),
    .PORT_NUM           (VRF_WPORT_NUM),
    .WRITE_BANK_PORT    (VRF_PREBANK_WPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select[2'b10]),
    .addr               (waddr_w[2'b10]),
    .prio_idx           (wr_prio_idx_w[2'b10])
); 

bank_write_arbiter #(
    .X_Y                (2'b11),
    .PORT_NUM           (VRF_WPORT_NUM),
    .WRITE_BANK_PORT    (VRF_PREBANK_WPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select[2'b11]),
    .addr               (waddr_w[2'b11]),
    .prio_idx           (wr_prio_idx_w[2'b11])
); 

always_comb begin
    for (int i = 0; i < )
end

// regfile bank
regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_00_bank (
    .raddr1    (raddr_w[2'b00][0]),
    .raddr2    (raddr_w[2'b00][1]),
    .wen       (wen_w[2'b00][0]),
    .waddr     (waddr_w[2'b00][0]),
    .wdata     (wdata_w[2'b00][0]),
    .rdata1    (bank_data_w[2'b00][0]),
    .rdata2    (bank_data_w[2'b00][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_01_bank (
    .raddr1    (raddr_w[2'b01][0]),
    .raddr2    (raddr_w[2'b01][1]),
    .wen       (),
    .waddr     (waddr_w[2'b11][0]),
    .wdata     (),
    .rdata1    (bank_data_w[2'b01][0]),
    .rdata2    (bank_data_w[2'b01][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_10_bank (
    .raddr1    (raddr_w[2'b10][0]),
    .raddr2    (raddr_w[2'b10][1]),
    .wen       (),
    .waddr     (waddr_w[2'b11][0]),
    .wdata     (),
    .rdata1    (bank_data_w[2'b10][0]),
    .rdata2    (bank_data_w[2'b10][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_11_bank (
    .raddr1    (raddr_w[2'b11][0]),
    .raddr2    (raddr_w[2'b11][1]),
    .wen       (),
    .waddr     (waddr_w[2'b11][0]),
    .wdata     (),
    .rdata1    (bank_data_w[2'b11][0]),
    .rdata2    (bank_data_w[2'b11][1])
);

endmodule