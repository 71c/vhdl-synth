library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mix is
    port(
        -- output_wave : out signed(15 downto 0) := to_signed(0, 16)
        test_out : out signed(5 downto 0);

        buttons_on : in std_logic_vector(0 to 7);

        wave_switch_button : in std_logic := '0'
    );
end mix;

architecture synth of mix is

    type MIDI_NOTE_ARRAY is array (0 to 7) of unsigned(6 downto 0);

    component oscillator is
        port(
            clk : in std_logic;
            rate : in signed(15 downto 0);
            wave_type : in unsigned(1 downto 0);
            oscout : out signed(15 downto 0) := to_signed(0, 16)
        );
    end component;

    component SB_HFOSC is
        generic(
            CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2^N (0-3)
        port(
            CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
            CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
            CLKHF : out std_logic := 'X'   -- Clock output
        );
    end component;

    component osc is
        generic(
            max_digit : integer
        );
        port(
            clk_in : in std_logic;
            clk_out : out std_logic
        );
    end component;

    component note2freq is
        port(
            midi_note : in unsigned(6 downto 0);
            rate : out signed(15 downto 0) -- basically frequency
        );
    end component;

    component button_debouncer is
        port(
          clk : in std_logic;
          button_in : in std_logic; -- this is the glitchy, original button signal
          button_out : out std_logic;   -- corrected button, 1 when button is active (down)
          pushed_down : out std_logic; -- 1 for one clock cycle when the push-button goes down (i.e. just pushed)
          pushed_up : out std_logic -- 1 for one clock cycle when the push-button goes up (i.e. just released)
        );
    end component;
    
    signal osc1_midi_note : unsigned(6 downto 0) := 7d"69"; -- A4, MIDI note 69
    signal osc1_rate : signed(15 downto 0);

    signal base_clk : std_logic := '0';
    signal clk : std_logic := '0';

    signal output_wave : signed(15 downto 0);

    -- signal button_freqs : MIDI_NOTE_ARRAY := (7d"69", 7d"70", 7d"71", 7d"72", 7d"73", 7d"74", 7d"75", 7d"76");
    -- signal button_freqs : MIDI_NOTE_ARRAY := (7d"36", 7d"40", 7d"43", 7d"48", 7d"52", 7d"55", 7d"60", 7d"64");
    signal button_freqs : MIDI_NOTE_ARRAY := (7d"60", 7d"62", 7d"64", 7d"65", 7d"67", 7d"69", 7d"71", 7d"72"); -- C major scale

    signal osc1_wave_type : unsigned(1 downto 0) := 2b"00";

    signal wave_switch_button_pushed_down : std_logic;
begin

    -- SETUP

    -- This is be base oscillator that we will have osc use
    base_osc : SB_HFOSC generic map (
        CLKHF_DIV => "0b00"
    )
    port map (
        CLKHFPU => '1',
        CLKHFEN => '1',
        CLKHF => base_clk
    );

    -- this osc drives our clk that will be used for the wave
    clk_osc : osc generic map(
        max_digit => 9
    )
    port map(
        clk_in => base_clk,
        clk_out => clk
    );


    -- this converts MIDI note to rate
    note2freq_converter_1 : note2freq port map(
        midi_note => osc1_midi_note,
        rate => osc1_rate
    );

    the_wave_maker : oscillator port map(
        clk => clk,
        rate => osc1_rate,
        wave_type => osc1_wave_type,
        oscout => output_wave
    );

    wave_switch_debouncer : button_debouncer port map (
        clk => base_clk,
        button_in => wave_switch_button,
        pushed_down => wave_switch_button_pushed_down
    );

    process (base_clk) begin
        if rising_edge(base_clk) then
            if buttons_on(0) then osc1_midi_note <= button_freqs(0);
            elsif buttons_on(1) then osc1_midi_note <= button_freqs(1);
            elsif buttons_on(2) then osc1_midi_note <= button_freqs(2);
            elsif buttons_on(3) then osc1_midi_note <= button_freqs(3);
            elsif buttons_on(4) then osc1_midi_note <= button_freqs(4);
            elsif buttons_on(5) then osc1_midi_note <= button_freqs(5);
            elsif buttons_on(6) then osc1_midi_note <= button_freqs(6);
            elsif buttons_on(7) then osc1_midi_note <= button_freqs(7);
            else
            end if;
            
            if wave_switch_button_pushed_down then
                osc1_wave_type <= 2b"0" when osc1_wave_type = 2b"10" else osc1_wave_type + 1;
            end if;

        end if;
    end process;

    test_out <= output_wave(15 downto 10) when (or buttons_on) else 6b"0";
end synth ; 
