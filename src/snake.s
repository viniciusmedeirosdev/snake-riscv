# Snake - assembly RISC-V (RV32I) - Ripes
#
# Perifericos (aba I/O do Ripes), nesta ordem:
#   LED Matrix 35x25 -> 0xF0000000
#   D-Pad            -> 0xF0000DAC
# Aperte uma seta para comecar. Pontuacao aparece no console.

        .equ LED_BASE,   0xF0000000   # LED_MATRIX_0_BASE
        .equ DPAD_BASE,  0xF0000DAC   # D_PAD_0_BASE (UP=+0 DOWN=+4 LEFT=+8 RIGHT=+12)
        .equ W,          35           # largura da matriz
        .equ H,          25           # altura da matriz
        .equ CELLS,      875          # W*H
        .equ BUF_BYTES,  3500         # CELLS*4 (tamanho do buffer circular)

        .equ C_BLACK,    0x00000000
        .equ C_BODY,     0x0000C000   # verde
        .equ C_HEAD,     0x00FFFF00   # amarelo
        .equ C_FOOD,     0x00FF0000   # vermelho
        .equ C_DEAD,     0x00FF00FF   # magenta (cabeça na colisão)

        .equ DIR_UP,     0
        .equ DIR_DOWN,   1
        .equ DIR_LEFT,   2
        .equ DIR_RIGHT,  3

        .equ DELAY,      1000         # velocidade: maior = mais lento
        .equ START_LEN,  3

# ---------------------------------------------------------------------
#  Uso dos registradores salvos (valem durante o jogo todo)
#    s0  = base da matriz de LEDs       s1  = base do D-Pad
#    s2  = x da cabeça                  s3  = y da cabeça
#    s4  = direção atual                s5  = endereço do buffer da cobra
#    s6  = índice (bytes) da cabeça     s7  = índice (bytes) da cauda
#    s8  = tamanho da cobra             s9  = estado do gerador aleatório
#    s10 = pontos (comidas)             s11 = próxima direção (do D-Pad)
# ---------------------------------------------------------------------

        .data
body:   .zero 3500                  # buffer circular: endereços dos LEDs da cobra
msg_start: .string "SNAKE RV32I - aperte uma direcao no D-Pad para comecar\n"
msg_over:  .string "GAME OVER! Pontos: "
msg_win:   .string "VOCE VENCEU! Pontos: "
msg_again: .string "\nAperte uma direcao para jogar de novo.\n"

        .text
main:
        li   s0, LED_BASE
        li   s1, DPAD_BASE
        la   s5, body
        li   s9, 0

        la   a0, msg_start
        li   a7, 4                  # ecall 4 = imprime string
        ecall
        mv   a0, s0
        jal  ra, clear_screen

new_game:
        # --- espera o jogador apertar algo; o contador vira a semente ---
        mv   a0, s1
        jal  ra, wait_release
wait_start:
        addi s9, s9, 1
        mv   a0, s1
        jal  ra, any_pressed
        beqz a0, wait_start
        ori  s9, s9, 1              # semente nunca pode ser zero (xorshift)
        # Mantém o resultado visível até o comando de uma nova partida.
        mv   a0, s0
        jal  ra, clear_screen

        # --- cobra inicial: 3 gomos na linha central, andando para a direita ---
        li   s3, 12                 # y
        li   s2, 5                  # x da cauda
        li   s6, -4                 # índice da cabeça (vai para 0 no 1º push)
        li   s7, 0                  # índice da cauda
        li   s8, 0
        li   s10, 0
        li   s4, DIR_RIGHT
        li   s11, DIR_RIGHT
init_body:
        mv   a0, s2
        mv   a1, s3
        mv   a2, s0
        jal  ra, xy_to_addr
        addi s6, s6, 4
        add  t0, s5, s6
        sw   a0, 0(t0)              # guarda endereço do gomo
        li   t1, C_BODY
        sw   t1, 0(a0)              # acende o LED
        addi s8, s8, 1
        addi s2, s2, 1
        li   t6, START_LEN
        blt  s8, t6, init_body
        addi s2, s2, -1             # s2 volta a apontar para a cabeça
        li   t1, C_HEAD
        sw   t1, 0(a0)

        mv   a0, s9
        mv   a1, s0
        jal  ra, spawn_food
        mv   s9, a0

