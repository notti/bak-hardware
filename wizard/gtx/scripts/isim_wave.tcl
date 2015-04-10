###############################################################################
##$Date: 2008/05/30 00:57:53 $
##$RCSfile: isim_wave_tcl.ejava,v $
##$Revision: 1.1.2.1 $
###############################################################################
## isim_wave.tcl
###############################################################################



scope /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check0
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
scope /EXAMPLE_TB/example_mgt_top_i/tile0_frame_check1
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
scope /EXAMPLE_TB/example_mgt_top_i/tile1_frame_check0
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
scope /EXAMPLE_TB/example_mgt_top_i/tile1_frame_check1
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
scope /EXAMPLE_TB/example_mgt_top_i/tile2_frame_check0
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
scope /EXAMPLE_TB/example_mgt_top_i/tile2_frame_check1
ntrace select -n begin_r track_data_r data_error_detected_r start_of_packet_detected_r RX_DATA ERROR_COUNT
## {Receive Ports - 8b10b Decoder }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXCHARISCOMMA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXCHARISCOMMA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXDISPERR0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXDISPERR1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXNOTINTABLE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXNOTINTABLE1_OUT
## {Receive Ports - Comma Detection and Alignment }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXBYTEISALIGNED0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXBYTEISALIGNED1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXENMCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXENMCOMMAALIGN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXENPCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXENPCOMMAALIGN1_IN
## {Receive Ports - RX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXDATA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXDATA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXRECCLK0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXRECCLK1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXUSRCLK21_IN
## {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXEQMIX0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXEQMIX1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXP0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXP1_IN
## {Receive Ports - RX Polarity Control Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXPOLARITY0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RXPOLARITY1_IN
## {Shared Ports - Tile and PLL Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n CLKIN_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n GTXRESET_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n PLLLKDET_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n REFCLKOUT_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RESETDONE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n RESETDONE1_OUT
## {Transmit Ports - TX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXDATA0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXDATA1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXUSRCLK21_IN
## {Transmit Ports - TX Driver and OOB signalling }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXN0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXN1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXP0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile0_gtx_i
ntrace select -n TXP1_OUT

## {Receive Ports - 8b10b Decoder }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXCHARISCOMMA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXCHARISCOMMA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXDISPERR0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXDISPERR1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXNOTINTABLE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXNOTINTABLE1_OUT
## {Receive Ports - Comma Detection and Alignment }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXBYTEISALIGNED0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXBYTEISALIGNED1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXENMCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXENMCOMMAALIGN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXENPCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXENPCOMMAALIGN1_IN
## {Receive Ports - RX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXDATA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXDATA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXRECCLK0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXRECCLK1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXUSRCLK21_IN
## {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXEQMIX0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXEQMIX1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXP0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXP1_IN
## {Receive Ports - RX Polarity Control Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXPOLARITY0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RXPOLARITY1_IN
## {Shared Ports - Tile and PLL Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n CLKIN_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n GTXRESET_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n PLLLKDET_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n REFCLKOUT_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RESETDONE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n RESETDONE1_OUT
## {Transmit Ports - TX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXDATA0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXDATA1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXUSRCLK21_IN
## {Transmit Ports - TX Driver and OOB signalling }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXN0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXN1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXP0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile1_gtx_i
ntrace select -n TXP1_OUT

## {Receive Ports - 8b10b Decoder }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXCHARISCOMMA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXCHARISCOMMA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXDISPERR0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXDISPERR1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXNOTINTABLE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXNOTINTABLE1_OUT
## {Receive Ports - Comma Detection and Alignment }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXBYTEISALIGNED0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXBYTEISALIGNED1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXENMCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXENMCOMMAALIGN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXENPCOMMAALIGN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXENPCOMMAALIGN1_IN
## {Receive Ports - RX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXDATA0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXDATA1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXRECCLK0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXRECCLK1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXUSRCLK21_IN
## {Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXEQMIX0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXEQMIX1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXN0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXN1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXP0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXP1_IN
## {Receive Ports - RX Polarity Control Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXPOLARITY0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RXPOLARITY1_IN
## {Shared Ports - Tile and PLL Ports }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n CLKIN_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n GTXRESET_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n PLLLKDET_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n REFCLKOUT_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RESETDONE0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n RESETDONE1_OUT
## {Transmit Ports - TX Data Path interface }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXDATA0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXDATA1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXUSRCLK0_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXUSRCLK1_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXUSRCLK20_IN
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXUSRCLK21_IN
## {Transmit Ports - TX Driver and OOB signalling }
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXN0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXN1_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXP0_OUT
scope /EXAMPLE_TB/example_mgt_top_i/gtx_i/tile2_gtx_i
ntrace select -n TXP1_OUT

ntrace start
run 50us
quit



