# Compara preparacao isolada e chamada de xy_to_addr.
.text
main:
li sp, 0x7ffffff0
li a0, 7
li a1, 12
li a2, 0x10010000
jal ra, xy_to_addr
li a7, 10
ecall

xy_to_addr:
        slli t0, a1, 5
        slli t1, a1, 1
        add  t0, t0, t1
        add  t0, t0, a1
        add  t0, t0, a0
        slli t0, t0, 2
        add  a0, a2, t0
        ret
