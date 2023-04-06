module tb_top;

reg [CNT_WIDTH-1:0] cnt;
reg clk = 0;
reg rst = 0;
reg flag_cnt;
reg end_cnt;

tx_trans tx_trans_u();

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
    tx_trans_u.tx_action;
    @(posedge end_cnt);
    tx_trans_u.tx_action;
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