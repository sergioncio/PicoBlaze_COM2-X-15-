library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity complemento is
    Port (operand : in std_logic_vector(7 downto 0);	-- Entrada
          Y : out std_logic_vector(7 downto 0);			-- Salida
          clk : in std_logic);
end complemento;
--
architecture low_level_definition of complemento is

signal aux: std_logic_vector(7 downto 0) := "00000000";
signal salida: std_logic_vector(7 downto 0) := "00000000";
begin
	bus_width_loop: for i in 0 to 1 generate
	
	FF:
		process (clk)
			begin
				if i = 0 then
					if (clk'event and clk = '1') then
						aux <= (not operand);
					end if;
				end if;
		end process FF;
	
	FE:
		process (clk)
			begin
				if i = 1 then
					if (clk'event and clk = '1') then
						salida <= aux + ("00000001");
					end if;
				end if;
		end process FE;
	Y <= salida;
	end generate bus_width_loop;
end low_level_definition;
