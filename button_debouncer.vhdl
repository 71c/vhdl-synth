library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity button_debouncer is
  port(
	clk : in std_logic;
    button_in : in std_logic; -- this is the glitchy, original button signal
    button_out : out std_logic;   -- corrected button, 1 when button is active (down)
    pushed_down : out std_logic; -- 1 for one clock cycle when the push-button goes down (i.e. just pushed)
    pushed_up : out std_logic -- 1 for one clock cycle when the push-button goes up (i.e. just released)
  );
end button_debouncer;

architecture synth of button_debouncer is
    -- Actually works without this synchronization, but I'm keeping this because
    -- that is what is done in the original code.
    signal button_in_sync : std_logic;
    signal button_in_sync_prev : std_logic;

    signal count : unsigned(15 downto 0);
    signal button_not_idle : std_logic;
    signal count_is_maxed : std_logic;
begin
    process(clk) begin
        if rising_edge(clk) then
            button_in_sync <= button_in;
            button_in_sync_prev <= button_in_sync;
            
            if button_not_idle then
                count <= count + '1';
                if count_is_maxed then
                    button_out <= not button_out;
                end if;
            else
                count <= 16b"0";
            end if;

        end if;
    end process;

    button_not_idle <= button_out xor button_in_sync_prev;
    count_is_maxed <= and count;

    pushed_down <= button_not_idle and count_is_maxed and not button_out;
    pushed_up <= button_not_idle and count_is_maxed and button_out;

end;
