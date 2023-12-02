; Print "Hello, world!" to the screen

    org $2000

main
    jsr clear_screen
    jsr hello2
    ;brk

halt
    jmp halt

hello2
    ldx #$00
hello2_loop
    lda hello_world,x
    sta $0400,x
    inx
    cpx #hello_world_end-hello_world
    bne hello2_loop
    rts

hello1
    lda #"H"
    sta $400
    lda #"e"
    sta $401
    lda #"l"
    sta $402
    lda #"l"
    sta $403
    lda #"o"
    sta $404
    ;lda #","
    lda #$ac
    sta $405
    lda #" "
    sta $406
    lda #"w"
    sta $407
    lda #"o"
    sta $408
    lda #"r"
    sta $409
    lda #"l"
    sta $40a
    lda #"d"
    sta $40b
    lda #"!"
    sta $40c
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

hello_world
    asc "Hello, world! (one more time!)"
hello_world_end

    brk
    brk
    brk
