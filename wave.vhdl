library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity oscillator is
    port(
        clk : in std_logic;
        rate : in signed(15 downto 0);
        wave_type : in unsigned(1 downto 0);
        oscout : out signed(15 downto 0) := to_signed(0, 16)
    );
end oscillator;

architecture synth of oscillator is
    signal phase : signed(15 downto 0) := to_signed(0, 16);
begin
    process (clk) begin
        if rising_edge(clk) then
            phase <= phase + rate;

            if wave_type = 2d"0" then
                oscout <= phase; -- saw wave
            elsif wave_type = 2d"1" then
                oscout <= 16b"1111111111111111" when phase(15) else 16b"0000000000000000";
            elsif wave_type = 2d"2" then
                oscout <= (phase sll 1) when phase(15) = '0' else (16b"1111111111111111" - phase) sll 1;
            end if;
        end if;
    end process;

end synth ; -- synth
