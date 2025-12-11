# Jogo da Forca em FPGA (VHDL) 🎮

Este projeto consiste na implementação de um **Jogo da Forca** utilizando a linguagem de descrição de hardware **VHDL**, projetado para a placa de desenvolvimento **Xilinx Spartan-3A Starter Kit**. O sistema integra periféricos de entrada (Teclado PS/2) e saída (Display LCD) para criar uma experiência de jogo interativa completa.

## 📋 Sobre o Projeto

O objetivo deste projeto é demonstrar o controle de periféricos e lógica de estados complexa em FPGA. O usuário seleciona uma palavra secreta de um banco de memória interno, e deve adivinhá-la digitando letras no teclado antes que suas vidas acabem.

[cite_start]Este trabalho foi desenvolvido como parte da disciplina de Sistemas Digitais na **Universidade Federal do Rio de Janeiro (UFRJ)**[cite: 169, 172].

## ⚙️ Funcionalidades

* [cite_start]**Interface PS/2:** Captura e decodificação de scancodes de um teclado externo[cite: 130, 198].
* [cite_start]**Controle de LCD 16x2:** Driver personalizado para exibição de caracteres, status do jogo e mensagens de vitória/derrota[cite: 23, 210].
* [cite_start]**Lógica de Jogo (FSM):** Máquina de estados que gerencia palpites, contagem de vidas (6 tentativas) e verificação de vitória[cite: 71, 72].
* [cite_start]**Banco de Palavras:** ROM interna contendo palavras selecionáveis via switches (ex: "FPGA", "VHDL", "SPARTAN")[cite: 153, 213].

## 🛠️ Hardware Utilizado

* [cite_start]**Placa:** Xilinx Spartan-3A / 3AN FPGA Starter Kit[cite: 1].
* **Entrada:** Teclado padrão PS/2.
* **Saída:** Display LCD 16x2 (integrado à placa ou externo).

## 🚀 Como Jogar

1.  [cite_start]**Configuração:** Utilize os switches `SW0` a `SW3` na placa para selecionar o índice da palavra secreta (0 a 9) [cite: 5-7, 213].
2.  [cite_start]**Início:** Pressione a tecla `ESPAÇO` no teclado para iniciar a rodada[cite: 87, 216].
3.  **Gameplay:**
    * Digite letras (A-Z) para tentar adivinhar a palavra.
    * A primeira linha do LCD mostra a palavra mascarada (ex: `_ _ _ _`).
    * [cite_start]A segunda linha mostra as letras erradas já chutadas e o número de vidas restantes [cite: 223-225].
4.  **Fim de Jogo:**
    * [cite_start]**Vitória:** Se completar a palavra, aparecerá "VOCE GANHOU"[cite: 234].
    * [cite_start]**Derrota:** Se as vidas chegarem a 0, aparecerá "VOCE PERDEU"[cite: 238].
    * [cite_start]Pressione `ESPAÇO` para reiniciar[cite: 102].

## 📂 Estrutura dos Arquivos

* [cite_start]`game_fsm.vhd`: Lógica principal e máquina de estados do jogo[cite: 69].
* [cite_start]`lcd_controller_8bit.vhd`: Controlador de baixo nível para o display LCD[cite: 23].
* [cite_start]`ps2_keyboard_interface.vhd`: Interface física e lógica para o teclado PS/2[cite: 130].
* [cite_start]`word_rom.vhd`: Memória contendo as palavras do jogo[cite: 153].
* [cite_start]`hangman.ucf`: Arquivo de restrições de pinagem para a Spartan-3A[cite: 1].

## 🔌 Pinagem (Spartan-3A)

[cite_start]Conforme definido no arquivo `.ucf` [cite: 2-22]:

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

* [cite_start]**Erik Branco Queiroz** [cite: 176]
* [cite_start]**Paulo Vitor Couto Doederlein** [cite: 177]
* [cite_start]**Arthur Freitas Ramos** [cite: 178]

---
[cite_start]*Projeto desenvolvido em Dezembro de 2025.* [cite: 183]
