# Mede uma espera com os quatro botoes soltos em RAM.
.equ DELAY, 3000
.equ DIR_UP, 0
.equ DIR_DOWN, 1
.equ DIR_LEFT, 2
.equ DIR_RIGHT, 3
.data
.align 2
test_leds: .zero 3500
test_dpad: .zero 16
.text
main:
li sp, 0x7ffffff0
li a0, 3
li a1, 1
la a2, test_dpad
jal ra, delay_and_poll
li a7, 10
ecall

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