# =====================================================================
#  Laço principal: espera um "tick", move a cobra, trata colisões
# =====================================================================
game_loop:
        mv   a0, s4
        mv   a1, s9
        mv   a2, s1
        jal  ra, delay_and_poll
        mv   s11, a0
        mv   s9, a1
        mv   s4, s11                # aplica a direção escolhida

        # --- nova posição da cabeça (t2 = nx, t3 = ny) ---
        mv   t2, s2
        mv   t3, s3
        li   t0, DIR_UP
        beq  s4, t0, mv_up
        li   t0, DIR_DOWN
        beq  s4, t0, mv_down
        li   t0, DIR_LEFT
        beq  s4, t0, mv_left
        addi t2, t2, 1              # direita
        j    mv_done
mv_up:
        addi t3, t3, -1
        j    mv_done
mv_down:
        addi t3, t3, 1
        j    mv_done
mv_left:
        addi t2, t2, -1
mv_done:
        # --- colisão com a borda (comparação sem sinal pega o -1 também) ---
        li   t0, W
        bgeu t2, t0, game_over
        li   t0, H
        bgeu t3, t0, game_over

        mv   s2, t2
        mv   s3, t3
        mv   a0, s2
        mv   a1, s3
        mv   a2, s0
        jal  ra, xy_to_addr
        mv   t4, a0                 # t4 = endereço do LED da nova cabeça

        # --- comeu? ---
        lw   t0, 0(t4)
        li   t1, C_FOOD
        li   t5, 0                  # t5 = 1 se comeu
        bne  t0, t1, no_food
        li   t5, 1
        j    after_tail
no_food:
        # sem comida: a cauda anda (apaga o último gomo)
        add  t0, s5, s7
        lw   t0, 0(t0)
        sw   zero, 0(t0)
        addi s7, s7, 4
        li   t0, BUF_BYTES
        blt  s7, t0, tail_ok
        li   s7, 0
tail_ok:
        addi s8, s8, -1
        # colisão com o próprio corpo (depois de mover a cauda,
        # então encostar na ponta da cauda é permitido)
        lw   t0, 0(t4)
        bnez t0, game_over
after_tail:
        # cabeça antiga vira corpo
        add  t0, s5, s6
        lw   t0, 0(t0)
        li   t1, C_BODY
        sw   t1, 0(t0)
        # empilha a nova cabeça no buffer circular
        addi s6, s6, 4
        li   t0, BUF_BYTES
        blt  s6, t0, head_ok
        li   s6, 0
head_ok:
        add  t0, s5, s6
        sw   t4, 0(t0)
        li   t1, C_HEAD
        sw   t1, 0(t4)
        addi s8, s8, 1

        beqz t5, game_loop
        addi s10, s10, 1            # +1 ponto
        li   t0, CELLS
        bge  s8, t0, you_win        # tabuleiro cheio
        mv   a0, s9
        mv   a1, s0
        jal  ra, spawn_food
        mv   s9, a0
        j    game_loop

# =====================================================================
#  Fim de jogo
# =====================================================================
game_over:
        mv   a0, s2                 # pinta a posição atual da cabeça
        mv   a1, s3
        mv   a2, s0
        jal  ra, xy_to_addr
        li   t1, C_DEAD
        sw   t1, 0(a0)
        la   a0, msg_over
        j    show_score
you_win:
        la   a0, msg_win
show_score:
        li   a7, 4
        ecall
        mv   a0, s10
        li   a7, 1                  # ecall 1 = imprime inteiro
        ecall
        la   a0, msg_again
        li   a7, 4
        ecall
        j    new_game

# =====================================================================
#  Sub-rotinas
# =====================================================================

# xy_to_addr: a0 = x, a1 = y, a2 = base dos LEDs -> a0 = endereço
# y*35 = y*32 + y*2 + y  (RV32I não tem MUL)
xy_to_addr:
        slli t0, a1, 5
        slli t1, a1, 1
        add  t0, t0, t1
        add  t0, t0, a1
        add  t0, t0, a0
        slli t0, t0, 2
        add  a0, a2, t0
        ret

