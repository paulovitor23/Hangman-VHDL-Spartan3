library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm is
    Port ( 
        clk                 : in  std_logic;
        reset               : in  std_logic;
        word_to_guess_in    : in  std_logic_vector(79 downto 0);
        word_length_in      : in  integer range 0 to 10;
        key_scancode_in     : in  std_logic_vector(7 downto 0);
        new_key_ready_in    : in  std_logic;
        display_info_out    : out std_logic_vector(255 downto 0);
        start_lcd_update_out: out std_logic
    );
end game_fsm;

architecture Behavioral of game_fsm is

    type state_type is (S_INIT, S_WAIT_START, S_PLAYING, S_CHECK_KEY, S_WIN, S_LOSE);
    signal state_reg, state_next : state_type := S_INIT;
    signal lives_reg, lives_next : integer range 0 to 6;
    signal secret_word_reg : std_logic_vector(79 downto 0);
    signal word_length_reg : integer range 0 to 10;
    signal display_word_reg, display_word_next : std_logic_vector(79 downto 0);
    signal incorrect_letters_reg, incorrect_letters_next : std_logic_vector(47 downto 0);
    signal incorrect_count_reg, incorrect_count_next : integer range 0 to 6;
    signal guessed_letters_mask_reg, guessed_letters_mask_next : std_logic_vector(25 downto 0);
    signal ascii_key : std_logic_vector(7 downto 0);
    signal trigger_lcd_update : std_logic;

