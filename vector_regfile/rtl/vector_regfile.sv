module vector_regfile 
import rrv64_core_vec_param_pkg::*;
(
    input                                       clk,
    input                                       rstn,

    //read port
    input   prf_pipereg_t                       vdq_vrf_read_packet,
    output  logic                               busy,
    output  logic [VLEN-1:0]                    data_v0,
    output  prf_rdata_t                         vrf_rs_packet,

    //write port
    input   logic                                     wr0_vld,
    output  logic                                     wr0_conflict,
    input   logic [VREG_ADDR_WIDTH-1:0]               waddr0,
    input   logic [VFULEN-1:0]                        wmask0,
    input   logic [VFULEN-1:0]                        wdata0,
    input   logic                                     wr1_vld,
    output  logic                                     wr1_conflict,
    input   logic [VREG_ADDR_WIDTH-1:0]               waddr1,
    input   logic [VFULEN-1:0]                        wmask1,
    input   logic [VFULEN-1:0]                        wdata1
);

logic           [VFULEN-1:0]                                                    vector_arch_v0_low, vector_arch_v0_high;
prf_pipereg_t                                                                   prf_pipereg, prf_pipereg_w;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_ff;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_next;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_RPORT_NUM-1:0]                           bank_read_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][PERBANK_ROW_WIDTH-1:0]raddr_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][VFULEN-1:0]           bank_data_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_RPORT-1:0][VRF_RPORT_NUM-1:0]    rd_prio_idx_w;

logic           [VRF_WPORT_NUM-1:0][VREG_ADDR_WIDTH-1:0]                        vreg_waddr_w;
logic           [VRF_WPORT_NUM-1:0][VFULEN-1:0]                                 vreg_wmask_w;
logic           [VRF_WPORT_NUM-1:0][VFULEN-1:0]                                 vreg_wdata_w;
logic           [VRF_WPORT_NUM-1:0]                                             write_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_WPORT_NUM-1:0]                           bank_write_select_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][PERBANK_ROW_WIDTH-1:0]waddr_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0]                       wen_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][VFULEN-1:0]           wmask_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][VFULEN-1:0]           wdata_w;
logic           [VRF_BANK_NUM-1:0][VRF_PREBANK_WPORT-1:0][VRF_WPORT_NUM-1:0]    wr_prio_idx_w;

logic                                                                           wr0_nonconf_vld;
logic                                                                           wr1_nonconf_vld;
logic           [VRF_RPORT_NUM-1:0]                                             wr_rd_conf_stall;
logic           [VRF_RPORT_NUM-1:0]                                             read_select_byconf;

assign data_v0       = {vector_arch_v0_high, vector_arch_v0_low};

always @(posedge clk) begin
    if (~rstn) begin
        prf_pipereg.vld             <= 0;
        prf_pipereg.vaddr           <= 0;
        prf_pipereg.rs_idx          <= 0;
        prf_pipereg.rs_field_idx    <= 0;
    end else if (~busy) begin
        prf_pipereg = vdq_vrf_read_packet;
    end 
end

assign prf_pipereg_w = prf_pipereg;

always_ff @(posedge clk) begin
    if (~rstn) begin
        read_select_ff <= '1;
    end else if (~busy) begin
        read_select_ff <= ~vdq_vrf_read_packet.vld;
    end else begin
        read_select_ff <= read_select_next;
    end
end

//read arbiter
assign read_select_next     = read_select_ff | read_select_w;
assign read_select_w        = bank_read_select_w[2'b00] | bank_read_select_w[2'b01] | bank_read_select_w[2'b10] | bank_read_select_w[2'b11];
assign busy                 = ~(&read_select_next);
assign read_select_byconf   = wr_rd_conf_stall | read_select_ff;

