        .text
        .attribute      4, 16
        .attribute      5, "rv32i2p1"
        .file   "example.c"
        .globl  main
        .p2align        2
        .type   main,@function
main:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        sw      s1, 52(sp)
        sw      s2, 48(sp)
        sw      s3, 44(sp)
        sw      s4, 40(sp)
        sw      s5, 36(sp)
        sw      s6, 32(sp)
        sw      s7, 28(sp)
        sw      s8, 24(sp)
        sw      s9, 20(sp)
        sw      s10, 16(sp)
        sw      s11, 12(sp)
        li      a0, 875
        lui     a1, 983040
.LBB0_1:
        sw      zero, 0(a1)
        addi    a0, a0, -1
        addi    a1, a1, 4
        bnez    a0, .LBB0_1
        lui     a0, 983041
        lw      a1, -596(a0)
        lw      a2, -592(a0)
        lw      a3, -588(a0)
        lw      a4, -584(a0)
        or      a2, a2, a1
        lui     s0, %hi(rng)
        lw      a1, %lo(rng)(s0)
        or      a3, a3, a4
        or      a2, a2, a3
        bnez    a2, .LBB0_4
.LBB0_3:
        addi    a1, a1, 1
        sw      a1, %lo(rng)(s0)
        lw      a2, -596(a0)
        lw      a3, -592(a0)
        lw      a4, -588(a0)
        lw      a5, -584(a0)
        or      a2, a3, a2
        or      a4, a4, a5
        or      a2, a2, a4
        beqz    a2, .LBB0_3
.LBB0_4:
        ori     a0, a1, 1
        sw      a0, %lo(rng)(s0)
        lui     a0, %hi(body)
        lui     s1, 983040
        addi    a1, s1, 1700
        sw      a1, %lo(body)(a0)
        addi    a0, a0, %lo(body)
        lui     a1, 12
        sw      a1, 1700(s1)
        addi    a2, s1, 1704
        sw      a2, 4(a0)
        sw      a1, 1704(s1)
        addi    a2, s1, 1708
        sw      a2, 8(a0)
        sw      a1, 1708(s1)
        lui     a0, 4096
        addi    a0, a0, -256
        sw      a0, 1708(s1)
        lw      s2, %lo(rng)(s0)
.LBB0_5:
        slli    a0, s2, 13
        xor     a0, a0, s2
        srli    a1, a0, 17
        xor     a0, a1, a0
        slli    a1, a0, 5
        xor     s2, a1, a0
        andi    s3, s2, 63
        slli    a0, s2, 19
        srli    a0, a0, 27
        sltiu   a1, s3, 35
        sltiu   a2, a0, 25
        and     a1, a1, a2
        sw      s2, %lo(rng)(s0)
        beqz    a1, .LBB0_5
        li      a1, 35
        call    __mulsi3@plt
        add     a0, a0, s3
        slli    a0, a0, 2
        or      a0, a0, s1
        lw      a1, 0(a0)
        bnez    a1, .LBB0_5
        sw      zero, 4(sp)
        li      s3, 0
        li      s5, 7
        li      s1, 12
        li      s2, 2
        li      s6, 3
        lui     a1, 983040
        addi    s4, a1, 1708
        lui     s11, 4080
        lui     s7, 983041
        lui     a1, %hi(body)
        addi    s9, a1, %lo(body)
        lui     a1, 4096
        addi    a1, a1, -256
        sw      a1, 8(sp)
        li      s8, 3
.LBB0_8:
        sw      s11, 0(a0)
        j       .LBB0_11
.LBB0_9:
        mv      s0, s6
.LBB0_10:
        lui     a0, 12
        sw      a0, 0(s11)
        addi    a0, s2, 1
        li      a1, 875
        call    __modsi3@plt
        mv      s2, a0
        slli    a0, a0, 2
        add     a0, s9, a0
        sw      s4, 0(a0)
        lw      a0, 8(sp)
        sw      a0, 0(s4)
        addi    s6, s0, 1
        lui     s11, 4080
        beq     s10, s11, .LBB0_23
.LBB0_11:
        lui     s0, 4080
        mv      a0, s8
        mv      s11, s4
        li      a1, 1000
        j       .LBB0_13
.LBB0_12:
        addi    a1, a1, -1
        beqz    a1, .LBB0_19
