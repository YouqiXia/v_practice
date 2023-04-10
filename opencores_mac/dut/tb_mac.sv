`timescale 1ns/1ps

module tb_top;

reg				reset					;
reg				clk_125m				;
reg				clk_user				;
reg				clk_reg					;
				//user interface 
logic			rx_mac_ra				;
logic			rx_mac_rd				;
logic	[31:0]	rx_mac_data				;
logic	[1:0]	rx_mac_be				;
logic			rx_mac_pa				;
logic			rx_mac_sop				;
logic			rx_mac_eop				;
			    //user interface 
logic			tx_mac_wa	            ;
logic			tx_mac_wr	        	;
logic	[31:0]	tx_mac_data	        	;
logic 	[1:0]	tx_mac_be				;
logic			tx_mac_sop	        	;
logic			tx_mac_eop				;
				//phy interface     	 
				//phy interface			
logic			gtx_clk					;
logic			rx_clk					;
logic			tx_clk					;
logic			tx_er					;
logic			tx_en					;
logic	[7:0]	txd						;
logic			rx_er					;
logic			rx_dv					;
logic 	[7:0]	rxd						;
logic			crs						;
logic			col						;
                //host interface
logic           csb                     ;
logic           wrb                     ;
logic    [15:0] cd_in                   ;
logic    [15:0] cd_out                  ;
logic    [7:0]  ca                      ;
				//phy int host interface 
logic			line_loop_en			;
logic	[2:0]	speed					;
				//mii
wire         	mdio                	;
logic        	mdc                		;
logic           cpu_init_end            ;

// dut
logic [2048-1:0]    packet;
logic [63:0]        packet_size;

initial begin
    reset = 1;
    #1000
    reset = 0;
    host_interface_u.read_init_reg;
    host_interface_u.init_reg;
    repeat (100) @(posedge host_interface.clk_reg);
    user_interface_u.rx_ctrl;
    repeat (100) @(posedge host_interface.clk_reg);
    packet      = 'h180c200000100000000000088080001000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    packet_size = 'd84;
    user_interface_u.tx_ctrl(packet, packet_size);
    repeat (100) @(posedge host_interface.clk_reg);
    user_interface_u.rx_ctrl;
    repeat (100) @(posedge host_interface.clk_reg);
    $finish;
end

MAC_top U_MAC_top(
 //system signals     			(//system signals           ),
.Reset                          (reset					    ),
.Clk_125M				        (clk_125m				    ),
.Clk_user				        (clk_user				    ),
.Clk_reg					    (clk_reg					),
.Speed                          (speed                      ),
 //user interface               (//user interface           ),
.Rx_mac_ra				        (rx_mac_ra				    ),
.Rx_mac_rd				        (rx_mac_rd				    ),
.Rx_mac_data				    (rx_mac_data				),
.Rx_mac_BE				        (rx_mac_be				    ),
.Rx_mac_pa				        (rx_mac_pa				    ),
.Rx_mac_sop				        (rx_mac_sop				    ),
.Rx_mac_eop				        (rx_mac_eop				    ),
 //user interface               (//user interface           ),
.Tx_mac_wa	        	        (tx_mac_wa	        	    ),
.Tx_mac_wr	        	        (tx_mac_wr	        	    ),
.Tx_mac_data	        	    (tx_mac_data	        	),
.Tx_mac_BE				        (tx_mac_be				    ),
.Tx_mac_sop	        	        (tx_mac_sop	        	    ),
.Tx_mac_eop				        (tx_mac_eop				    ),
 //Phy interface     	        (//Phy interface     	    ),
 //Phy interface			    (//Phy interface			),
.Gtx_clk					    (gtx_clk					),
.Rx_clk					        (rx_clk					    ),
.Tx_clk					        (tx_clk					    ),
.Tx_er					        (tx_er					    ),
.Tx_en					        (tx_en					    ),
.Txd						    (txd						),
.Rx_er					        (rx_er					    ),
.Rx_dv					        (rx_dv					    ),
.Rxd						    (rxd						),
.Crs						    (crs						),
.Col						    (col						),
//host interface
.CSB                            (csb                        ),
.WRB                            (wrb                        ),
.CD_in                          (cd_in                      ),
.CD_out                         (cd_out                     ),
.CA                             (ca                         ),
 //MII interface signals        (//MII interface signals    ),
.Mdio                	        (mdio                	    ),
.Mdc                		    (mdc                		)
);

clk_gen clk_gen_u(
    .speed   (speed   ),
    .gtx_clk (gtx_clk ),
    .rx_clk  (rx_clk  ),
    .tx_clk  (tx_clk  ),
    .clk_125M(clk_125m),
    .clk_reg (clk_reg ),
    .clk_user(clk_user)
);

phy_interface phy_interface_u(
    .tx_er  (tx_er),
    .tx_en  (tx_en),
    .txd    (txd  ),
    .rx_er  (rx_er),
    .rx_dv  (rx_dv),
    .rxd    (rxd  ),
    .crs    (crs  ),
    .col    (col  )
);

host_interface host_interface_u(
    .reset	(reset	),
    .clk_reg(clk_reg),
    .csb    (csb    ),
    .wrb    (wrb    ),
    .cd_in  (cd_in  ),
    .cd_out (cd_out ),
    .ca     (ca     )
);

user_interface user_interface_u(
    .reset	     (reset	        ),
    .clk_user    (clk_user      ),
    .cpu_init_end(cpu_init_end  ),     
    .rx_mac_ra   (rx_mac_ra     ),
    .rx_mac_rd   (rx_mac_rd     ),
    .rx_mac_data (rx_mac_data   ),
    .rx_mac_be   (rx_mac_be     ),
    .rx_mac_pa   (rx_mac_pa     ),
    .rx_mac_sop  (rx_mac_sop    ),
    .rx_mac_eop  (rx_mac_eop    ),
    .tx_mac_wa	 (tx_mac_wa	    ), 
    .tx_mac_wr	 (tx_mac_wr	    ), 
    .tx_mac_data (tx_mac_data   ),     
    .tx_mac_be   (tx_mac_be     ),
    .tx_mac_sop	 (tx_mac_sop    ), 
    .tx_mac_eop  (tx_mac_eop    )
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
      $fsdbDumpMDA();
      $fsdbDumpon;
    end
end

endmodule
