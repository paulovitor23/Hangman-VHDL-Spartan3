# Jogo da Forca em FPGA (VHDL) 🎮

Este projeto consiste na implementação de um **Jogo da Forca** utilizando a linguagem de descrição de hardware **VHDL**, projetado para a placa de desenvolvimento **Xilinx Spartan-3A Starter Kit**. O sistema integra periféricos de entrada (Teclado PS/2) e saída (Display LCD) para criar uma experiência de jogo interativa completa.

## 📋 Sobre o Projeto

O objetivo deste projeto é demonstrar o controle de periféricos e lógica de estados complexa em FPGA. O usuário seleciona uma palavra secreta de um banco de memória interno e deve adivinhá-la digitando letras no teclado antes que suas vidas acabem.

Este trabalho foi desenvolvido como parte da disciplina de Sistemas Digitais na **Universidade Federal do Rio de Janeiro (UFRJ)**.

## ⚙️ Funcionalidades

* **Interface PS/2:** Captura e decodificação de scancodes de um teclado externo.
* **Controle de LCD 16x2:** Driver personalizado para exibição de caracteres, status do jogo e mensagens de vitória/derrota.
* **Lógica de Jogo (FSM):** Máquina de estados que gerencia palpites, contagem de vidas (6 tentativas) e verificação de vitória.
* **Banco de Palavras:** ROM interna contendo palavras selecionáveis via switches (ex: "FPGA", "VHDL", "SPARTAN").

## 🛠️ Hardware Utilizado

* **Placa:** Xilinx Spartan-3A / 3AN FPGA Starter Kit.
* **Entrada:** Teclado padrão PS/2.
* **Saída:** Display LCD 16x2 (integrado à placa ou externo).

## 🚀 Como Jogar

1.  **Configuração:** Utilize os switches `SW0` a `SW3` na placa para selecionar o índice da palavra secreta (0 a 9).
2.  **Início:** Pressione a tecla `ESPAÇO` no teclado para iniciar a rodada.
3.  **Gameplay:**
    * Digite letras (A-Z) para tentar adivinhar a palavra.
    * A primeira linha do LCD mostra a palavra mascarada (ex: `_ _ _ _`).
    * A segunda linha mostra as letras erradas já chutadas e o número de vidas restantes.
4.  **Fim de Jogo:**
    * **Vitória:** Se completar a palavra, aparecerá "VOCE GANHOU".
    * **Derrota:** Se as vidas chegarem a 0, aparecerá "VOCE PERDEU".
    * Pressione `ESPAÇO` para reiniciar.

## 📂 Estrutura dos Arquivos

* `game_fsm.vhd`: Lógica principal e máquina de estados do jogo.
* `lcd_controller_8bit.vhd`: Controlador de baixo nível para o display LCD.
* `ps2_keyboard_interface.vhd`: Interface física e lógica para o teclado PS/2.
* `word_rom.vhd`: Memória contendo as palavras do jogo.
* `hangman.ucf`: Arquivo de restrições de pinagem para a Spartan-3A.

## 🔌 Pinagem (Spartan-3A)

Conforme definido no arquivo `.ucf`:

| Sinal | Pino FPGA | Descrição |
| :--- | :--- | :--- |
| **CLK_50MHZ** | E12 | Clock principal |
| **BTN_RESET** | T14 | Reset do sistema (Botão Norte) |
| **SW<0:3>** | V8, U10, U8, T9 | Seleção da palavra |
| **PS2_CLK** | W12 | Clock do Teclado |
| **PS2_DATA** | V11 | Dados do Teclado |
| **LCD_E** | AB4 | Enable do LCD |
| **LCD_RS** | Y14 | Register Select do LCD |
| **LCD_RW** | W13 | Read/Write do LCD |
| **LCD_DB<0:7>** | Y13, AB18... | Barramento de dados do LCD |

## 👥 Autores

* **Erik Branco Queiroz**
* **Paulo Vitor Couto Doederlein**
* **Arthur Freitas Ramos**

---
*Projeto desenvolvido em Dezembro de 2025.*