.LBB0_13:
        lw      a3, -596(s7)
        lw      a2, -592(s7)
        snez    a4, a0
        snez    a2, a2
        and     a4, a2, a4
        li      a2, 1
        bnez    a4, .LBB0_15
        addi    a2, a0, -1
        snez    a2, a2
        snez    a3, a3
        and     a2, a3, a2
        addi    a2, a2, -1
        and     a2, a2, s8
.LBB0_15:
        lw      a3, -588(s7)
        addi    a4, a0, -3
        snez    a4, a4
        snez    a3, a3
        and     a4, a3, a4
        li      a3, 2
        bnez    a4, .LBB0_17
        mv      a3, a2
.LBB0_17:
        lw      a2, -584(s7)
        addi    a4, a0, -2
        snez    a4, a4
        snez    a2, a2
        and     a2, a2, a4
        li      s8, 3
        bnez    a2, .LBB0_12
        mv      s8, a3
        j       .LBB0_12
.LBB0_19:
        addi    a0, s8, -3
        seqz    a0, a0
        add     a0, s5, a0
        addi    a1, s8, -2
        seqz    a1, a1
        sub     s5, a0, a1
        addi    a0, s8, -1
        seqz    a0, a0
        seqz    a1, s8
        sub     s1, s1, a1
        add     s1, s1, a0
        sltiu   a0, s5, 35
        sltiu   a1, s1, 25
        and     a0, a0, a1
        beqz    a0, .LBB0_27
        li      a1, 35
        mv      a0, s1
        call    __mulsi3@plt
        add     a0, a0, s5
        slli    a0, a0, 2
        lui     s4, 983040
        add     s4, a0, s4
        lw      s10, 0(s4)
        beq     s10, s0, .LBB0_9
        slli    a0, s3, 2
        add     a0, s9, a0
        lw      a0, 0(a0)
        sw      zero, 0(a0)
        addi    a0, s3, 1
        li      a1, 875
        call    __modsi3@plt
        lw      a1, 0(s4)
        bnez    a1, .LBB0_27
        mv      s3, a0
        addi    s0, s6, -1
        j       .LBB0_10
.LBB0_23:
        lw      a0, 4(sp)
        addi    a0, a0, 1
        li      a1, 873
        blt     a1, s0, .LBB0_28
        sw      a0, 4(sp)
        lui     a0, %hi(rng)
        lw      s0, %lo(rng)(a0)
.LBB0_25:
        slli    a0, s0, 13
        xor     a0, a0, s0
        srli    a1, a0, 17
        xor     a0, a1, a0
        slli    s0, a0, 5
        xor     s0, s0, a0
        andi    s10, s0, 63
        slli    a0, s0, 19
        srli    a0, a0, 27
        sltiu   a1, s10, 35
        sltiu   a2, a0, 25
        and     a1, a1, a2
        lui     a2, %hi(rng)
        sw      s0, %lo(rng)(a2)
        beqz    a1, .LBB0_25
        li      a1, 35
        call    __mulsi3@plt
        add     a0, a0, s10
        slli    a0, a0, 2
        lui     a1, 983040
        or      a0, a0, a1
        lw      a1, 0(a0)
        bnez    a1, .LBB0_25
        j       .LBB0_8
.LBB0_27:
        lw      a0, 4(sp)
.LBB0_28:
        lw      ra, 60(sp)
        lw      s0, 56(sp)
        lw      s1, 52(sp)
        lw      s2, 48(sp)
        lw      s3, 44(sp)
        lw      s4, 40(sp)
        lw      s5, 36(sp)
        lw      s6, 32(sp)
        lw      s7, 28(sp)
        lw      s8, 24(sp)
        lw      s9, 20(sp)
        lw      s10, 16(sp)
        lw      s11, 12(sp)
        addi    sp, sp, 64
        ret
.Lfunc_end0:
        .size   main, .Lfunc_end0-main

        .type   rng,@object
        .section        .sdata,"aw",@progbits
        .p2align        2
rng:
        .word   1
        .size   rng, 4

        .type   body,@object
        .local  body
        .comm   body,3500,4
        .ident  "clang version 17.0.1 (https://github.com/llvm/llvm-project.git e19b7dc36bc047b9eb72078d034596be766da350)"
        .section        ".note.GNU-stack","",@progbits
        .addrsig