begin
    process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= S_INIT;
            lives_reg <= 6;
            word_length_reg <= 0;
            secret_word_reg <= (others => '0');
            display_word_reg <= (others => '0');
            incorrect_letters_reg <= (others => '0');
            incorrect_count_reg <= 0;
            guessed_letters_mask_reg <= (others => '0');
        elsif rising_edge(clk) then
            state_reg <= state_next;
            lives_reg <= lives_next;
            word_length_reg <= word_length_in;
            secret_word_reg <= word_to_guess_in;
            display_word_reg <= display_word_next;
            incorrect_letters_reg <= incorrect_letters_next;
            incorrect_count_reg <= incorrect_count_next;
            guessed_letters_mask_reg <= guessed_letters_mask_next;
        end if;
    end process;
    
    start_lcd_update_out <= trigger_lcd_update;

    process(state_reg, lives_reg, secret_word_reg, word_length_reg, display_word_reg,
            incorrect_letters_reg, incorrect_count_reg, guessed_letters_mask_reg,
            new_key_ready_in, ascii_key)
            
        variable v_letter_found : boolean;
        variable v_letter_index : integer;
        variable v_is_new_guess : boolean;
        variable v_is_win       : boolean;
        
    begin
        state_next <= state_reg;
        lives_next <= lives_reg;
        display_word_next <= display_word_reg;
        incorrect_letters_next <= incorrect_letters_reg;
        incorrect_count_next <= incorrect_count_reg;
        guessed_letters_mask_next <= guessed_letters_mask_reg;
        trigger_lcd_update <= '0';
        
        case state_reg is
            when S_INIT =>
                lives_next <= 6;
                incorrect_count_next <= 0;
                guessed_letters_mask_next <= (others => '0');
                display_word_next <= (others => '0');
                incorrect_letters_next <= (others => '0');
                trigger_lcd_update <= '1';
                state_next <= S_WAIT_START;

            when S_WAIT_START =>
                if new_key_ready_in = '1' and ascii_key = x"20" then
                    display_word_next <= (others => '0');
                    for i in 0 to word_length_reg - 1 loop
                        display_word_next((9-i)*8+7 downto (9-i)*8) <= x"5F";
                    end loop;
                    trigger_lcd_update <= '1';
                    state_next <= S_PLAYING;
                end if;

            when S_PLAYING =>
                if new_key_ready_in = '1' and (unsigned(ascii_key) >= to_unsigned(character'pos('A'), 8) and unsigned(ascii_key) <= to_unsigned(character'pos('Z'), 8)) then
                    state_next <= S_CHECK_KEY;
                end if;

            when S_CHECK_KEY =>
                v_letter_index := to_integer(unsigned(ascii_key) - to_unsigned(character'pos('A'), 8));
                v_is_new_guess := (guessed_letters_mask_reg(v_letter_index) = '0');
                
                if v_is_new_guess then
                    guessed_letters_mask_next <= guessed_letters_mask_reg;
                    guessed_letters_mask_next(v_letter_index) <= '1';
                    
                    v_letter_found := false;
                    for i in 0 to word_length_reg - 1 loop
                        if secret_word_reg((9-i)*8+7 downto (9-i)*8) = ascii_key then
                            display_word_next((9-i)*8+7 downto (9-i)*8) <= ascii_key;
                            v_letter_found := true;
                        end if;
                    end loop;
                    
                    if not v_letter_found then
                        lives_next <= lives_reg - 1;
                        if incorrect_count_reg < 6 then
                            incorrect_letters_next((5-incorrect_count_reg)*8+7 downto (5-incorrect_count_reg)*8) <= ascii_key;
                            incorrect_count_next <= incorrect_count_reg + 1;
                        end if;
                    end if;
                    
                    v_is_win := true;
                    for i in 0 to word_length_reg - 1 loop
                        if display_word_next((9-i)*8+7 downto (9-i)*8) = x"5F" then
                            v_is_win := false;
                        end if;
                    end loop;
                    
                    if v_is_win then
                        state_next <= S_WIN;
                    elsif (not v_letter_found and lives_reg = 1) then -- Checando se a vida vai para 0
                        state_next <= S_LOSE;
                    else
                        state_next <= S_PLAYING;
                    end if;
                    trigger_lcd_update <= '1';
                else
                    state_next <= S_PLAYING;
                end if;
            
            when S_WIN =>
                if new_key_ready_in = '1' and ascii_key = x"20" then
                    state_next <= S_INIT;
                end if;
                
            when S_LOSE =>
                if new_key_ready_in = '1' and ascii_key = x"20" then
                    state_next <= S_INIT;
                end if;
        end case;
    end process;

    scancode_to_ascii_proc: process(key_scancode_in)
    begin
        case key_scancode_in is
            when x"1C" => ascii_key <= x"41"; when x"32" => ascii_key <= x"42"; when x"21" => ascii_key <= x"43"; when x"23" => ascii_key <= x"44"; when x"24" => ascii_key <= x"45"; when x"2B" => ascii_key <= x"46"; when x"34" => ascii_key <= x"47"; when x"33" => ascii_key <= x"48"; when x"43" => ascii_key <= x"49"; when x"3B" => ascii_key <= x"4A"; when x"42" => ascii_key <= x"4B"; when x"4B" => ascii_key <= x"4C"; when x"3A" => ascii_key <= x"4D"; when x"31" => ascii_key <= x"4E"; when x"44" => ascii_key <= x"4F"; when x"4D" => ascii_key <= x"50"; when x"15" => ascii_key <= x"51"; when x"2D" => ascii_key <= x"52"; when x"1B" => ascii_key <= x"53"; when x"2C" => ascii_key <= x"54"; when x"3C" => ascii_key <= x"55"; when x"2A" => ascii_key <= x"56"; when x"1D" => ascii_key <= x"57"; when x"22" => ascii_key <= x"58"; when x"35" => ascii_key <= x"59"; when x"1A" => ascii_key <= x"5A";
            when x"29" => ascii_key <= x"20"; -- ESPAÇO
            when others => ascii_key <= x"00";
        end case;
    end process;

    display_formatter_proc: process(state_reg, lives_reg, display_word_reg, incorrect_letters_reg, secret_word_reg, word_length_reg)
        function to_slv_str(s : string) return std_logic_vector is
            variable res : std_logic_vector(1 to s'length*8);
        begin
            for i in s'range loop
                res((i-1)*8+1 to i*8) := std_logic_vector(to_unsigned(character'pos(s(i)), 8));
            end loop;
            return res;
        end function;
        
        variable line1, line2 : std_logic_vector(127 downto 0);
        variable lives_char : character;
    begin
        line1 := (others => x"20"); line2 := (others => x"20");
        
        case state_reg is
            when S_INIT | S_WAIT_START =>
                line1(127 downto 128-16*8) := to_slv_str("JOGO DA FORCA   ");
                line2(127 downto 128-16*8) := to_slv_str("Pressione ESPACO");
            when S_PLAYING | S_CHECK_KEY =>
                line1(127 downto 128-6*8) := incorrect_letters_reg;
                line2(127 downto 128-10*8) := display_word_reg;
                line2(127-13*8 downto 128-16*8) := to_slv_str(" V:");
                case lives_reg is
                    when 6 => lives_char := '6'; when 5 => lives_char := '5'; when 4 => lives_char := '4'; when 3 => lives_char := '3'; when 2 => lives_char := '2'; when 1 => lives_char := '1'; when others => lives_char := '0';
                end case;
                line2(127-15*8 downto 128-16*8) := std_logic_vector(to_unsigned(character'pos(lives_char), 8));
            when S_WIN =>
                line1(127 downto 128-16*8) := to_slv_str("   PARABENS!    ");
                line2(127 downto 128-16*8) := to_slv_str(" Voce Venceu!   ");
            when S_LOSE =>
                line1(127 downto 128-16*8) := to_slv_str("  FIM DE JOGO   ");
                line2(127 downto 128-word_length_reg*8) := secret_word_reg(79 downto 80-word_length_reg*8);
        end case;
        display_info_out <= line1 & line2;
    end process;
end Behavioral;