module priority_N_2_mux#(
    parameter SEL_WIDTH = 8,
    parameter PRI_IDX_WIDTH = 3
)(
    input   [PRI_IDX_WIDTH-1:0] priority_idx,
    input   [SEL_WIDTH-1:0]     req,
    output  [SEL_WIDTH-1:0]     gnt_first,
    output  [SEL_WIDTH-1:0]     gnt_second
);

parameter PRIORITY_WIDTH = $clog2(SEL_WIDTH);

wire priority_fix;

wire [SEL_WIDTH-1:0] grant, grant_less, mid, mid_less;
wire [SEL_WIDTH*2-1:0] double_grant, double_grant_less;
wire [SEL_WIDTH*3-1:0] double_first_grant_index, double_second_grant_index;
wire [SEL_WIDTH-1:0] first_grant, second_grant;

wire [SEL_WIDTH*2-1:0] double_req;
wire [SEL_WIDTH*2-1:0] double_fixed_req;
wire [SEL_WIDTH-1:0] fixed_req;

assign double_req = {req, req};
assign double_fixed_req = double_req >> priority_idx;
assign fixed_req = double_fixed_req[SEL_WIDTH-1:0];

assign double_grant = {grant, grant};
assign double_grant_less = {grant_less, grant_less};

assign double_first_grant_index = double_grant << priority_idx;
assign double_second_grant_index = double_grant_less << priority_idx;

assign first_grant = double_first_grant_index[SEL_WIDTH*2-1:SEL_WIDTH];
assign second_grant = double_second_grant_index[SEL_WIDTH*2-1:SEL_WIDTH];

assign grant[0] = fixed_req[0];
assign mid[0] = fixed_req[0];
assign mid_less[0] = fixed_req[0] & !grant[0];
assign grant_less[0] = fixed_req[0] & !grant[0];

generate
    for(genvar j = 1; j < SEL_WIDTH; j = j + 1) begin
        assign grant[j] = fixed_req[j] & !mid[j-1];
        assign grant_less[j] = fixed_req[j] & !mid_less[j-1] & !grant[j];
        assign mid[j] = fixed_req[j] | mid[j-1];
        assign mid_less[j] = (fixed_req[j] | mid_less[j-1]) & !grant[j];
    end
endgenerate

assign gnt_first    = first_grant;
assign gnt_second   = second_grant;


endmodule
