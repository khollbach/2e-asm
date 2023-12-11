; High-graphics mode experiments.

; Built-in (ROM) subroutines
COUT equ $fded
CROUT equ $fd8e
GETLN equ $fd6a
RDKEY equ $fd0c
IOSAVE equ $ff4a
IOREST equ $ff3f
MOVE equ $fe2c
READ equ $fefd
WRITE equ $fecd
WAIT equ $fca8
BELL equ $ff3a
HOME equ $fc58
PRBLNK equ $f948
PRBL2 equ $f94a
PRHEX equ $fde3
PRBYTE equ $fdda
PRNTAX equ $f941
SETINV equ $fe80
SETNORM equ $fe84
; Relevant memory locations
CH equ $24
CV equ $25
INVFLAG equ $32
PROMPT equ $33
A1 equ $3c
A2 equ $3e
A4 equ $42
RNDL equ $4e
RNDH equ $4f
BUF equ $0200
; I/O locations
KBD equ $c000 ; high bit indicates if there's pending input
SPKR equ $c030 ; read to toggle
TEXT_OFF equ $c050
TEXT_ON equ $c051
MIXED_OFF equ $c052
MIXED_ON equ $c053
PAGE2_OFF equ $c054
PAGE2_ON equ $c055
HIRES_OFF equ $c056
HIRES_ON equ $c057

; Global variables.
rng_state equ $fe
flag_bit equ $ff
mega_sprite equ $bf00

; This is a terrible hack.
;
; We put a tiny bit of code at $2000, where prodos loads our program into
; memory. This code copies the actual program (`main` through `prog_end`) to
; $6000, and then jumps to it.
;
; Note that merlin32 doesn't put any padding between these two sections. So the
; "bootstrapping" code gets loaded at $2000, and the real program gets loaded at
; like $20ab, before being copied to $6000. But the second `org` command *does*
; ensure that the main code has correct the jump addresses for being loaded and
; run starting at $6000.
    org $2000

    ; dest: $6000
    lda #$00
    sta A4
    lda #$60
    sta A4+1

    ; src: main
    lda #<actual_main
    sta A1
    lda #>actual_main
    sta A1+1

    ; end: prog_end-1
    lda #<actual_prog_end_minus_one
    sta A2
    lda #>actual_prog_end_minus_one
    sta A2+1

    ldy #$00
    jsr MOVE

    jmp $6000

prog_len equ prog_end - main
actual_prog_end equ actual_main + prog_len
actual_prog_end_minus_one equ actual_prog_end - 1

; This is the address of `main` *before* it gets MOVEd to $6000.
actual_main

    org $6000

main
    jsr black_screen
    bit HIRES_ON
    bit MIXED_OFF
    bit TEXT_OFF

    jsr draw_something

halt
    jmp halt

; todo
draw_something
    ldy #$00
    ldx #$00

    lda #$00
    sta A2

    ; TODO: generate sprite data from a script, and copy it in
    ; Then write a small snippet of asm code to copy mega_sprite_data into mega_sprite

    ; lda #<msprite_0
    ; sta A1
    ; lda #>msprite_0
    ; sta A1+1
    ; jsr draw_tile

    ; inx
    ; lda #<msprite_1
    ; sta A1
    ; lda #>msprite_1
    ; sta A1+1
    ; jsr draw_tile

    rts

; inputs: x in 0..40, y in 0..24
;   A1 pointing to sprite data
;   A2 (#$00 or #$20 for Page1 or Page2)
; clobbers: A4
draw_tile
    tya
    pha

    jsr base_addr

    ldy #$00
draw_pixel_rows
    lda (A1),y
    sta (A4)

    clc
    lda A4+1
    adc #$04
    sta A4+1

    iny
    cpy #$08
    bne draw_pixel_rows

    pla
    tay
    rts

; inputs: x in 0..40, y in 0..24
;   A2 (#$00 or #$20 for Page1 or Page2)
; clobbers: a
; output: A4
base_addr
    ; Which band? (0, 1, or 2)
    tya
    lsr a ; shift right three times (i.e. divide by 8)
    lsr a
    lsr a
    sta $60

    ; Which block within the band? (0..=7)
    tya
    and #$08-1 ; keep lowest three bits (i.e. y modulo 8)
    sta $61

    ; Compute band offset; store in $60.
    ; Multiplication is done by iterated addition.
    lda #$00
    clc
band_offset_loop
    dec $60
    bmi band_offset_loop_end
    adc #$28
    jmp band_offset_loop
band_offset_loop_end
    sta $60

    ; Compute block offset; store in $61,$62.
    ; Multiplying by $80 is kind of like dividing by 2.
    lda $61
    ror a ; carry input is still clear from above
    sta $62
    ; "underflow" the carry output into the low byte
    lda #$00
    ror a
    sta $61

    ; base_addr := $2000 + band_offset + block_offset + x
    ; low byte (which can't overflow in this case)
    lda $60
    adc $61
    stx $60
    adc $60
    sta A4
    ; high byte
    lda #$20
    adc $62
    adc A2 ; Optionally +$2000 for Page 2.
    sta A4+1

    rts

; clobbers: a
black_screen
    lda #$00
    sta $2000
    sta $2001
    jsr fill_screen
    rts

; clobbers nothing
fill_screen
    ; dest: $2002
    lda #$02
    sta A4
    lda #$20
    sta A4+1

    ; src: $2000
    lda #$00
    sta A1
    lda #$20
    sta A1+1

    ; end: $3ffd
    lda #$fd
    sta A2
    lda #$3f
    sta A2+1

    jsr IOSAVE
    jsr IOREST
    ldy #$00
    jsr MOVE
    jsr IOREST
    rts

    brk
    brk
    brk

ZERO
    hex 00
FF
    hex ff

; Note that the bits are "reversed" in the sprite data. This is because the
; constant values are written down in msb-first order, but the Apple II display
; memory mapping uses lsb-first order.
sprite_quadrants
top_left
    dfb %0_1111110
    dfb %0_0000010
    dfb %0_1111010
    dfb %0_1010010
    dfb %0_1111010
    dfb %0_1001010
    dfb %0_1111010
    dfb %0_1111010
top_right
    dfb %0_0111111
    dfb %0_0100000
    dfb %0_0101111
    dfb %0_0101110
    dfb %0_0101111
    dfb %0_0101100
    dfb %0_0101111
    dfb %0_0101111
bottom_left
    dfb %0_0000010
    dfb %0_1111110
    dfb %0_1100000
    dfb %0_1111100
    dfb %0_0101110
    dfb %0_1010110
    dfb %0_1111110
    dfb %0_0000000
bottom_right
    dfb %0_0100000
    dfb %0_0111111
    dfb %0_0000011
    dfb %0_0011111
    dfb %0_0110101
    dfb %0_0111010
    dfb %0_0111111
    dfb %0_0000000

    brk
    brk
    brk
prog_end
