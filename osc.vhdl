library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity osc is
    generic(
        -- Divide the clock frequency by 2^(max_digit+1)
        max_digit : integer
    );
    port(
        clk_in : in std_logic;
        clk_out : out std_logic
    );
end osc;

architecture synth of osc is
    signal counter : unsigned(max_digit downto 0);
begin
    process(clk_in) begin
        if rising_edge(clk_in) then
            counter <= counter + 1;
        end if;
    end process;

    clk_out <= counter(max_digit);
end;
