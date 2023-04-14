parameter PACKET_SIZE = 100 + 14;

import dut_package::*;
import "DPI-C" function void c_function();
import "DPI-C" function void c_trans(input tx_packet_t tx_packet);
import "DPI-C" function void cpp_long_vector(input bit[1023:0] signal);


module tb_top;

bit [PACKET_SIZE-1:0] packet = 1024'h010101010101010101010101010101010101010101;

reg [CNT_WIDTH-1:0] cnt;
reg clk = 0;
reg rst = 0;
reg flag_cnt;
reg end_cnt;

tx_trans tx_trans_u();
tx_packet_t tx_packet_1;

initial begin
    tx_packet_1.addr = 32;
    tx_packet_1.data = 83;
end

initial begin
    tx_trans_u.init_tx;
    clk = 0;
    rst = 1;
    flag_cnt = 0;
    @(posedge clk);
    @(posedge clk);
    rst = 0;
    flag_cnt = 1;
    @(posedge end_cnt);
    @(posedge end_cnt);
    c_function();
    @(posedge end_cnt);
    tx_trans_u.tx_action;
    @(posedge end_cnt);
    c_trans(tx_packet_1);
    tx_trans_u.tx_action;
    @(posedge end_cnt);
    cpp_long_vector(packet);
    $finish;
end

always #20 clk = ~clk;

counter counter_u(
    .clk(clk),
    .rst(rst),
    .flag_cnt_i(flag_cnt),
    .cnt_o(cnt),
    .end_cnt_o(end_cnt)
);


initial begin
    int dumpon = 0;
    string log;
    string wav;
    $value$plusargs("dumpon=%d",dumpon);
    if ($value$plusargs("sim_log=%s",log)) begin
        $display("wave_log= %s",log);
    end
    wav = {log,"/waves.fsdb"};
    $display("wave_log= %s",wav);
    if(dumpon > 0) begin
      $fsdbDumpfile(wav);
      $fsdbDumpvars(0,tb_top);
      $fsdbDumpvars("+struct");
      $fsdbDumpvars("+mda");
      $fsdbDumpvars("+all");
      $fsdbDumpon;
    end
end

endmodule