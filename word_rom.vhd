library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity word_rom is
    Port ( 
        word_index      : in  std_logic_vector(3 downto 0);
        word_out        : out std_logic_vector(79 downto 0); -- 10 letras * 8 bits (ASCII)
        word_length_out : out integer range 0 to 10
    );
end word_rom;

architecture Behavioral of word_rom is
    -- Função para converter string em std_logic_vector (ASCII) e preencher com espaços
    function to_slv(s: string; len: integer) return std_logic_vector is
        constant max_len : integer := 10;
        variable result : std_logic_vector((max_len*8)-1 downto 0) := (others => x"20"); -- Preenche com espaços
    begin
        for i in 1 to len loop
            result(((max_len-i)*8)+7 downto (max_len-i)*8) := std_logic_vector(to_unsigned(character'pos(s(i)), 8));
        end loop;
        return result;
    end function;

begin
    process(word_index)
    begin
        case word_index is
            when "0000" => 
                word_out <= to_slv("VHDL", 4); 
                word_length_out <= 4;
            when "0001" => 
                word_out <= to_slv("SPARTAN", 7);
                word_length_out <= 7;
            when "0010" => 
                word_out <= to_slv("FORCA", 5);
                word_length_out <= 5;
            when "0011" => 
                word_out <= to_slv("TECLADO", 7);
                word_length_out <= 7;
            when "0100" => 
                word_out <= to_slv("PLACA", 5);
                word_length_out <= 5;
            when "0101" => 
                word_out <= to_slv("LOGICA", 6);
                word_length_out <= 6;
            when "0110" => 
                word_out <= to_slv("JOGO", 4);
                word_length_out <= 4;
            when "0111" => 
                word_out <= to_slv("DISPLAY", 7);
                word_length_out <= 7;
            when "1000" => 
                word_out <= to_slv("CIRCUITO", 8);
                word_length_out <= 8;
            when "1001" => 
                word_out <= to_slv("PROJETO", 7);
                word_length_out <= 7;
            when others => -- Para os índices 10 a 15, repete a primeira palavra
                word_out <= to_slv("VHDL", 4); 
                word_length_out <= 4;
        end case;
    end process;

end Behavioral;