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

task init_reg;

    @(posedge clk_reg);

    for(int i = 0; i < 35; i = i + 1) begin
        read_reg(i);
    end

endtask

endmodule