library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mix2 is
    port(
        -- output_wave : out signed(15 downto 0) := to_signed(0, 16)
        test_out : out signed(5 downto 0);

        buttons_on : in std_logic_vector(0 to 7);

        wave_switch_button : in std_logic := '0'
    );
end mix2;

architecture synth of mix2 is

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
    signal osc2_rate : signed(15 downto 0);
    signal osc3_rate : signed(15 downto 0);
    signal osc4_rate : signed(15 downto 0);
    signal osc5_rate : signed(15 downto 0);
    signal osc6_rate : signed(15 downto 0);
    signal osc7_rate : signed(15 downto 0);
    signal osc8_rate : signed(15 downto 0);

    signal base_clk : std_logic := '0';
    signal clk : std_logic := '0';

    signal output_wave_1 : signed(15 downto 0);
    signal output_wave_2 : signed(15 downto 0);
    signal output_wave_3 : signed(15 downto 0);
    signal output_wave_4 : signed(15 downto 0);
    signal output_wave_5 : signed(15 downto 0);
    signal output_wave_6 : signed(15 downto 0);
    signal output_wave_7 : signed(15 downto 0);
    signal output_wave_8 : signed(15 downto 0);

    signal output_wave_1_used : signed(18 downto 0);
    signal output_wave_2_used : signed(18 downto 0);
    signal output_wave_3_used : signed(18 downto 0);
    signal output_wave_4_used : signed(18 downto 0);
    signal output_wave_5_used : signed(18 downto 0);
    signal output_wave_6_used : signed(18 downto 0);
    signal output_wave_7_used : signed(18 downto 0);
    signal output_wave_8_used : signed(18 downto 0);

    signal output_wave : signed(18 downto 0);

    -- signal button_freqs : MIDI_NOTE_ARRAY := (7d"69", 7d"70", 7d"71", 7d"72", 7d"73", 7d"74", 7d"75", 7d"76");
    -- signal button_freqs : MIDI_NOTE_ARRAY := (7d"36", 7d"40", 7d"43", 7d"48", 7d"52", 7d"55", 7d"60", 7d"64");
    signal button_freqs : MIDI_NOTE_ARRAY := (7d"60", 7d"62", 7d"64", 7d"65", 7d"67", 7d"69", 7d"71", 7d"72"); -- C major scale

    signal osc_wave_type : unsigned(1 downto 0) := 2b"00";

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


    -- NOTE TO FREQUENCY CONVERTERS

    note2freq_converter_1 : note2freq port map(
        midi_note => button_freqs(0),
        rate => osc1_rate
    );

    note2freq_converter_2 : note2freq port map(
        midi_note => button_freqs(1),
        rate => osc2_rate
    );

    note2freq_converter_3 : note2freq port map(
        midi_note => button_freqs(2),
        rate => osc3_rate
    );

    note2freq_converter_4 : note2freq port map(
        midi_note => button_freqs(3),
        rate => osc4_rate
    );

    note2freq_converter_5 : note2freq port map(
        midi_note => button_freqs(4),
        rate => osc5_rate
    );

    note2freq_converter_6 : note2freq port map(
        midi_note => button_freqs(5),
        rate => osc6_rate
    );

    note2freq_converter_7 : note2freq port map(
        midi_note => button_freqs(6),
        rate => osc7_rate
    );

    note2freq_converter_8 : note2freq port map(
        midi_note => button_freqs(7),
        rate => osc8_rate
    );

    -- OSCILLATORS

    the_wave_maker_1 : oscillator port map(
        clk => clk,
        rate => osc1_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_1
    );

    the_wave_maker_2 : oscillator port map(
        clk => clk,
        rate => osc2_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_2
    );

    the_wave_maker_3 : oscillator port map(
        clk => clk,
        rate => osc3_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_3
    );

    the_wave_maker_4 : oscillator port map(
        clk => clk,
        rate => osc4_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_4
    );

    the_wave_maker_5 : oscillator port map(
        clk => clk,
        rate => osc5_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_5
    );

    the_wave_maker_6 : oscillator port map(
        clk => clk,
        rate => osc6_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_6
    );

    the_wave_maker_7 : oscillator port map(
        clk => clk,
        rate => osc7_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_7
    );

    the_wave_maker_8 : oscillator port map(
        clk => clk,
        rate => osc8_rate,
        wave_type => osc_wave_type,
        oscout => output_wave_8
    );


    output_wave_1_used <= "000" & output_wave_1 when buttons_on(0) else 19d"0";
    output_wave_2_used <= "000" & output_wave_2 when buttons_on(1) else 19d"0";
    output_wave_3_used <= "000" & output_wave_3 when buttons_on(2) else 19d"0";
    output_wave_4_used <= "000" & output_wave_4 when buttons_on(3) else 19d"0";
    output_wave_5_used <= "000" & output_wave_5 when buttons_on(4) else 19d"0";
    output_wave_6_used <= "000" & output_wave_6 when buttons_on(5) else 19d"0";
    output_wave_7_used <= "000" & output_wave_7 when buttons_on(6) else 19d"0";
    output_wave_8_used <= "000" & output_wave_8 when buttons_on(7) else 19d"0";

    output_wave <= output_wave_1_used + output_wave_2_used + output_wave_3_used +
            output_wave_4_used + output_wave_5_used + output_wave_6_used +
            output_wave_7_used + output_wave_8_used;


    wave_switch_debouncer : button_debouncer port map (
        clk => base_clk,
        button_in => wave_switch_button,
        pushed_down => wave_switch_button_pushed_down
    );

    process (base_clk) begin
        if rising_edge(base_clk) then
            if wave_switch_button_pushed_down then
                osc_wave_type <= 2b"0" when osc_wave_type = 2b"10" else osc_wave_type + 1;
            end if;

        end if;
    end process;

    test_out <= output_wave(18 downto 13) when (or buttons_on) else 6b"0";
end synth ;
