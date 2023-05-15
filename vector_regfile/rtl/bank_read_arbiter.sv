module bank_read_arbiter 
#(
    parameter   X_Y             = 2'b00, // 01, 10, 11, 00 enum?
    parameter   PORT_NUM        = 5,
    parameter   READ_BANK_PORT  = 2,
    parameter   ADDR_WIDTH      = 5 + 1;
    parameter   ADDR_X_SIZE     = 1,
    parameter   ADDR_X_WIDTH    = 1,
    parameter   ADDR_Y_SIZE     = 16,
    parameter   ADDR_Y_WIDTH    = 4,
)(
    input   logic   [READ_BANK_PORT-1:0][ADDR_WIDTH-1:0]    vreg_addr,
    input   logic   [PORT_NUM-1:0]                          vreg_read_select,
    output  logic   [PORT_NUM-1:0]                          bank_read_select,
    output  logic   [READ_BANK_PORT-1:0][ADDR_Y_WIDTH-1:0]  addr,
    output  logic   [READ_BANK_PORT-1:0][PORT_NUM-1:0]      prio_idx
);

genvar i;
logic [PORT_NUM-1:0] req, reg_hit, gnt_first, gnt_second;

priority_N_2_mux pri_5_2_mux_u 
#(
    SEL_WIDTH(PORT_NUM),
)(
    .priority_idx(0),
    .req(req),
    .gnt_first(gnt_first),
    .gnt_second(gnt_second)
);

generate
    for (i = 0; i < PORT_NUM; i++) begin
        if (X_Y == 00) begin
            assign reg_hit[i] =  (vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) &  (vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 01) begin
            assign reg_hit[i] =  (vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) & ~(vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 10) begin
            assign reg_hit[i] = ~(vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) &  (vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 11) begin
            assign reg_hit[i] = ~(vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) & ~(vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end
    end
endgenerate

assign req              = ~vreg_read_select & reg_hit;
assign prio_idx[0]      = gnt_first;
assign prio_idx[1]      = gnt_second;
assign bank_read_select = gnt_first | gnt_second;

always_comb begin
    addr = 0;
    for (integer j = 0; j < PORT_NUM; j++) begin
        if (prio_idx[0][j]) begin
            addr[0] = vreg_addr[j][ADDR_X_WIDTH+:ADDR_Y_WIDTH];
        end
        if (prio_idx[1][j]) begin
            addr[1] = vreg_addr[j][ADDR_X_WIDTH+:ADDR_Y_WIDTH];
        end
    end
end


endmodule