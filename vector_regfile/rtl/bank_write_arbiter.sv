module bank_write_arbiter 
#(
    parameter   X_Y             = 2'b00, // 01, 10, 11, 00 enum?
    parameter   PORT_NUM        = 2,
    parameter   WRITE_BANK_PORT = 1,
    parameter   ADDR_WIDTH      = 5 + 1,
    parameter   ADDR_X_SIZE     = 1,
    parameter   ADDR_X_WIDTH    = 1,
    parameter   ADDR_Y_SIZE     = 16,
    parameter   ADDR_Y_WIDTH    = 4
)(
    input   logic   [PORT_NUM-1:0][ADDR_WIDTH-1:0]          vreg_addr,
    input   logic   [PORT_NUM-1:0]                          vreg_write_select,
    output  logic   [PORT_NUM-1:0]                          bank_write_select,
    output  logic   [WRITE_BANK_PORT-1:0][ADDR_Y_WIDTH-1:0] addr,
    output  logic   [WRITE_BANK_PORT-1:0][PORT_NUM-1:0]     prio_idx
);

genvar i;
logic [PORT_NUM-1:0] req, reg_hit, gnt;

priority_N_1_mux  
#(
    .NUM_REQ(PORT_NUM)
) pri_2_1_mux_u(
    .req    (req),
    .base   (2'b1),
    .gnt    (gnt)
);

generate
    for (i = 0; i < PORT_NUM; i++) begin
        if (X_Y == 2'b00) begin
            assign reg_hit[i] =  (vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) &  (vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 2'b01) begin
            assign reg_hit[i] =  (vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) & ~(vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 2'b10) begin
            assign reg_hit[i] = ~(vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) &  (vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end else if (X_Y == 2'b11) begin
            assign reg_hit[i] = ~(vreg_addr[i][ADDR_X_WIDTH-1:0] < ADDR_X_SIZE) & ~(vreg_addr[i][ADDR_WIDTH-1:ADDR_X_WIDTH] < ADDR_Y_SIZE);
        end
    end
endgenerate

assign req                  = ~vreg_write_select & reg_hit;
assign prio_idx             = gnt;
assign bank_write_select    = gnt;

always_comb begin
    addr = 0;
    for (integer j = 0; j < WRITE_BANK_PORT; j++) begin
        for (int k = 0; k < PORT_NUM; k++) begin
            if (prio_idx[j][k]) begin
                addr[j] = vreg_addr[k][ADDR_X_WIDTH+:ADDR_Y_WIDTH];
            end
        end
    end
end


endmodule