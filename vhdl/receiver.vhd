-----------------------------------------------------------
-- wrapper for gtx inputs
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity receiver is
port(
-- signals for gtx transciever
	refclk_n            : in  std_logic;
	refclk_p			: in  std_logic;
	rst                 : in  std_logic;
	rxn                 : in  std_logic_vector(5 downto 0);
	rxp                 : in  std_logic_vector(5 downto 0);
	txn                 : out std_logic_vector(5 downto 0);
	txp                 : out std_logic_vector(5 downto 0);

-- clk
	rxclk               : out std_logic_vector(1 downto 0);
    rst_out             : out std_logic_vector(1 downto 0);
	data                : out t_data_array(1 downto 0);
	cdr_valid           : out std_logic_vector(1 downto 0);

-- settings
	polarity            : in std_logic_vector(1 downto 0);
	descramble          : in std_logic_vector(1 downto 0);
	rxeqmix             : in t_cfg_array(1 downto 0);
	enable              : in std_logic_vector(1 downto 0)
);
end receiver;

architecture Structural of receiver is
	type t_gtxdata_array is array(integer range <>) of std_logic_vector(19 downto 0);

	component GTX 
	port
	(
    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE0  (Location)

    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE0_RXCHARISCOMMA0_OUT                : out  std_logic_vector(1 downto 0);
    TILE0_RXCHARISCOMMA1_OUT                : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXDISPERR1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE0_OUT                 : out  std_logic_vector(1 downto 0);
    TILE0_RXNOTINTABLE1_OUT                 : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE0_RXBYTEISALIGNED0_OUT              : out  std_logic;
    TILE0_RXBYTEISALIGNED1_OUT              : out  std_logic;
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXRECCLK0_OUT                     : out  std_logic;
    TILE0_RXRECCLK1_OUT                     : out  std_logic;
    TILE0_RXUSRCLK0_IN                      : in   std_logic;
    TILE0_RXUSRCLK1_IN                      : in   std_logic;
    TILE0_RXUSRCLK20_IN                     : in   std_logic;
    TILE0_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE0_RXEQMIX0_IN                       : in   std_logic_vector(1 downto 0);
    TILE0_RXEQMIX1_IN                       : in   std_logic_vector(1 downto 0);
    TILE0_RXN0_IN                           : in   std_logic;
    TILE0_RXN1_IN                           : in   std_logic;
    TILE0_RXP0_IN                           : in   std_logic;
    TILE0_RXP1_IN                           : in   std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    TILE0_RXPOLARITY0_IN                    : in   std_logic;
    TILE0_RXPOLARITY1_IN                    : in   std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    TILE0_CLKIN_IN                          : in   std_logic;
    TILE0_GTXRESET_IN                       : in   std_logic;
    TILE0_PLLLKDET_OUT                      : out  std_logic;
    TILE0_REFCLKOUT_OUT                     : out  std_logic;
    TILE0_RESETDONE0_OUT                    : out  std_logic;
    TILE0_RESETDONE1_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE0_TXDATA0_IN                        : in   std_logic_vector(19 downto 0);
    TILE0_TXDATA1_IN                        : in   std_logic_vector(19 downto 0);
    TILE0_TXUSRCLK0_IN                      : in   std_logic;
    TILE0_TXUSRCLK1_IN                      : in   std_logic;
    TILE0_TXUSRCLK20_IN                     : in   std_logic;
    TILE0_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE0_TXN0_OUT                          : out  std_logic;
    TILE0_TXN1_OUT                          : out  std_logic;
    TILE0_TXP0_OUT                          : out  std_logic;
    TILE0_TXP1_OUT                          : out  std_logic;


    
    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE1  (Location)

    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE1_RXCHARISCOMMA0_OUT                : out  std_logic_vector(1 downto 0);
    TILE1_RXCHARISCOMMA1_OUT                : out  std_logic_vector(1 downto 0);
    TILE1_RXDISPERR0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE1_RXDISPERR1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE1_RXNOTINTABLE0_OUT                 : out  std_logic_vector(1 downto 0);
    TILE1_RXNOTINTABLE1_OUT                 : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE1_RXBYTEISALIGNED0_OUT              : out  std_logic;
    TILE1_RXBYTEISALIGNED1_OUT              : out  std_logic;
    TILE1_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE1_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE1_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE1_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE1_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE1_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
    TILE1_RXRECCLK0_OUT                     : out  std_logic;
    TILE1_RXRECCLK1_OUT                     : out  std_logic;
    TILE1_RXUSRCLK0_IN                      : in   std_logic;
    TILE1_RXUSRCLK1_IN                      : in   std_logic;
    TILE1_RXUSRCLK20_IN                     : in   std_logic;
    TILE1_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE1_RXEQMIX0_IN                       : in   std_logic_vector(1 downto 0);
    TILE1_RXEQMIX1_IN                       : in   std_logic_vector(1 downto 0);
    TILE1_RXN0_IN                           : in   std_logic;
    TILE1_RXN1_IN                           : in   std_logic;
    TILE1_RXP0_IN                           : in   std_logic;
    TILE1_RXP1_IN                           : in   std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    TILE1_RXPOLARITY0_IN                    : in   std_logic;
    TILE1_RXPOLARITY1_IN                    : in   std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    TILE1_CLKIN_IN                          : in   std_logic;
    TILE1_GTXRESET_IN                       : in   std_logic;
    TILE1_PLLLKDET_OUT                      : out  std_logic;
    TILE1_REFCLKOUT_OUT                     : out  std_logic;
    TILE1_RESETDONE0_OUT                    : out  std_logic;
    TILE1_RESETDONE1_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE1_TXDATA0_IN                        : in   std_logic_vector(19 downto 0);
    TILE1_TXDATA1_IN                        : in   std_logic_vector(19 downto 0);
    TILE1_TXUSRCLK0_IN                      : in   std_logic;
    TILE1_TXUSRCLK1_IN                      : in   std_logic;
    TILE1_TXUSRCLK20_IN                     : in   std_logic;
    TILE1_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE1_TXN0_OUT                          : out  std_logic;
    TILE1_TXN1_OUT                          : out  std_logic;
    TILE1_TXP0_OUT                          : out  std_logic;
    TILE1_TXP1_OUT                          : out  std_logic;


    
    --_________________________________________________________________________
    --_________________________________________________________________________
    --TILE2  (Location)

    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    TILE2_RXCHARISCOMMA0_OUT                : out  std_logic_vector(1 downto 0);
    TILE2_RXCHARISCOMMA1_OUT                : out  std_logic_vector(1 downto 0);
    TILE2_RXDISPERR0_OUT                    : out  std_logic_vector(1 downto 0);
    TILE2_RXDISPERR1_OUT                    : out  std_logic_vector(1 downto 0);
    TILE2_RXNOTINTABLE0_OUT                 : out  std_logic_vector(1 downto 0);
    TILE2_RXNOTINTABLE1_OUT                 : out  std_logic_vector(1 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    TILE2_RXBYTEISALIGNED0_OUT              : out  std_logic;
    TILE2_RXBYTEISALIGNED1_OUT              : out  std_logic;
    TILE2_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE2_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE2_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE2_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE2_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE2_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
    TILE2_RXRECCLK0_OUT                     : out  std_logic;
    TILE2_RXRECCLK1_OUT                     : out  std_logic;
    TILE2_RXUSRCLK0_IN                      : in   std_logic;
    TILE2_RXUSRCLK1_IN                      : in   std_logic;
    TILE2_RXUSRCLK20_IN                     : in   std_logic;
    TILE2_RXUSRCLK21_IN                     : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    TILE2_RXEQMIX0_IN                       : in   std_logic_vector(1 downto 0);
    TILE2_RXEQMIX1_IN                       : in   std_logic_vector(1 downto 0);
    TILE2_RXN0_IN                           : in   std_logic;
    TILE2_RXN1_IN                           : in   std_logic;
    TILE2_RXP0_IN                           : in   std_logic;
    TILE2_RXP1_IN                           : in   std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    TILE2_RXPOLARITY0_IN                    : in   std_logic;
    TILE2_RXPOLARITY1_IN                    : in   std_logic;
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    TILE2_CLKIN_IN                          : in   std_logic;
    TILE2_GTXRESET_IN                       : in   std_logic;
    TILE2_PLLLKDET_OUT                      : out  std_logic;
    TILE2_REFCLKOUT_OUT                     : out  std_logic;
    TILE2_RESETDONE0_OUT                    : out  std_logic;
    TILE2_RESETDONE1_OUT                    : out  std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TILE2_TXDATA0_IN                        : in   std_logic_vector(19 downto 0);
    TILE2_TXDATA1_IN                        : in   std_logic_vector(19 downto 0);
    TILE2_TXUSRCLK0_IN                      : in   std_logic;
    TILE2_TXUSRCLK1_IN                      : in   std_logic;
    TILE2_TXUSRCLK20_IN                     : in   std_logic;
    TILE2_TXUSRCLK21_IN                     : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TILE2_TXN0_OUT                          : out  std_logic;
    TILE2_TXN1_OUT                          : out  std_logic;
    TILE2_TXP0_OUT                          : out  std_logic;
    TILE2_TXP1_OUT                          : out  std_logic
	);
	end component;

-- clocks
	signal refclkout_i              : std_logic;
	signal txclk_i                 : std_logic;
	signal refclk					: std_logic;

    signal rxrecclk_i               : std_logic_vector(1 downto 0);
    signal rxrecclk_unbuf           : std_logic_vector(1 downto 0);

-- registers

	signal resetdone_r              : std_logic_vector(1 downto 0);
	signal resetdone_r2             : std_logic_vector(1 downto 0);
  
-- signals from gtx wizard
	----------------------- Receive Ports - 8b10b Decoder ----------------------
	signal  rxchariscomma_i         : t_cfg_array(1 downto 0);
	signal  rxdisperr_i             : t_cfg_array(1 downto 0);
	signal  rxnotintable_i          : t_cfg_array(1 downto 0);
	--------------- Receive Ports - Comma Detection and Alignment --------------
	signal  rxbyteisaligned_i       : std_logic_vector(1 downto 0);
	signal  rxencommaalign_i        : std_logic_vector(1 downto 0);
	------------------- Receive Ports - RX Data Path interface -----------------
	signal  rxdata_i                : t_data_array(1 downto 0);
	signal  rxdataR_i               : t_data_array(1 downto 0);
	signal  rxdataD_i               : t_data_array(1 downto 0);
	--------------------- Shared Ports - Tile and PLL Ports --------------------
	signal  resetdone_i             : std_logic_vector(1 downto 0);
	------------------ Transmit Ports - TX Data Path interface -----------------
	signal  txdata_i                : t_gtxdata_array(1 downto 0);
	----------------------------------------------------------------------------
	signal  datavalidaligned_i      : std_logic_vector(1 downto 0);
	signal  datavalidaligned_r      : std_logic_vector(1 downto 0);
	signal  datavalid_i             : std_logic_vector(1 downto 0);
	signal  rxunsynced_i            : std_logic_vector(1 downto 0);
    signal  polarity_synced         : std_logic_vector(1 downto 0);

begin
    inbuf_refclkbufds_i : IBUFDS
    port map
    (
        O                   => refclk,
        I                   => refclk_p,
        IB                  => refclk_n
    );


    -- TILE0 (X0Y3) has our data inputs, but we need TILE1+2, because
    -- TILE2 has the connected clock input
	gtx_i : GTX
	port map
	(
		--_____________________________________________________________________
		--_____________________________________________________________________
		--TILE0  (X0Y3)

		----------------------- Receive Ports - 8b10b Decoder ----------------------
		TILE0_RXCHARISCOMMA0_OUT        =>      rxchariscomma_i(0),
		TILE0_RXCHARISCOMMA1_OUT        =>      rxchariscomma_i(1),
		TILE0_RXDISPERR0_OUT            =>      rxdisperr_i(0),
		TILE0_RXDISPERR1_OUT            =>      rxdisperr_i(1),
		TILE0_RXNOTINTABLE0_OUT         =>      rxnotintable_i(0),
		TILE0_RXNOTINTABLE1_OUT         =>      rxnotintable_i(1),
		--------------- Receive Ports - Comma Detection and Alignment --------------
		TILE0_RXBYTEISALIGNED0_OUT      =>      rxbyteisaligned_i(0),
		TILE0_RXBYTEISALIGNED1_OUT      =>      rxbyteisaligned_i(1),
		TILE0_RXENMCOMMAALIGN0_IN       =>      rxencommaalign_i(0),
		TILE0_RXENMCOMMAALIGN1_IN       =>      rxencommaalign_i(1),
		TILE0_RXENPCOMMAALIGN0_IN       =>      rxencommaalign_i(0),
		TILE0_RXENPCOMMAALIGN1_IN       =>      rxencommaalign_i(1),
		------------------- Receive Ports - RX Data Path interface -----------------
		TILE0_RXDATA0_OUT               =>      rxdata_i(0),
		TILE0_RXDATA1_OUT               =>      rxdata_i(1),
        TILE0_RXRECCLK0_OUT             =>      rxrecclk_unbuf(0),
        TILE0_RXRECCLK1_OUT             =>      rxrecclk_unbuf(1),
		TILE0_RXUSRCLK0_IN              =>      rxrecclk_i(0),
		TILE0_RXUSRCLK1_IN              =>      rxrecclk_i(1),
		TILE0_RXUSRCLK20_IN             =>      rxrecclk_i(0),
		TILE0_RXUSRCLK21_IN             =>      rxrecclk_i(1),
		------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
		TILE0_RXEQMIX0_IN               =>      rxeqmix(0),
		TILE0_RXEQMIX1_IN               =>      rxeqmix(1),
		TILE0_RXN0_IN                   =>      rxn(0),
		TILE0_RXN1_IN                   =>      rxn(1),
		TILE0_RXP0_IN                   =>      rxp(0),
		TILE0_RXP1_IN                   =>      rxp(1),
		----------------- Receive Ports - RX Polarity Control Ports ----------------
		TILE0_RXPOLARITY0_IN            =>      polarity_synced(0),
		TILE0_RXPOLARITY1_IN            =>      polarity_synced(1),
		--------------------- Shared Ports - Tile and PLL Ports --------------------
		TILE0_CLKIN_IN                  =>      refclk,
		TILE0_GTXRESET_IN               =>      rst,
		TILE0_PLLLKDET_OUT              =>      open,
		TILE0_REFCLKOUT_OUT             =>      refclkout_i,
		TILE0_RESETDONE0_OUT            =>      resetdone_i(0),
		TILE0_RESETDONE1_OUT            =>      resetdone_i(1),
		------------------ Transmit Ports - TX Data Path interface -----------------
		TILE0_TXDATA0_IN                =>      txdata_i(0),
		TILE0_TXDATA1_IN                =>      txdata_i(1),
		TILE0_TXUSRCLK0_IN              =>      txclk_i,
		TILE0_TXUSRCLK1_IN              =>      txclk_i,
		TILE0_TXUSRCLK20_IN             =>      txclk_i,
		TILE0_TXUSRCLK21_IN             =>      txclk_i,
		--------------- Transmit Ports - TX Driver and OOB signalling --------------
		TILE0_TXN0_OUT                  =>      txn(0),
		TILE0_TXN1_OUT                  =>      txn(1),
		TILE0_TXP0_OUT                  =>      txp(0),
		TILE0_TXP1_OUT                  =>      txp(1),


        --_____________________________________________________________________
        --_____________________________________________________________________
        --TILE1  (X0Y4)

        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE1_RXCHARISCOMMA0_OUT        =>      open,
        TILE1_RXCHARISCOMMA1_OUT        =>      open,
        TILE1_RXDISPERR0_OUT            =>      open,
        TILE1_RXDISPERR1_OUT            =>      open,
        TILE1_RXNOTINTABLE0_OUT         =>      open,
        TILE1_RXNOTINTABLE1_OUT         =>      open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        TILE1_RXBYTEISALIGNED0_OUT      =>      open,
        TILE1_RXBYTEISALIGNED1_OUT      =>      open,
        TILE1_RXENMCOMMAALIGN0_IN       =>      '0',
        TILE1_RXENMCOMMAALIGN1_IN       =>      '0',
        TILE1_RXENPCOMMAALIGN0_IN       =>      '0',
        TILE1_RXENPCOMMAALIGN1_IN       =>      '0',
        ------------------- Receive Ports - RX Data Path interface -----------------
        TILE1_RXDATA0_OUT               =>      open,
        TILE1_RXDATA1_OUT               =>      open,
        TILE1_RXRECCLK0_OUT             =>      open,
        TILE1_RXRECCLK1_OUT             =>      open,
        TILE1_RXUSRCLK0_IN              =>      '0',
        TILE1_RXUSRCLK1_IN              =>      '0',
        TILE1_RXUSRCLK20_IN             =>      '0',
        TILE1_RXUSRCLK21_IN             =>      '0',
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE1_RXEQMIX0_IN               =>      "00",
        TILE1_RXEQMIX1_IN               =>      "00",
        TILE1_RXN0_IN                   =>      RXN(2),
        TILE1_RXN1_IN                   =>      RXN(3),
        TILE1_RXP0_IN                   =>      RXP(2),
        TILE1_RXP1_IN                   =>      RXP(3),
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        TILE1_RXPOLARITY0_IN            =>      '0',
        TILE1_RXPOLARITY1_IN            =>      '0',
        --------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE1_CLKIN_IN                  =>      refclk,
        TILE1_GTXRESET_IN               =>      '0',
        TILE1_PLLLKDET_OUT              =>      open,
        TILE1_REFCLKOUT_OUT             =>      open,
        TILE1_RESETDONE0_OUT            =>      open,
        TILE1_RESETDONE1_OUT            =>      open,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TILE1_TXDATA0_IN                =>      (others => '0'),
        TILE1_TXDATA1_IN                =>      (others => '0'),
        TILE1_TXUSRCLK0_IN              =>      '0',
        TILE1_TXUSRCLK1_IN              =>      '0',
        TILE1_TXUSRCLK20_IN             =>      '0',
        TILE1_TXUSRCLK21_IN             =>      '0',
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE1_TXN0_OUT                  =>      TXN(2),
        TILE1_TXN1_OUT                  =>      TXN(3),
        TILE1_TXP0_OUT                  =>      TXP(2),
        TILE1_TXP1_OUT                  =>      TXP(3),

		--_____________________________________________________________________
		--_____________________________________________________________________
		--TILE1  (X0Y5)


		----------------------- Receive Ports - 8b10b Decoder ----------------------
		TILE2_RXCHARISCOMMA0_OUT        =>      open,
		TILE2_RXCHARISCOMMA1_OUT        =>      open,
		TILE2_RXDISPERR0_OUT            =>      open,
		TILE2_RXDISPERR1_OUT            =>      open,
		TILE2_RXNOTINTABLE0_OUT         =>      open,
		TILE2_RXNOTINTABLE1_OUT         =>      open,
		--------------- Receive Ports - Comma Detection and Alignment --------------
		TILE2_RXBYTEISALIGNED0_OUT      =>      open,
		TILE2_RXBYTEISALIGNED1_OUT      =>      open,
		TILE2_RXENMCOMMAALIGN0_IN       =>      '0',
		TILE2_RXENMCOMMAALIGN1_IN       =>      '0',
		TILE2_RXENPCOMMAALIGN0_IN       =>      '0',
		TILE2_RXENPCOMMAALIGN1_IN       =>      '0',
		------------------- Receive Ports - RX Data Path interface -----------------
		TILE2_RXDATA0_OUT               =>      open,
		TILE2_RXDATA1_OUT               =>      open,
        TILE2_RXRECCLK0_OUT             =>      open,
        TILE2_RXRECCLK1_OUT             =>      open,
		TILE2_RXUSRCLK0_IN              =>      '0',
		TILE2_RXUSRCLK1_IN              =>      '0',
		TILE2_RXUSRCLK20_IN             =>      '0',
		TILE2_RXUSRCLK21_IN             =>      '0',
		------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
		TILE2_RXEQMIX0_IN               =>      (others => '0'),
		TILE2_RXEQMIX1_IN               =>      (others => '0'),
		TILE2_RXN0_IN                   =>      rxn(4),
		TILE2_RXN1_IN                   =>      rxn(5),
		TILE2_RXP0_IN                   =>      rxp(4),
		TILE2_RXP1_IN                   =>      rxp(5),
		----------------- Receive Ports - RX Polarity Control Ports ----------------
		TILE2_RXPOLARITY0_IN            =>      '0',
		TILE2_RXPOLARITY1_IN            =>      '0',
		--------------------- Shared Ports - Tile and PLL Ports --------------------
		TILE2_CLKIN_IN                  =>      refclk,
		TILE2_GTXRESET_IN               =>      '0',
		TILE2_PLLLKDET_OUT              =>      open,
		TILE2_REFCLKOUT_OUT             =>      open,
		TILE2_RESETDONE0_OUT            =>      open,
		TILE2_RESETDONE1_OUT            =>      open,
		------------------ Transmit Ports - TX Data Path interface -----------------
		TILE2_TXDATA0_IN                =>      (others => '0'),
		TILE2_TXDATA1_IN                =>      (others => '0'),
		TILE2_TXUSRCLK0_IN              =>      '0',
		TILE2_TXUSRCLK1_IN              =>      '0',
		TILE2_TXUSRCLK20_IN             =>      '0',
		TILE2_TXUSRCLK21_IN             =>      '0',
		--------------- Transmit Ports - TX Driver and OOB signalling --------------
		TILE2_TXN0_OUT                  =>      txn(4),
		TILE2_TXN1_OUT                  =>      txn(5),
		TILE2_TXP0_OUT                  =>      txp(4),
		TILE2_TXP1_OUT                  =>      txp(5)
	);

	refclkout_bufg0_i: BUFG
	port map(
		I   		    =>  refclkout_i,
		O   		    =>  txclk_i
	);

	syncs: for i in 0 to 1 generate
        signal tx:        std_logic;
        signal tx_synced: std_logic;
        signal descramble_synced: std_logic;
        signal enable_synced: std_logic;
    begin
        rxclk_bufg_i: BUFG
        port map(
            I          => rxrecclk_unbuf(i),
            O          => rxrecclk_i(i)
        );

        -- rec_enable
    
        rec_enable_i: entity work.flag
        port map(
            flag_in     => enable(i),
            flag_out    => enable_synced,
            clk         => rxrecclk_i(i)
        );
        rec_polarity_i: entity work.flag
        port map(
            flag_in     => polarity(i),
            flag_out    => polarity_synced(i),
            clk         => rxrecclk_i(i)
        );
        rec_descramble_i: entity work.flag
        port map(
            flag_in     => descramble(i),
            flag_out    => descramble_synced,
            clk         => rxrecclk_i(i)
        );


		-- reset delay + synchronizing
		reset_delay_process: process(rxrecclk_i(i), resetdone_i(i))
		begin
            if resetdone_i(i) = '0' then
                resetdone_r(i)  <= '0';
                resetdone_r2(i) <= '0';
			elsif rising_edge(rxrecclk_i(i)) then
                resetdone_r(i)  <= '1';
                resetdone_r2(i) <= resetdone_r(i);
			end if;
		end process;

		-- alignment fsm
		align: entity work.align_fsm
		port map(
			clk             => rxrecclk_i(i),
			rst             => not resetdone_r2(i),
			enable          => enable_synced,
			aligned         => rxbyteisaligned_i(i),
			valid           => datavalid_i(i),
			align           => rxencommaalign_i(i),
			unsynced        => rxunsynced_i(i),
			tx              => tx
		);

        flag: entity work.flag
        port map(
            flag_in     => tx,
            flag_out    => tx_synced,
            clk         => txclk_i
        );

        -- clock to adc; get's blanked for synch request
        txdata_i(i) <= "11111111110000000000" when tx_synced = '1' else
                       (others => '0');

		-- correct endianess of rxdata

		rxdataR_i(i)(15 downto 8)   <= rxdata_i(i)(7 downto 0);
		rxdataR_i(i)(7 downto 0)    <= rxdata_i(i)(15 downto 8);

		-- descrambler
		descrambler: entity work.descramble
		port map(
			clk              => rxrecclk_i(i),
			data_in          => rxdataR_i(i),
			data_out         => rxdataD_i(i)
		);

		-- data valid
		datavalid_i(i)  <= not or_many( (rxdisperr_i(i) & rxnotintable_i(i)) );
		datavalidaligned_i(i)  <= and_many( (datavalid_i(i) & not rxunsynced_i(i) & not rxchariscomma_i(i)));

		datavalidaligned_r_process: process(rxrecclk_i(i))
		begin
			if rising_edge(rxrecclk_i(i)) then
                if resetdone_r2(i) = '0' then
                    datavalidaligned_r(i) <= '0';
                else
                    datavalidaligned_r(i) <= datavalidaligned_i(i);
                end if;
			end if;
		end process;

		-- wire troughs
		data(i)             <= rxdataD_i(i) when descramble_synced = '1' else rxdataR_i(i);
		cdr_valid(i)        <= datavalidaligned_r(i) and datavalidaligned_i(i);

        rst_out(i) <= not resetdone_r2(i);
        -- rxclk is only valid when cdr_valid(i) == '1'
        rxclk(i) <= rxrecclk_i(i);
	end generate syncs;

end Structural;

