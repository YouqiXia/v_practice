module host_interface (
    input	        		reset					,
    input	        	    clk_reg					,
    output  reg             csb                     ,
    output  reg             wrb                     ,
    output  reg    [15:0]   cd_in                   ,
    input          [15:0]   cd_out                  ,
    output  reg    [7:0]    ca                      
);

reg [63:0] write_counter;
reg [63:0] read_counter;

// addr
parameter addr_Tx_Hwmark                  =7'd00;
parameter addr_Tx_Lwmark                  =7'd01;
parameter addr_pause_frame_send_en        =7'd02;
parameter addr_pause_quanta_set           =7'd03;
parameter addr_IFGset                     =7'd04;
parameter addr_FullDuplex                 =7'd05;
parameter addr_MaxRetry                   =7'd06;
parameter addr_MAC_tx_add_en              =7'd07;
parameter addr_MAC_tx_add_prom_data       =7'd08;
parameter addr_MAC_tx_add_prom_add        =7'd09;
parameter addr_MAC_tx_add_prom_wr         =7'd10;
parameter addr_tx_pause_en                =7'd11;
parameter addr_xoff_cpu                   =7'd12;
parameter addr_xon_cpu                    =7'd13;
parameter addr_MAC_rx_add_chk_en          =7'd14;
parameter addr_MAC_rx_add_prom_data       =7'd15;
parameter addr_MAC_rx_add_prom_add        =7'd16;
parameter addr_MAC_rx_add_prom_wr         =7'd17;
parameter addr_broadcast_filter_en        =7'd18;
parameter addr_broadcast_bucket_depth     =7'd19;
parameter addr_broadcast_bucket_interval  =7'd20;
parameter addr_RX_APPEND_CRC              =7'd21;
parameter addr_Rx_Hwmark                  =7'd22;
parameter addr_Rx_Lwmark                  =7'd23;
parameter addr_CRC_chk_en                 =7'd24;
parameter addr_RX_IFG_SET                 =7'd25;
parameter addr_RX_MAX_LENGTH              =7'd26;
parameter addr_RX_MIN_LENGTH              =7'd27;
parameter addr_CPU_rd_addr                =7'd28;
parameter addr_CPU_rd_apply               =7'd29;
parameter addr_CPU_rd_grant               =7'd30;
parameter addr_CPU_rd_dout_l              =7'd31;
parameter addr_CPU_rd_dout_h              =7'd32;
parameter addr_Line_loop_en               =7'd33;
parameter addr_Speed                      =7'd34;

// ctrl signal
parameter PAUSE_START   = 1;
parameter OPEN          = 1;
parameter CLOSE         = 0;

initial begin
    ca      = 0;
    cd_in   = 0;
    csb     = 1;
    wrb     = 1;
    write_counter   = 0;
    read_counter    = 0;
end

task read_reg(
    input [7:0]     addr_i
);

    reg [15:0]  data;

    @(posedge clk_reg);
    ca      = addr_i << 1;
    cd_in   = 0;
    csb     = 0;
    wrb     = 1;

    @(posedge clk_reg);
    csb     = 1;
    wrb     = 1;
    data    = cd_out;
    read_counter = read_counter + 1;
    $display("read %d: addr = %d, data = %x", read_counter, addr_i, data);

endtask

task write_reg(
    input [7:0]     addr_i,
    input [15:0]    data_i
);

    @(posedge clk_reg);
    ca      = addr_i << 1;
    cd_in   = data_i;
    csb     = 0;
    wrb     = 0;

    @(posedge clk_reg);
    csb     = 1;
    wrb     = 1;
    write_counter = write_counter + 1;
    $display("write %d: addr = %d, data = %x", write_counter, addr_i, data_i);

endtask

task flow_ctrl(
    input flow_ctrl_en
);
    // flow control -> whether send a pause frame
    @(posedge clk_reg);
    if(flow_ctrl_en) begin
        // enable
        write_reg(addr_pause_frame_send_en, 1);
        // pause time
        write_reg(addr_pause_quanta_set, 10);
        // quanta = 0
        write_reg(addr_xoff_cpu, 0);
        // quanta = quanta_data
        write_reg(addr_xon_cpu, 1);
    end else begin
        // disable
        write_reg(addr_pause_frame_send_en, 1);
    end
endtask

task broadcast_ctrl(
    input broadcast_ctrl_en
);
    if(broadcast_ctrl_en) begin
        // Broadcast filter
        write_reg(addr_broadcast_filter_en, 1);
        write_reg(addr_broadcast_bucket_depth, 1);
        write_reg(addr_broadcast_bucket_interval, 10);
    end else begin
        write_reg(addr_broadcast_filter_en, 0);
    end
endtask

task rx_append_crc_ctrl(
    input rx_append_crc_ctrl_en
);
    if (rx_append_crc_ctrl_en) begin
        write_reg(addr_RX_APPEND_CRC, 1);
    end else begin
        write_reg(addr_RX_APPEND_CRC, 0);
    end
endtask

task crc_chk_ctrl(
    input crc_chk_ctrl_en
);
    if (crc_chk_ctrl_en) begin 
        write_reg(addr_CRC_chk_en, 1);
    end else begin
        write_reg(addr_CRC_chk_en, 0);
    end
endtask

task counters_read(
    input [6:0] counters_addr
);
    write_reg(addr_CPU_rd_addr, counters_addr);
    write_reg(addr_CPU_rd_apply, 1);
endtask

task read_init_reg;

    @(posedge clk_reg);

    for(int i = 0; i < 35; i = i + 1) begin
        read_reg(i);
    end

endtask

task init_reg;

    @(posedge clk_reg);
    flow_ctrl(CLOSE);
    broadcast_ctrl(CLOSE);
    rx_append_crc_ctrl(CLOSE);
    crc_chk_ctrl(CLOSE);

endtask


endmodule