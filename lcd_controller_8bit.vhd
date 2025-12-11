library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_controller_8bit is
    Port ( 
        clk                 : in  std_logic;
        reset               : in  std_logic;
        start_update        : in  std_logic;
        display_data_in     : in  std_logic_vector(255 downto 0);
        lcd_e               : out std_logic;
        lcd_rs              : out std_logic;
        lcd_rw              : out std_logic;
        lcd_db              : out std_logic_vector(7 downto 0)
    );
end lcd_controller_8bit;

architecture Behavioral of lcd_controller_8bit is
    constant CLK_FREQ_HZ : integer := 50_000_000;
    constant WAIT_15MS : integer := 15 * (CLK_FREQ_HZ / 1000);
    constant WAIT_4_1MS : integer := 41 * (CLK_FREQ_HZ / 10000);
    constant WAIT_1_64MS : integer := 164 * (CLK_FREQ_HZ / 100000);
    constant WAIT_100US : integer := 100 * (CLK_FREQ_HZ / 1000000);
    constant WAIT_40US : integer := 40 * (CLK_FREQ_HZ / 1000000);
    constant E_PULSE_WIDTH : integer := 12;
    constant E_SETUP_HOLD : integer := 3;

    constant CMD_CLEAR_DISPLAY : std_logic_vector(7 downto 0) := x"01";
    constant CMD_ENTRY_MODE_SET : std_logic_vector(7 downto 0) := x"06";
    constant CMD_DISPLAY_ON : std_logic_vector(7 downto 0) := x"0C";
    constant CMD_FUNCTION_SET : std_logic_vector(7 downto 0) := x"38";
    constant CMD_SET_ADDR_LINE1 : std_logic_vector(7 downto 0) := x"80";
    constant CMD_SET_ADDR_LINE2 : std_logic_vector(7 downto 0) := x"C0";

    type state_type is (
        S_IDLE, S_POWER_ON_WAIT, S_INIT_CMD1, S_INIT_CMD2, S_INIT_CMD3, 
        S_INIT_FUNCTION_SET, S_INIT_DISPLAY_OFF, S_INIT_CLEAR, S_INIT_ENTRY_MODE, S_INIT_DISPLAY_ON,
        S_SET_ADDR_L1, S_WRITE_L1, S_SET_ADDR_L2, S_WRITE_L2,
        S_SEND_CMD_SETUP, S_SEND_CMD_PULSE, S_SEND_CMD_HOLD, S_WAIT_DELAY
    );
    signal state_reg, state_next : state_type := S_POWER_ON_WAIT;
    signal delay_counter_reg : integer range 0 to WAIT_15MS;
    signal delay_target : integer range 0 to WAIT_15MS;
    signal char_counter_reg : integer range 0 to 15;
    signal return_state : state_type;
    signal lcd_e_reg, lcd_rs_reg : std_logic;
    signal lcd_db_reg : std_logic_vector(7 downto 0);
    signal display_data_buffer : std_logic_vector(255 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            lcd_e <= lcd_e_reg;
            lcd_rs <= lcd_rs_reg;
            lcd_db <= lcd_db_reg;
        end if;
    end process;
    
    lcd_rw <= '0';

    process(clk, reset)
    begin
        if reset = '1' then
            state_reg <= S_POWER_ON_WAIT;
            delay_counter_reg <= 0;
            char_counter_reg <= 0;
            display_data_buffer <= (others => '0');
        elsif rising_edge(clk) then
            state_reg <= state_next;
            if state_reg = S_WAIT_DELAY then
                delay_counter_reg <= delay_counter_reg + 1;
            else
                delay_counter_reg <= 0;
            end if;
            if state_reg = S_SEND_CMD_HOLD and (return_state = S_WRITE_L1 or return_state = S_WRITE_L2) then
                char_counter_reg <= char_counter_reg + 1;
            elsif state_reg = S_SET_ADDR_L1 or state_reg = S_SET_ADDR_L2 then
                char_counter_reg <= 0;
            end if;
            if start_update = '1' then
                display_data_buffer <= display_data_in;
            end if;
        end if;
    end process;

    process(state_reg, start_update, delay_counter_reg, delay_target, char_counter_reg, display_data_buffer)
    begin
        state_next <= state_reg;
        lcd_e_reg <= '0';
        lcd_rs_reg <= '0';
        lcd_db_reg <= (others => '0');
        delay_target <= 0;
        return_state <= S_IDLE;

        case state_reg is
            when S_IDLE => if start_update = '1' then state_next <= S_SET_ADDR_L1; end if;
            when S_POWER_ON_WAIT => delay_target <= WAIT_15MS; state_next <= S_WAIT_DELAY; return_state <= S_INIT_CMD1;
            when S_INIT_CMD1 => lcd_db_reg <= x"30"; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_CMD2; delay_target <= WAIT_4_1MS;
            when S_INIT_CMD2 => lcd_db_reg <= x"30"; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_CMD3; delay_target <= WAIT_100US;
            when S_INIT_CMD3 => lcd_db_reg <= x"30"; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_FUNCTION_SET; delay_target <= WAIT_40US;
            when S_INIT_FUNCTION_SET => lcd_db_reg <= CMD_FUNCTION_SET; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_DISPLAY_OFF; delay_target <= WAIT_40US;
            when S_INIT_DISPLAY_OFF => lcd_db_reg <= x"08"; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_CLEAR; delay_target <= WAIT_40US;
            when S_INIT_CLEAR => lcd_db_reg <= CMD_CLEAR_DISPLAY; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_ENTRY_MODE; delay_target <= WAIT_1_64MS;
            when S_INIT_ENTRY_MODE => lcd_db_reg <= CMD_ENTRY_MODE_SET; state_next <= S_SEND_CMD_SETUP; return_state <= S_INIT_DISPLAY_ON; delay_target <= WAIT_40US;
            when S_INIT_DISPLAY_ON => lcd_db_reg <= CMD_DISPLAY_ON; state_next <= S_SEND_CMD_SETUP; return_state <= S_IDLE; delay_target <= WAIT_40US;
            when S_SET_ADDR_L1 => lcd_db_reg <= CMD_SET_ADDR_LINE1; state_next <= S_SEND_CMD_SETUP; return_state <= S_WRITE_L1; delay_target <= WAIT_40US;
            when S_WRITE_L1 =>
                lcd_rs_reg <= '1';
                lcd_db_reg <= display_data_buffer(255 - char_counter_reg*8 downto 256 - (char_counter_reg+1)*8);
                state_next <= S_SEND_CMD_SETUP;
                if char_counter_reg = 15 then return_state <= S_SET_ADDR_L2; else return_state <= S_WRITE_L1; end if;
                delay_target <= WAIT_40US;
            when S_SET_ADDR_L2 => lcd_db_reg <= CMD_SET_ADDR_LINE2; state_next <= S_SEND_CMD_SETUP; return_state <= S_WRITE_L2; delay_target <= WAIT_40US;
            when S_WRITE_L2 =>
                lcd_rs_reg <= '1';
                lcd_db_reg <= display_data_buffer(127 - char_counter_reg*8 downto 128 - (char_counter_reg+1)*8);
                state_next <= S_SEND_CMD_SETUP;
                if char_counter_reg = 15 then return_state <= S_IDLE; else return_state <= S_WRITE_L2; end if;
                delay_target <= WAIT_40US;
            when S_SEND_CMD_SETUP => lcd_e_reg <= '0'; if delay_counter_reg >= E_SETUP_HOLD then state_next <= S_SEND_CMD_PULSE; else state_next <= S_SEND_CMD_SETUP; end if;
            when S_SEND_CMD_PULSE => lcd_e_reg <= '1'; if delay_counter_reg >= E_PULSE_WIDTH then state_next <= S_SEND_CMD_HOLD; else state_next <= S_SEND_CMD_PULSE; end if;
            when S_SEND_CMD_HOLD => lcd_e_reg <= '0'; if delay_counter_reg >= E_SETUP_HOLD then state_next <= S_WAIT_DELAY; else state_next <= S_SEND_CMD_HOLD; end if;
            when S_WAIT_DELAY => if delay_counter_reg >= delay_target then state_next <= return_state; end if;
        end case;
    end process;
end Behavioral;