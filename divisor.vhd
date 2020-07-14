----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:49:11 11/22/2019 
-- Design Name: 
-- Module Name:    compDivisor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisor is
    Port ( character_in : in  STD_LOGIC_VECTOR (7 downto 0);
           ws : in  STD_LOGIC;
           inPortid : in  STD_LOGIC_VECTOR (7 downto 0);
           reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  div_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  finOp : out std_logic);
end divisor;

architecture Behavioral of divisor is

type type_state is (INICIO, RESTA, RESTOMENOR, RESTOMAYOR, DESPLAZAR_INCCNT, FIN);	-- Se ha cambiado la FSM
	signal state, nextstate : type_state;
	signal RESTO, DIVISOR: std_logic_vector(15 downto 0);
	signal COCIENTE : std_logic_vector(7 downto 0);
	signal cnt : unsigned (3 downto 0);
	signal init, incCNT, subu_REST_DIV, addu_REST_DIV, srl_DIV, sl_COC0, sl_COC1  : std_logic; -- Se han cambiado las señales de control
	signal subu_resta_DIV, addu_resta_DIV : std_logic_vector(15 downto 0);


begin

	-- registro cnt
	process(reset,clk)
	begin
		if(reset = '1')then
			cnt <= (others => '0');
		elsif(rising_edge(clk))then
			if(init = '1')then
				cnt <= (others => '0');
			elsif(incCNT = '1') then
				cnt <= cnt + 1;				-- Ahora Contador ascendente
			end if;
		end if;
	end process;

	-- registro RESTO
	process(reset,clk)
	begin
		if(reset = '1')then
			RESTO <= (others => '0');
		elsif(rising_edge(clk)) then
			if(init = '1')then
				RESTO <= x"00" & character_in;
			elsif(subu_REST_DIV = '1') then
				RESTO <= subu_resta_DIV;
			elsif(addu_REST_DIV = '1') then
				RESTO <= addu_resta_DIV;
			end if;
		end if;
	end process;
	
	-- registro DIVISOR
	process(reset,clk)
	begin
		if(reset = '1')then
			DIVISOR <= (others => '0');
		elsif(rising_edge(clk)) then
			if(init = '1')then
			--	DIVISOR <= x"0200"; -- dividimos entre 2
				DIVISOR <= x"0F00"; -- dividimos entre 15
			--	DIVISOR <= x"0800"; -- dividimos entre 8
			elsif(srl_DIV = '1') then
				DIVISOR <= '0' & DIVISOR(15 downto 1);
			end if;
		end if;
	end process;
	
	
	-- registro COCIENTE
	process(reset,clk)
	begin
		if(reset = '1')then
			COCIENTE <= (others => '0');
		elsif(rising_edge(clk)) then
			if(init = '1')then
				COCIENTE <= (others => '0');
			elsif(sl_COC0 = '1') then
				COCIENTE <= COCIENTE(6 DOWNTO 0) & '0'; 
			elsif(sl_COC1 = '1') then
				COCIENTE <= COCIENTE(6 DOWNTO 0) & '1';
			end if;
		end if;
	end process;
	
	-- restador
	subu_resta_DIV <= std_logic_vector(unsigned(RESTO) - unsigned(DIVISOR));
	-- sumador
	addu_resta_DIV <= std_logic_vector(unsigned(RESTO) + unsigned(DIVISOR));
	
	-- salida
   div_out <= COCIENTE;
	--rest <= RESTO(7 downto 0);

	
	-- unidad de control
	process(reset,clk)
	begin
		if(reset = '1') then
			state <= INICIO;
		elsif rising_edge(clk) then
			state <= nextstate;
		end if;
	end process;
	
	-- maquina de estado
	process(state, ws, cnt, subu_resta_DIV)
	begin
	
		init <= '0'; incCNT <= '0'; subu_REST_DIV<= '0'; addu_REST_DIV<= '0';
		srl_DIV<= '0'; sl_COC0 <= '0'; sl_COC1 <= '0'; finOP <= '0';
		case state is
		when INICIO =>
			if(ws='1' and inPortid=x"43")then
				init <= '1'; 
				nextstate <= RESTA;
			else
				nextstate <= INICIO;
			end if;
			
		when RESTA =>
			subu_REST_DIV <= '1';
			if(subu_resta_DIV(15)='1')then
				nextstate <= RESTOMENOR;
			else
				nextstate <= RESTOMAYOR;
			end if;
			
		when RESTOMENOR =>
			addu_REST_DIV <= '1';
			sl_COC0 <= '1';
			nextstate <= DESPLAZAR_INCCNT; 
			
		when RESTOMAYOR =>
			sl_COC1 <= '1';
			nextstate <= DESPLAZAR_INCCNT;
			
		when DESPLAZAR_INCCNT =>
			srl_DIV <= '1';
			incCNT <= '1';
			if(cnt=x"8")then
				nextstate <= FIN;
			else
				nextstate <= RESTA;
			end if;
			
		when FIN =>
			nextstate <= INICIO;
			finOP <= '1';
		end case;
	end process;
	
end Behavioral;

