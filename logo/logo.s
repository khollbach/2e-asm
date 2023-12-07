; Draw the RC logo.

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
PROMPT equ $33
A1 equ $3c
A2 equ $3e
A4 equ $42
RNDL equ $4e
RNDH equ $4f
BUF equ $0200
; I/O locations
SPKR equ $c030 ; read to toggle
TEXT_OFF equ $c050
TEXT_ON equ $c051
MIXED_OFF equ $c052
MIXED_ON equ $c053
HIRES_OFF equ $c056
HIRES_ON equ $c057

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
;
; NOTE: if/when the main program gets to be more than 4KiB in size, we'll need
; to adjust this code to copy from high-to-low instead. (So we'll probably need
; to write our own memcpy routine.) As-is, the MOVE routine would overwrite the
; part of the data from $6000 onwards before it has a chance to read it.
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
    ;bit MIXED_OFF
    bit MIXED_ON ; todo
    bit TEXT_OFF

    ; clear screen; cursor to bottom
    jsr HOME
    ldx #$28
cursor_end
    jsr CROUT
    dex
    bne cursor_end

    ldy #$00
loop_y
    ldx #$00
; loop_x

    jsr black_screen
    jsr draw_sprite

    tya
    jsr PRNTAX
    jsr IOSAVE
    jsr CROUT
    jsr RDKEY
    jsr IOREST

    ; inx
    ; cpx #$28
    ; bne loop_x

    iny
    cpy #$18
    bne loop_y

halt
    jmp halt

; inputs: x in 0..=38, y in 0..=22 (decimal)
; clobbers nothing
draw_sprite
    ; Draw the quadrants in clockwise order.

    lda #<top_left
    sta A1
    lda #>top_left
    sta A1+1
    jsr draw_quadrant

    inx
    lda #<top_right
    sta A1
    lda #>top_right
    sta A1+1
    jsr draw_quadrant

    iny
    lda #<bottom_right
    sta A1
    lda #>bottom_right
    sta A1+1
    jsr draw_quadrant

    dex
    lda #<bottom_left
    sta A1
    lda #>bottom_left
    sta A1+1
    jsr draw_quadrant

    dey
    rts

; inputs: x in 0..40, y in 0..24, A1 pointing to sprite data
; clobbers nothing
draw_quadrant
    tya
    pha

    jsr base_addr

    ldy #$00
draw_pixel_rows
    lda (A1),y
    sta (A4)

    lda A4+1
    adc #$04
    sta A4+1

    iny
    cpy #$08
    bne draw_pixel_rows

    pla
    tay
    rts

; inputs: x,y
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
sprite
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
