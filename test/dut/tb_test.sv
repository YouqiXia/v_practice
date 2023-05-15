module tb_top
import template_pkg::*;
();

logic   [CNT_WIDTH-1:0] cnt;
logic   clk = 0;
logic   rst = 0;
logic   flag_cnt;
logic   end_cnt;
info_t  info;

initial begin
    clk = 0;
    rst = 1;
    flag_cnt = 0;
    @(posedge clk);
    @(posedge clk);
    rst = 0;
    flag_cnt = 1;
    #(1000)
    $finish;
end

always #20 begin
    info.vld[0] = $random() & 1'b1;
    info.vld[1] = $random() & 1'b1;
    info.addr[0] = $random() & 8'hFF;
    info.addr[1] = $random() & 8'hFF;
end

always #20 clk = ~clk;

// counter counter_u(*);

counter counter_u(
    .clk(clk),
    .rst(rst),
    .flag_cnt(flag_cnt),
    .info(info),
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