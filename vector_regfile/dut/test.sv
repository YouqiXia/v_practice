module tb_top;
import rrv64_core_vec_param_pkg::*;

parameter   PERIOD = 20;

logic       clk = 0;
logic       rstn;

//read port
prf_pipereg_t                       vdq_vrf_read_packet;
logic                               busy;
logic [VLEN-1:0]                    data_v0;
prf_rdata_t                         vrf_rs_packet;

//write port
logic                                     wr0_vld;
logic                                     wr0_conflict;
logic [VREG_ADDR_WIDTH-1:0]               waddr0;
logic [VFULEN-1:0]                        wmask0;
logic [VFULEN-1:0]                        wdata0;
logic                                     wr1_vld;
logic                                     wr1_conflict;
logic [VREG_ADDR_WIDTH-1:0]               waddr1;
logic [VFULEN-1:0]                        wmask1;
logic [VFULEN-1:0]                        wdata1;

always #(PERIOD/2) clk = ~clk;

vector_regfile vector_regfile_u(
    .clk                    (clk),
    .rstn                   (rstn),
    .vdq_vrf_read_packet    (vdq_vrf_read_packet),
    .busy                   (busy),
    .data_v0                (data_v0),
    .vrf_rs_packet          (vrf_rs_packet),
    .wr0_vld                (wr0_vld),
    .wr0_conflict           (wr0_conflict),
    .waddr0                 (waddr0),
    .wmask0                 (wmask0),
    .wdata0                 (wdata0),
    .wr1_vld                (wr1_vld),
    .wr1_conflict           (wr1_conflict),
    .waddr1                 (waddr1),
    .wmask1                 (wmask1),
    .wdata1                 (wdata1)
);

logic [VRF_RPORT_NUM-1:0][VREG_ADDR_WIDTH-1:0] read_addr;

// main {
initial begin
    reset(); 
    for (int i = 0; i < 32*2; i = i + 2) begin
        rand_wr(1,i,1,i+1);
    end
    set_read_addr(1,3,5,7,9,read_addr);
    read_chk(5'b11111, read_addr);
    #(PERIOD * 100);
    $finish;
end
// }

initial begin
    clk     = 0;
    rstn    = 0;
    vdq_vrf_read_packet.vld          = 0;
    vdq_vrf_read_packet.vaddr        = 0;
    vdq_vrf_read_packet.rs_idx       = 0;
    vdq_vrf_read_packet.rs_field_idx = 0;
    wr0_vld        = 0;
    waddr0         = 0;
    wdata0         = 0;
    wr1_vld        = 0;
    waddr1         = 0;
    wdata1         = 0;
end

task reset();
    @(posedge clk);
    rstn = 0;
    @(posedge clk);
    @(posedge clk);
    rstn = 1;
endtask

task rand_wr(
    input                       wen0,
    input [VREG_ADDR_WIDTH-1:0] addr0,
    input                       wen1,
    input [VREG_ADDR_WIDTH-1:0] addr1
);
    @(posedge clk);
    wr0_vld        = wen0;
    waddr0         = addr0;
    wmask0         = {VFULEN{1'b1}};
    wdata0         = $random() & {64{1'b1}};
    wr1_vld        = wen1;
    waddr1         = addr1;
    wmask1         = {VFULEN{1'b1}};
    wdata1         = $random() & {64{1'b1}};
    if (wen0) begin
        $display("write to addr = %x, data = %x", addr0, wdata0);
    end
    if (wen1) begin
        $display("write to addr = %x, data = %x", addr1, wdata1);
    end
    @(posedge clk);
    wr0_vld        = 0;
    wr1_vld        = 0;
endtask //automatic

task set_read_addr(
    input   [VREG_ADDR_WIDTH-1:0] local_addr0,
    input   [VREG_ADDR_WIDTH-1:0] local_addr1,
    input   [VREG_ADDR_WIDTH-1:0] local_addr2,
    input   [VREG_ADDR_WIDTH-1:0] local_addr3,
    input   [VREG_ADDR_WIDTH-1:0] local_addr4,
    output  [VRF_RPORT_NUM-1:0][VREG_ADDR_WIDTH-1:0] addr_packet
);
    addr_packet[0] = local_addr0;
    addr_packet[1] = local_addr1;
    addr_packet[2] = local_addr2;
    addr_packet[3] = local_addr3;
    addr_packet[4] = local_addr4;
endtask

task read_chk(
    input [4:0]                         rd_en,
    input [4:0][VREG_ADDR_WIDTH-1:0]    addr
);
    prf_pipereg_t vrfreq_tmp;
    bit           busy_tmp;
    for (int i = 0; i < VRF_RPORT_NUM; i++) begin
        vrfreq_tmp.vld[i]              = rd_en[i];
        vrfreq_tmp.vaddr[i]            = addr[i];
        vrfreq_tmp.rs_idx[i]           = $random() & {VSB_ENT_NUM{1'b1}};
        vrfreq_tmp.rs_field_idx[i]     = $random() & {2{1'b1}};
    end
    @(posedge clk);
    for (int i = 0; i < VRF_RPORT_NUM; i++) begin
        vdq_vrf_read_packet.vld[i]              = vrfreq_tmp.vld[i];
        vdq_vrf_read_packet.vaddr[i]            = vrfreq_tmp.vaddr[i];
        vdq_vrf_read_packet.rs_idx[i]           = vrfreq_tmp.rs_idx[i];
        vdq_vrf_read_packet.rs_field_idx[i]     = vrfreq_tmp.rs_field_idx[i];
    end
    do begin
        for (int i = 0; i < VRF_RPORT_NUM; i++) begin
            if (vrf_rs_packet.vld[i]) begin
                vrfreq_tmp.vld[i]           = ~vrf_rs_packet.vld[i];
                $display("read addr = %x, data = %x", vrfreq_tmp.vaddr[i], vrf_rs_packet.data[i]);
            end
        end
        busy_tmp = busy;
        @(posedge clk);
    end while (busy_tmp);
endtask

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
      $fsdbDumpMDA();
      $fsdbDumpon;
    end
end

endmodule