module user_interface(
    input			reset					,
    input			clk_user				,
    input           cpu_init_end            ,
                    //user inputerface 
    input			rx_mac_ra				,
    output			rx_mac_rd				,
    input	[31:0]	rx_mac_data				,
    input	[1:0]	rx_mac_be				,
    input			rx_mac_pa				,
    input			rx_mac_sop				,
    input			rx_mac_eop				,
                    //user inputerface 
    input			tx_mac_wa	        	,
    output			tx_mac_wr	        	,
    output	[31:0]	tx_mac_data	        	,
    output 	[1:0]	tx_mac_be				,//big endian
    output			tx_mac_sop	        	,
    output			tx_mac_eop				
);

assign rx_mac_rd    = 0;

assign tx_mac_wr    = 0;
assign tx_mac_data  = 0;
assign tx_mac_be    = 0;
assign tx_mac_sop   = 0;
assign tx_mac_eop   = 0;

endmodule