module counter (
    input clk,
    input rst,
    input flag_cnt_i,
    output [CNT_WIDTH-1:0] cnt_o,
    output end_cnt_o
);

reg [CNT_WIDTH-1:0] cnt;

always @(posedge clk) begin
    if(rst) begin
        cnt <= 0;
    end else if (end_cnt_o) begin
        cnt <= 0;
    end else if (flag_cnt_i) begin
        cnt <= cnt + 1;
    end
end

assign end_cnt_o = flag_cnt_i & (cnt == CNT_END - 1);

endmodule