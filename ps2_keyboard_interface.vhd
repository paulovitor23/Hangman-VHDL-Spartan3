library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_keyboard_interface is
    Port ( 
        clk            : in  std_logic; -- Clock principal de 50 MHz
        reset          : in  std_logic;
        ps2_clk        : inout std_logic;
        ps2_data       : inout std_logic;
        scancode       : out std_logic_vector(7 downto 0);
        scancode_ready : out std_logic
    );
end ps2_keyboard_interface;

architecture Behavioral of ps2_keyboard_interface is
    type state_type is (IDLE, RECEIVING, DONE);
    signal state        : state_type := IDLE;
    signal bit_count    : integer range 0 to 10 := 0;
    signal ps2_frame    : std_logic_vector(10 downto 0);
    signal temp_scancode: std_logic_vector(7 downto 0);
    signal ready_pulse  : std_logic := '0';
    
    -- Sinais para filtrar e detectar a borda de descida do clock do PS/2
    signal ps2_clk_sync : std_logic_vector(2 downto 0);
    signal ps2_clk_fall_edge : std_logic;

begin
    -- O pino ps2_clk e ps2_data são open-drain. Deixá-los em alta impedância permite "escutar".
    ps2_clk <= 'Z';
    ps2_data <= 'Z';

    -- Processo para sincronizar e detectar a borda de descida do clock do PS/2
    process(clk, reset)
    begin
        if reset = '1' then
            ps2_clk_sync <= (others => '1');
        elsif rising_edge(clk) then
            ps2_clk_sync <= ps2_clk_sync(1 downto 0) & ps2_clk;
        end if;
    end process;
    
    ps2_clk_fall_edge <= '1' when ps2_clk_sync(2 downto 1) = "10" else '0';

    -- Máquina de estados para receber o frame PS/2
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            bit_count <= 0;
            ready_pulse <= '0';
            scancode <= (others => '0');
        elsif rising_edge(clk) then
            ready_pulse <= '0'; -- O pulso de 'pronto' dura apenas um ciclo
            
            if ps2_clk_fall_edge = '1' then
                case state is
                    when IDLE =>
                        if ps2_data = '0' then -- Bit de início detectado
                            state <= RECEIVING;
                            bit_count <= 0;
                        end if;
                        
                    when RECEIVING =>
                        if bit_count < 10 then
                            ps2_frame(bit_count) <= ps2_data;
                            bit_count <= bit_count + 1;
                        else -- Fim do frame
                            -- Frame recebido: [d0..d7, paridade, stop]
                            -- O bit de stop deve ser '1'. A verificação de paridade pode ser adicionada aqui.
                            if ps2_data = '1' then
                                temp_scancode <= ps2_frame(8 downto 1);
                                state <= DONE;
                            else -- Erro de frame, volta para IDLE
                                state <= IDLE;
                            end if;
                            bit_count <= 0;
                        end if;
                        
                    when DONE =>
                        -- Mantém o scancode válido por um ciclo e gera o pulso de 'pronto'
                        scancode <= temp_scancode;
                        ready_pulse <= '1';
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    scancode_ready <= ready_pulse;

end Behavioral;