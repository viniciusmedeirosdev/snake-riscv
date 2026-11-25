# Compara preparacao isolada e chamada de xy_to_addr.
.text
main:
li sp, 0x7ffffff0
li a0, 7
li a1, 12
li a2, 0x10010000
li a7, 10
ecall
