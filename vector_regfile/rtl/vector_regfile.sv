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
    input   logic                                     wr1_vld,
    output  logic                                     wr1_ready,
    input   logic [ISA_VREG_WIDTH+BANK_X_WIDTH-1:0]   waddr1,
    input   logic [BANK_ROW_SIZE-1:0]                 wdata1,
    input   logic                                     wr2_vld,
    output  logic                                     wr2_ready,
    input   logic [ISA_VREG_WIDTH+BANK_X_WIDTH-1:0]   waddr2,
    input   logic [BANK_ROW_SIZE-1:0]                 wdata1
);

prf_pipereg_t                                                                   prf_pipereg, prf_pipereg_w;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_ff;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_next;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_RPORT_NUM-1:0]                           bank_read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][BANK_COL_WIDTH-1:0]   addr_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][BANK_ROW_SIZE-1:0]    bank_data_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][VRF_RPORT_NUM-1:0]    prio_idx_w;

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

assign read_select_next = read_select_ff | read_select_w;
assign read_select_w    = bank_read_select_w[2'b00] | bank_read_select_w[2'b01] | bank_read_select_w[2'b10] | bank_read_select_w[2'b11];
assign busy             = &read_select_next;

bank_read_arbiter #(
    .X_Y                (2'b00),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VERG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b00]),
    .addr               (addr_w[2'b00]),
    .prio_idx_w         (prio_idx_w[2'b00])
);

bank_read_arbiter #(
    .X_Y                (2'b01),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VERG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b01]),
    .addr               (addr_w[2'b01]),
    .prio_idx_w         (prio_idx_w[2'b01])
);

bank_read_arbiter #(
    .X_Y                (2'b10),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VERG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b10]),
    .addr               (addr_w[2'b10]),
    .prio_idx_w         (prio_idx_w[2'b10])
);

bank_read_arbiter #(
    .X_Y                (2'b11),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VERG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_ff),
    .bank_read_select   (bank_read_select_w[2'b11]),
    .addr               (addr_w[2'b11]),
    .prio_idx_w         (prio_idx_w[2'b11])
);

bank_write_arbiter 

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_00_bank (
    .raddr1    (addr_w[2'b00][0]),
    .raddr2    (addr_w[2'b00][1]),
    .wen       (),
    .waddr     (),
    .wdata     (),
    .rdata1    (bank_data_w[2'b00][0]),
    .rdata2    (bank_data_w[2'b00][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_01_bank (
    .raddr1    (addr_w[2'b01][0]),
    .raddr2    (addr_w[2'b01][1]),
    .wen       (),
    .waddr     (),
    .wdata     (),
    .rdata1    (bank_data_w[2'b01][0]),
    .rdata2    (bank_data_w[2'b01][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_10_bank (
    .raddr1    (addr_w[2'b10][0]),
    .raddr2    (addr_w[2'b10][1]),
    .wen       (),
    .waddr     (),
    .wdata     (),
    .rdata1    (bank_data_w[2'b10][0]),
    .rdata2    (bank_data_w[2'b10][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_11_bank (
    .raddr1    (addr_w[2'b11][0]),
    .raddr2    (addr_w[2'b11][1]),
    .wen       (),
    .waddr     (),
    .wdata     (),
    .rdata1    (bank_data_w[2'b11][0]),
    .rdata2    (bank_data_w[2'b11][1])
);

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
                vrf_rs_packet.vld[i]            |= prio_idx_w[j][k][i];
                if (prio_idx_w[j][k][i]) begin
                    vrf_rs_packet.data[i]       = bank_data_w[j][k];
                end
            end
        end
    end
end

endmodule