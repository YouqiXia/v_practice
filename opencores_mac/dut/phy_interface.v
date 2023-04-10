module phy_interface (
    input			tx_er					,
    input			tx_en					,
    input	[7:0]	txd						,
    output			rx_er					,
    output			rx_dv					,
    output 	[7:0]	rxd						,
    output			crs						,
    output			col						
);

assign rx_dv    = tx_en;
assign rxd      = txd;
assign rx_er    = 0;
assign crs      = tx_en;
assign col      = 0;



endmodule