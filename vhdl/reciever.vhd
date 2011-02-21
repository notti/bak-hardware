-----------------------------------------------------------
-- Project			: 
-- File				: reciever.vhd
-- Author			: Gernot Vormayr
-- created			: July, 3rd 2009
-- last mod. by		        : 
-- last mod. on		        : 
-- contents			: wrapper for gtx inputs
-----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.procedures.all;

entity reciever is
port(
-- signals for gtx transciever
	refclk              : in  std_logic;
	rst                 : in  std_logic;
	rxn                 : in  std_logic_vector(3 downto 0);
	rxp                 : in  std_logic_vector(3 downto 0);
	txn                 : out std_logic_vector(3 downto 0);
	txp                 : out std_logic_vector(3 downto 0);
    pll_locked          : out std_logic;

-- clk
	clk                 : out std_logic;
	rst_out             : out std_logic;
	data                : out t_data_array(2 downto 0);

-- settings
	polarity            : in std_logic_vector(2 downto 0);
	descramble          : in std_logic_vector(2 downto 0);
	rxeqmix             : in t_cfg_array(2 downto 0);
	data_valid          : out std_logic_vector(2 downto 0);
	enable              : in std_logic_vector(2 downto 0)
);
end reciever;

architecture Structural of reciever is
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
    TILE0_RXBYTEREALIGN0_OUT                : out  std_logic;
    TILE0_RXBYTEREALIGN1_OUT                : out  std_logic;
    TILE0_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE0_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE0_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE0_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
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
    TILE1_RXBYTEREALIGN0_OUT                : out  std_logic;
    TILE1_RXBYTEREALIGN1_OUT                : out  std_logic;
    TILE1_RXENMCOMMAALIGN0_IN               : in   std_logic;
    TILE1_RXENMCOMMAALIGN1_IN               : in   std_logic;
    TILE1_RXENPCOMMAALIGN0_IN               : in   std_logic;
    TILE1_RXENPCOMMAALIGN1_IN               : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    TILE1_RXDATA0_OUT                       : out  std_logic_vector(15 downto 0);
    TILE1_RXDATA1_OUT                       : out  std_logic_vector(15 downto 0);
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
    TILE1_TXP1_OUT                          : out  std_logic

	);
	end component;

-- clocks
	signal refclkout_i              : std_logic;
	signal usrclk_i                 : std_logic;

-- registers

	signal resetdone_r              : std_logic_vector(2 downto 0);
	signal resetdone_r2             : std_logic_vector(2 downto 0);
  
-- signals from gtx wizard
	----------------------- Receive Ports - 8b10b Decoder ----------------------
	signal  rxchariscomma_i         : t_cfg_array(2 downto 0);
	signal  rxdisperr_i             : t_cfg_array(2 downto 0);
	signal  rxnotintable_i          : t_cfg_array(2 downto 0);
	--------------- Receive Ports - Comma Detection and Alignment --------------
	signal  rxbyteisaligned_i       : std_logic_vector(2 downto 0);
	signal  rxencommaalign_i        : std_logic_vector(2 downto 0);
	------------------- Receive Ports - RX Data Path interface -----------------
	signal  rxdata_i                : t_data_array(2 downto 0);
	signal  rxdataR_i               : t_data_array(2 downto 0);
	signal  rxdataD_i               : t_data_array(2 downto 0);
	--------------------- Shared Ports - Tile and PLL Ports --------------------
	signal  resetdone_i             : std_logic_vector(2 downto 0);
	------------------ Transmit Ports - TX Data Path interface -----------------
	signal  txdata_i                : t_gtxdata_array(2 downto 0);
	----------------------------------------------------------------------------
	signal  datavalidaligned_i      : std_logic_vector(2 downto 0);
	signal  datavalidaligned_r      : std_logic_vector(2 downto 0);
	signal  datavalid_i             : std_logic_vector(2 downto 0);
	signal  rxunsynced_i            : std_logic_vector(2 downto 0);