bank_read_arbiter #(
    .X_Y                (2'b00),
    .PORT_NUM           (VRF_RPORT_NUM),
    .READ_BANK_PORT     (VRF_PREBANK_RPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_read_00_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_byconf),
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
) bank_read_01_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_byconf),
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
) bank_read_10_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_byconf),
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
) bank_read_11_rarbiter (
    .vreg_addr          (prf_pipereg_w.vaddr),
    .vreg_read_select   (read_select_byconf),
    .bank_read_select   (bank_read_select_w[2'b11]),
    .addr               (raddr_w[2'b11]),
    .prio_idx           (rd_prio_idx_w[2'b11])
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
                vrf_rs_packet.vld[i]            |= rd_prio_idx_w[j][k][i];
                if (rd_prio_idx_w[j][k][i]) begin
                    vrf_rs_packet.data[i]       = bank_data_w[j][k];
                end
            end
        end
    end
end

// write arbiter
assign vreg_waddr_w[0]      = waddr0;
assign vreg_waddr_w[1]      = waddr1;
assign write_select_w[0]    = ~wr0_vld;
assign write_select_w[1]    = ~wr1_vld;
assign wr0_nonconf_vld      = wr0_vld & ~wr0_conflict;
assign wr1_nonconf_vld      = wr1_vld & ~wr1_conflict; 
assign vreg_wmask_w[0]      = wmask0;
assign vreg_wmask_w[1]      = wmask1;
assign vreg_wdata_w[0]      = wdata0;
assign vreg_wdata_w[1]      = wdata1;

assign wr0_conflict            = wr0_vld & ~(bank_write_select_w[2'b00][0] | bank_write_select_w[2'b01][0] | bank_write_select_w[2'b10][0] | bank_write_select_w[2'b11][0]);
assign wr1_conflict            = wr1_vld & ~(bank_write_select_w[2'b00][1] | bank_write_select_w[2'b01][1] | bank_write_select_w[2'b10][1] | bank_write_select_w[2'b11][1]);
bank_write_arbiter #(
    .X_Y                (2'b00),
    .PORT_NUM           (VRF_WPORT_NUM),
    .WRITE_BANK_PORT    (VRF_PREBANK_WPORT),
    .ADDR_WIDTH         (VREG_ADDR_WIDTH),
    .ADDR_X_SIZE        (PERBANK_COL_SIZE),
    .ADDR_X_WIDTH       (PERBANK_COL_WIDTH),
    .ADDR_Y_SIZE        (PERBANK_ROW_SIZE),
    .ADDR_Y_WIDTH       (PERBANK_ROW_WIDTH)
) bank_write_00_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select_w[2'b00]),
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
) bank_write_01_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select_w[2'b01]),
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
) bank_write_10_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select_w[2'b10]),
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
) bank_write_11_rarbiter (
    .vreg_addr          (vreg_waddr_w),
    .vreg_write_select  (write_select_w),
    .bank_write_select  (bank_write_select_w[2'b11]),
    .addr               (waddr_w[2'b11]),
    .prio_idx           (wr_prio_idx_w[2'b11])
); 

always_comb begin
    wen_w   = 0;
    wmask_w = 0;
    wdata_w = 0;
    for (int i = 0; i < VRF_BANK_NUM; i++) begin
        for (int j = 0; j < VRF_PREBANK_WPORT; j++) begin
            for (int k = 0; k < VRF_WPORT_NUM; k++) begin
                wen_w[i][j] |= wr_prio_idx_w[i][j][k];
                if (wr_prio_idx_w[i][j][k]) begin
                    wmask_w[i][j] = vreg_wmask_w[k];
                    wdata_w[i][j] = vreg_wdata_w[k];
                end
            end
        end
    end
end

generate
    genvar gen_i;
    for (gen_i = 0; gen_i < VRF_RPORT_NUM; gen_i++) begin
        assign wr_rd_conf_stall[gen_i] = ((prf_pipereg_w.vaddr[gen_i] == waddr0) & wr0_nonconf_vld) | ((prf_pipereg_w.vaddr[gen_i] == waddr1) & wr1_nonconf_vld);
    end
endgenerate

// regfile bank
regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_00_bank (
    .clk       (clk),
    .raddr1    (raddr_w[2'b00][0]),
    .raddr2    (raddr_w[2'b00][1]),
    .wen       (wen_w[2'b00][0]),
    .waddr     (waddr_w[2'b00][0]),
    .wmask     (wmask_w[2'b00][0]),
    .wdata     (wdata_w[2'b00][0]),
    .rdata1    (bank_data_w[2'b00][0]),
    .rdata2    (bank_data_w[2'b00][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_01_bank (
    .clk       (clk),
    .raddr1    (raddr_w[2'b01][0]),
    .raddr2    (raddr_w[2'b01][1]),
    .wen       (wen_w[2'b01][0]),
    .waddr     (waddr_w[2'b01][0]),
    .wmask     (wmask_w[2'b01][0]),
    .wdata     (wdata_w[2'b01][0]),
    .rdata1    (bank_data_w[2'b01][0]),
    .rdata2    (bank_data_w[2'b01][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_10_bank (
    .clk       (clk),
    .raddr1    (raddr_w[2'b10][0]),
    .raddr2    (raddr_w[2'b10][1]),
    .wen       (wen_w[2'b10][0]),
    .waddr     (waddr_w[2'b10][0]),
    .wmask     (wmask_w[2'b10][0]),
    .wdata     (wdata_w[2'b10][0]),
    .rdata1    (bank_data_w[2'b10][0]),
    .rdata2    (bank_data_w[2'b10][1])
);

regfile_bank #(
    .ROW       (PERBANK_ROW_SIZE),
    .ROW_WIDTH (PERBANK_ROW_WIDTH),
    .WIDTH     (VFULEN)
) vregfile_11_bank (
    .clk       (clk),
    .raddr1    (raddr_w[2'b11][0]),
    .raddr2    (raddr_w[2'b11][1]),
    .wen       (wen_w[2'b11][0]),
    .waddr     (waddr_w[2'b11][0]),
    .wmask     (wmask_w[2'b11][0]),
    .wdata     (wdata_w[2'b11][0]),
    .rdata1    (bank_data_w[2'b11][0]),
    .rdata2    (bank_data_w[2'b11][1])
);

always @(posedge clk) begin
    if (waddr0 == 0) begin
        for (int i = 0; i < VFULEN; i++) begin
            if (wmask0[i]) begin
                vector_arch_v0_low[i] = wdata0[i];
            end
        end
    end 
    if (waddr0 == 1) begin
        for (int i = 0; i < VFULEN; i++) begin
            if (wmask0[i]) begin
                vector_arch_v0_high[i] = wdata0[i];
            end
        end
    end 
    if (waddr1 == 0) begin
        for (int i = 0; i < VFULEN; i++) begin
            if (wmask1[i]) begin
                vector_arch_v0_low[i] = wdata1[i];
            end
        end
    end 
    if (waddr1 == 1) begin
        for (int i = 0; i < VFULEN; i++) begin
            if (wmask1[i]) begin
                vector_arch_v0_high[i] = wdata1[i];
            end
        end
    end 
end

// simulation interface

logic [ISA_VREG_NUM-1:0] [VLEN-1:0] vrf;
logic [ISA_VREG_NUM-1:0] [VLEN/VFULEN-1:0] [VFULEN-1:0] vrf_bank;

generate
    for (genvar i = 0; i < ISA_VREG_NUM; i++) begin
        for (genvar j = 0; j < VLEN/VFULEN; j++) begin
           assign vrf[i][j*VFULEN+:VFULEN] = vrf_bank[i][j];
        end
    end

    for (genvar i = 0; i < ISA_VREG_NUM; i++) begin
        for (genvar j = 0; j < VLEN/VFULEN; j++) begin
            if ((i < PERBANK_ROW_SIZE) & (j < PERBANK_COL_SIZE)) begin
                assign vrf_bank[i][j] = vregfile_00_bank.regfile[i]; 
            end else if (!(i < PERBANK_ROW_SIZE) &  (j < PERBANK_COL_SIZE)) begin
                assign vrf_bank[i][j] = vregfile_01_bank.regfile[i-PERBANK_ROW_SIZE]; 
            end else if ( (i < PERBANK_ROW_SIZE) & !(j < PERBANK_COL_SIZE)) begin
                assign vrf_bank[i][j] = vregfile_10_bank.regfile[i]; 
            end else if (!(i < PERBANK_ROW_SIZE) & !(j < PERBANK_COL_SIZE)) begin
                assign vrf_bank[i][j] = vregfile_11_bank.regfile[i-PERBANK_ROW_SIZE]; 
            end
        end
    end
endgenerate

endmodule