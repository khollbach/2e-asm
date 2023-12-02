; "hello-world" asm program
; draw some pixels to the screen

    org $2000

main
    jsr clear_screen
    jsr ascii_table
halt
    jmp halt
    ;jsr draw_square
    brk

draw_square
    lda #$bf
    sta $600
    sta $601
    sta $680
    sta $681
    rts

ascii_table
    ; set up $60 to point to $0400
    lda #$00
    sta $60
    lda #$04
    sta $61

    ; limit for `row` loop
    lda #$10
    sta $62

    lda #$00
top_half
    ldy #$00
row
    sta ($60),y
    clc
    adc #$01

    iny
    cpy $62
    bne row

    ; add $80 to $60,$61
    pha
    lda #$80
    clc
    adc $60
    sta $60

    lda #$00
    adc $61
    sta $61

    lda #05
    cmp $61
    pla
    bne top_half

    rts

; write " " to $400..$800
clear_screen
    ; set up $60 to point to $0400
    lda #$00
    sta $60
    lda #$04
    sta $61

outer_loop
    lda #" "
    ldy #$00
inner_loop ; clear one page of memory
    sta ($60),y
    iny
    bne inner_loop

    inc $61
    lda #$08
    cmp $61
    bne outer_loop

    rts

    brk
    brk
    brk
