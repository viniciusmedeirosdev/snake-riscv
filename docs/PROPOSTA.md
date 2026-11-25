# Proposta inicial do projeto

Descrição do escopo da etapa 1 (Arquitetura de Computadores, Universidade Católica de Santos). Este arquivo não comprova a data de entrega da proposta à disciplina.

## 1. Identificação

- Estudante: Vinicius Medeiros Peres
- Disciplina: Arquitetura de Computadores. Professor: Walter S. Oliveira

## 2. Tema

Tema 9: **Snake simples**. O jogo da cobrinha, escrito em assembly RISC-V usando só a base RV32I.

## 3. Funcionalidades previstas

- Tela na matriz de LEDs do Ripes (35 × 25), escrita por memória mapeada (`sw` em `0xF0000000`).
- Controle de direção pelo D-Pad do Ripes, lido por memória mapeada (`lw` em `0xF0000DAC`). A cobra não pode dar meia-volta.
- Corpo da cobra guardado na memória (`.data`) como fila circular de endereços de LED.
- Comida em posição aleatória (gerador xorshift, sem `mul`/`div`), sempre numa casa livre.
- Colisão com as bordas e com o próprio corpo, crescimento ao comer, pontuação, vitória com o tabuleiro cheio e reinício.
- Código dividido em sub-rotinas (`jal`/`jalr`, `ra`, pilha), seguindo as convenções de registradores.
- Análise de desempenho (instruções, ciclos e CPI) em diferentes processadores do Ripes.

## 4. Entradas e saídas

| | Dispositivo | Descrição |
|---|---|---|
| Entrada | D-Pad (setas cima, baixo, esquerda e direita) | muda a direção; uma seta inicia e reinicia o jogo |
| Saída | Matriz de LEDs 35 × 25 | amarelo = cabeça, verde = corpo, vermelho = comida, magenta = colisão |
| Saída | Console (ecalls 1 e 4) | mensagens de início, game over / vitória e pontuação |

## 5. Simulador e periféricos

- Simulador principal: **Ripes**, processador RV32I (single-cycle para jogar; modelos com pipeline para a análise).
- Periféricos: *LED Matrix* (35 × 25) e *D-Pad*, adicionados nessa ordem na aba I/O.
