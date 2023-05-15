module counter 
import template_pkg::*;
(
    input clk,
    input rst,
    input flag_cnt,
    input info_t info,
    output [CNT_WIDTH-1:0] cnt_o,
    output end_cnt_o
);

reg [CNT_WIDTH-1:0] cnt;

always @(posedge clk) begin
    if(rst) begin
        cnt <= 0;
    end else if (end_cnt_o) begin
        cnt <= 0;
    end else if (flag_cnt) begin
        cnt <= cnt + 1;
    end
end

assign end_cnt_o = flag_cnt & (cnt == CNT_END - 1);

always @(posedge clk) begin
    if (info.vld[0]) begin
        $display("addr0 = %d", info.addr[0][3:0]);
    end else if (info.vld[0]) begin
        $display("addr1 = %d", info.addr[1][3:0]);
    end
end

endmodule