begin
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
		TILE0_RXBYTEREALIGN0_OUT        =>      open,
		TILE0_RXBYTEREALIGN1_OUT        =>      open,
		TILE0_RXBYTEISALIGNED0_OUT      =>      rxbyteisaligned_i(0),
		TILE0_RXBYTEISALIGNED1_OUT      =>      rxbyteisaligned_i(1),
		TILE0_RXENMCOMMAALIGN0_IN       =>      rxencommaalign_i(0),
		TILE0_RXENMCOMMAALIGN1_IN       =>      rxencommaalign_i(1),
		TILE0_RXENPCOMMAALIGN0_IN       =>      rxencommaalign_i(0),
		TILE0_RXENPCOMMAALIGN1_IN       =>      rxencommaalign_i(1),
		------------------- Receive Ports - RX Data Path interface -----------------
		TILE0_RXDATA0_OUT               =>      rxdata_i(0),
		TILE0_RXDATA1_OUT               =>      rxdata_i(1),
		TILE0_RXUSRCLK0_IN              =>      usrclk_i,
		TILE0_RXUSRCLK1_IN              =>      usrclk_i,
		TILE0_RXUSRCLK20_IN             =>      usrclk_i,
		TILE0_RXUSRCLK21_IN             =>      usrclk_i,
		------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
		TILE0_RXEQMIX0_IN               =>      rxeqmix(0),
		TILE0_RXEQMIX1_IN               =>      rxeqmix(1),
		TILE0_RXN0_IN                   =>      rxn(0),
		TILE0_RXN1_IN                   =>      rxn(1),
		TILE0_RXP0_IN                   =>      rxp(0),
		TILE0_RXP1_IN                   =>      rxp(1),
		----------------- Receive Ports - RX Polarity Control Ports ----------------
		TILE0_RXPOLARITY0_IN            =>      polarity(0),
		TILE0_RXPOLARITY1_IN            =>      polarity(1),
		--------------------- Shared Ports - Tile and PLL Ports --------------------
		TILE0_CLKIN_IN                  =>      refclk,
		TILE0_GTXRESET_IN               =>      rst,
		TILE0_PLLLKDET_OUT              =>      pll_locked,
		TILE0_REFCLKOUT_OUT             =>      refclkout_i,
		TILE0_RESETDONE0_OUT            =>      resetdone_i(0),
		TILE0_RESETDONE1_OUT            =>      resetdone_i(1),
		------------------ Transmit Ports - TX Data Path interface -----------------
		TILE0_TXDATA0_IN                =>      txdata_i(0),
		TILE0_TXDATA1_IN                =>      txdata_i(1),
		TILE0_TXUSRCLK0_IN              =>      usrclk_i,
		TILE0_TXUSRCLK1_IN              =>      usrclk_i,
		TILE0_TXUSRCLK20_IN             =>      usrclk_i,
		TILE0_TXUSRCLK21_IN             =>      usrclk_i,
		--------------- Transmit Ports - TX Driver and OOB signalling --------------
		TILE0_TXN0_OUT                  =>      txn(0),
		TILE0_TXN1_OUT                  =>      txn(1),
		TILE0_TXP0_OUT                  =>      txp(0),
		TILE0_TXP1_OUT                  =>      txp(1),


		--_____________________________________________________________________
		--_____________________________________________________________________
		--TILE1  (X0Y5)

		----------------------- Receive Ports - 8b10b Decoder ----------------------
		TILE1_RXCHARISCOMMA0_OUT        =>      open,
		TILE1_RXCHARISCOMMA1_OUT        =>      rxchariscomma_i(2),
		TILE1_RXDISPERR0_OUT            =>      open,
		TILE1_RXDISPERR1_OUT            =>      rxdisperr_i(2),
		TILE1_RXNOTINTABLE0_OUT         =>      open,
		TILE1_RXNOTINTABLE1_OUT         =>      rxnotintable_i(2),
		--------------- Receive Ports - Comma Detection and Alignment --------------
		TILE1_RXBYTEREALIGN0_OUT        =>      open,
		TILE1_RXBYTEREALIGN1_OUT        =>      open,
		TILE1_RXBYTEISALIGNED0_OUT      =>      open,
		TILE1_RXBYTEISALIGNED1_OUT      =>      rxbyteisaligned_i(2),
		TILE1_RXENMCOMMAALIGN0_IN       =>      '0',
		TILE1_RXENMCOMMAALIGN1_IN       =>      rxencommaalign_i(2),
		TILE1_RXENPCOMMAALIGN0_IN       =>      '0',
		TILE1_RXENPCOMMAALIGN1_IN       =>      rxencommaalign_i(2),
		------------------- Receive Ports - RX Data Path interface -----------------
		TILE1_RXDATA0_OUT               =>      open,
		TILE1_RXDATA1_OUT               =>      rxdata_i(2),
		TILE1_RXUSRCLK0_IN              =>      usrclk_i,
		TILE1_RXUSRCLK1_IN              =>      usrclk_i,
		TILE1_RXUSRCLK20_IN             =>      usrclk_i,
		TILE1_RXUSRCLK21_IN             =>      usrclk_i,
		------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
		TILE1_RXEQMIX0_IN               =>      (others => '0'),
		TILE1_RXEQMIX1_IN               =>      rxeqmix(2),
		TILE1_RXN0_IN                   =>      rxn(2),
		TILE1_RXN1_IN                   =>      rxn(3),
		TILE1_RXP0_IN                   =>      rxp(2),
		TILE1_RXP1_IN                   =>      rxp(3),
		----------------- Receive Ports - RX Polarity Control Ports ----------------
		TILE1_RXPOLARITY0_IN            =>      '0',
		TILE1_RXPOLARITY1_IN            =>      polarity(2),
		--------------------- Shared Ports - Tile and PLL Ports --------------------
		TILE1_CLKIN_IN                  =>      refclk,
		TILE1_GTXRESET_IN               =>      rst,
		TILE1_PLLLKDET_OUT              =>      open,
		TILE1_REFCLKOUT_OUT             =>      open,
		TILE1_RESETDONE0_OUT            =>      open,
		TILE1_RESETDONE1_OUT            =>      resetdone_i(2),
		------------------ Transmit Ports - TX Data Path interface -----------------
		TILE1_TXDATA0_IN                =>      (others => '0'),
		TILE1_TXDATA1_IN                =>      txdata_i(2),
		TILE1_TXUSRCLK0_IN              =>      usrclk_i,
		TILE1_TXUSRCLK1_IN              =>      usrclk_i,
		TILE1_TXUSRCLK20_IN             =>      usrclk_i,
		TILE1_TXUSRCLK21_IN             =>      usrclk_i,
		--------------- Transmit Ports - TX Driver and OOB signalling --------------
		TILE1_TXN0_OUT                  =>      txn(2),
		TILE1_TXN1_OUT                  =>      txn(3),
		TILE1_TXP0_OUT                  =>      txp(2),
		TILE1_TXP1_OUT                  =>      txp(3)


	);

	refclkout_bufg0_i: BUFG
	port map(
		I   		    =>  refclkout_i,
		O   		    =>  usrclk_i
	);

	syncs: for i in 0 to 2 generate
		-- reset delay
		reset_delay_process: process(usrclk_i, resetdone_i(i))
		begin
			if resetdone_i(i) = '0' then
				resetdone_r(i)  <= '0';
				resetdone_r2(i) <= '0';
			elsif rising_edge(usrclk_i) then
				resetdone_r(i)  <= resetdone_i(i);
				resetdone_r2(i) <= resetdone_r(i);
			end if;
		end process;

		-- alignment fsm
		align: entity work.align_fsm
		port map(
			clk             => usrclk_i,
			rst             => not resetdone_r2(i),
			enable          => enable(i),
			aligned         => rxbyteisaligned_i(i),
			valid           => datavalid_i(i),
			align           => rxencommaalign_i(i),
			unsynced        => rxunsynced_i(i),
			tx              => txdata_i(i)
		);

		-- correct endianess of rxdata

		rxdataR_i(i)(15 downto 8)   <= rxdata_i(i)(7 downto 0);
		rxdataR_i(i)(7 downto 0)    <= rxdata_i(i)(15 downto 8);

		-- descrambler
		descrambler: entity work.descramble
		port map(
			clk              => usrclk_i,
			data_in          => rxdataR_i(i),
			data_out         => rxdataD_i(i)
		);

		-- data valid
		datavalid_i(i)  <= not or_many( (rxdisperr_i(i) & rxnotintable_i(i)) );
		datavalidaligned_i(i)  <= and_many( (datavalid_i(i) & not rxunsynced_i(i) & not rxchariscomma_i(0)));

		datavalidaligned_r_process: process(usrclk_i, resetdone_i(i))
		begin
			if resetdone_i(i) = '0' then
				datavalidaligned_r(i) <= '0';
			elsif rising_edge(usrclk_i) then
				datavalidaligned_r(i) <= datavalidaligned_i(i);
			end if;
		end process;

		-- wire troughs
		data(i)             <= rxdataD_i(i) when descramble(i) = '1' else rxdataR_i(i);
		data_valid(i)       <= datavalidaligned_r(i) and datavalidaligned_i(i);

	end generate syncs;

	clk     <= usrclk_i;
	rst_out <= not and_many(resetdone_i);

end Structural;