# rand: a0 = estado xorshift32; devolve o novo estado em a0
rand:
        bnez a0, rand_ok            # xorshift trava se o estado for 0
        li   a0, 1
rand_ok:
        slli t0, a0, 13
        xor  a0, a0, t0
        srli t0, a0, 17
        xor  a0, a0, t0
        slli t0, a0, 5
        xor  a0, a0, t0
        ret

# spawn_food: a0 = semente, a1 = base dos LEDs; retorna a0 = nova semente
# x = 6 bits aleatórios (0..63), rejeita se >= 35
# y = 5 bits aleatórios (0..31), rejeita se >= 25
spawn_food:
        addi sp, sp, -16
        sw   ra, 0(sp)
        sw   a0, 4(sp)
        sw   a1, 8(sp)
sf_try:
        lw   a0, 4(sp)
        jal  ra, rand
        sw   a0, 4(sp)
        andi a2, a0, 63             # x candidato
        srli a3, a0, 8
        andi a3, a3, 31             # y candidato
        li   t0, W
        bgeu a2, t0, sf_try
        li   t0, H
        bgeu a3, t0, sf_try
        mv   a0, a2
        mv   a1, a3
        lw   a2, 8(sp)
        jal  ra, xy_to_addr
        lw   t0, 0(a0)
        bnez t0, sf_try             # célula ocupada: sorteia de novo
        li   t1, C_FOOD
        sw   t1, 0(a0)
        lw   a0, 4(sp)
        lw   ra, 0(sp)
        addi sp, sp, 16
        ret

# delay_and_poll: a0 = direção atual, a1 = semente, a2 = base do D-Pad.
# Retorna a0 = próxima direção, a1 = semente atualizada; ignora meia-volta.
delay_and_poll:
        mv   a3, a0
        li   t6, DELAY
dp_loop:
        lw   t0, 0(a2)              # UP
        beqz t0, dp_down
        li   t1, DIR_DOWN
        beq  a3, t1, dp_down
        li   a0, DIR_UP
dp_down:
        lw   t0, 4(a2)              # DOWN
        beqz t0, dp_left
        li   t1, DIR_UP
        beq  a3, t1, dp_left
        li   a0, DIR_DOWN
dp_left:
        lw   t0, 8(a2)              # LEFT
        beqz t0, dp_right
        li   t1, DIR_RIGHT
        beq  a3, t1, dp_right
        li   a0, DIR_LEFT
dp_right:
        lw   t0, 12(a2)             # RIGHT
        beqz t0, dp_next
        li   t1, DIR_LEFT
        beq  a3, t1, dp_next
        li   a0, DIR_RIGHT
dp_next:
        addi a1, a1, 1              # mistura o tempo do jogador na semente
        addi t6, t6, -1
        bnez t6, dp_loop
        ret

# any_pressed: a0 = base do D-Pad; retorna a0 = 1 se há botão apertado
any_pressed:
        lw   t0, 0(a0)
        lw   t1, 4(a0)
        or   t0, t0, t1
        lw   t1, 8(a0)
        or   t0, t0, t1
        lw   t1, 12(a0)
        or   t0, t0, t1
        sltu a0, zero, t0           # a0 = (t0 != 0)
        ret

# wait_release: a0 = base do D-Pad; espera soltar todos os botões
wait_release:
        addi sp, sp, -16
        sw   ra, 0(sp)
        sw   a0, 4(sp)
wr_loop:
        lw   a0, 4(sp)
        jal  ra, any_pressed
        bnez a0, wr_loop
        lw   ra, 0(sp)
        addi sp, sp, 16
        ret

# clear_screen: a0 = base dos LEDs; apaga as 875 células
clear_screen:
        mv   t0, a0
        li   t1, CELLS
cs_loop:
        sw   zero, 0(t0)
        addi t0, t0, 4
        addi t1, t1, -1
        bnez t1, cs_loop
        ret
