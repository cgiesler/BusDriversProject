assemblertest:
    add $r0, $r1, $r2
    addi $r3, $r4, 30
    sub $r5, $r6, $r7
    subi $r8, $r9, -30
    rshftl $r10, $r11, 5
    rshfta $r12, $r13, 4
    lshft $r14, $r15, 3
    and $r16, $r17, $r18
    or $r19, $r20, $r21
labeltest:
    not $r22, $r23
    mov $r24, -1
    ld $r25, $r26, 34
    st $r27, $r28, 34
    push $r29
    pop $lr
    b $ilr, $r21, 5
    beq $r21, $r21, 5
    jmp 5
    fun labeltest
    ret
    intr
    nop
    halt
b $r21, $r21, labeltest
beq $r21, $r21, labeltest
jmp labeltest
