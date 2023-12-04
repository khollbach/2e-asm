; Paint the screen a solid color.

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

    jsr checker

    ; todo
    jsr RDKEY
    lda #<queen
    sta A1
    lda #>queen
    sta A1+1
    ldx #$00
    ldy #$00
    jsr draw_pawn_to_coords
    jsr RDKEY
    ldx #$05
    ldy #$07
    jsr draw_pawn_to_coords
    jmp halt

    lda #<pawn
    sta A1
    lda #>pawn
    sta A1+1
    ldy #$01
all_pawns
    ldx #$07
pawn_row
    jsr draw_piece

    ;; TODO
    jmp halt

    dex
    bpl pawn_row
    cpy #$06
    beq done_pawns
    ldy #$06
    jmp all_pawns
done_pawns

    lda #<rook
    sta A1
    lda #>rook
    sta A1+1
    ldy #$00
    ldx #$00
    jsr draw_piece
    ldx #$07
    jsr draw_piece
    ldy #$07
    ldx #$00
    jsr draw_piece
    ldx #$07
    jsr draw_piece

    ; etc ...

halt
    jmp halt

checker
    lda #$00
    sta $60
    lda #$20
    sta $61

draw_all_rows

draw_two_rows ; fill in the blocks on one page
    lda #$ff
    jsr draw_page

    lda $61
    clc
    adc #$04
    sta $61

    cmp #$40
    bmi draw_two_rows

    lda $61
    sec
    sbc #$20
    sta $61

    lda $61
    clc
    adc #$01
    sta $61

    cmp #$24
    bne draw_all_rows

    rts

; inputs: a, $60
; clobbers: y
draw_page ; draw one page (two rows of thin lines)
    ldy #$00
first_row
    sta ($60),y
    iny
    iny
    cpy #$08
    bne first_row

    ldy #$81
second_row
    sta ($60),y
    iny
    iny
    cpy #$89
    bne second_row

    rts

; inputs: piece (A1 = addr of sprite), coords (x,y in 0..=7)
; clobbers ???? (TODO)
draw_piece
    ;todo
    brk

    rts

; notes
; computing the top-left byte of the target square
; * the x offset will be very easy; just add that amount
; * the y offset should be a matter of "multiplying" 0x80 by y
;   (meaning add 0x80 in a loop, y many times)
; and then what?
; * and then do the same loop with +0x0400 8 times to fill in the
;   entire sprite (but keeping track of the loop index, to offset
;   into the sprite data)

; ok. now: computing screen offset
; * ok, now test it

; now: draw *piece* to coords

; maybe we should just clobber all registers?

draw_pawn_to_coords
    ; screen_addr := $2000
    lda #$00
    sta $60
    lda #$20
    sta $61

    ; screen_addr += 0x80 * y
y_offset_loop
    cpy #$00
    beq y_offset_loop_end

    lda $60
    clc
    adc #$80
    sta $60
    lda $61
    adc #$00
    sta $61

    dey
    jmp y_offset_loop
y_offset_loop_end

    ; screen_addr += x
    txa
    clc
    adc $60
    sta $60
    lda $61
    adc #$00
    sta $61

    ldy #$00
draw_loop
    lda (A1),y
    sta ($60)

    ; screen_addr += $0400
    lda $61
    clc
    adc #$04
    sta $61

    iny
    cpy #$08
    bne draw_loop

    rts

black_screen
    lda #$00
    sta $2000
    sta $2001
    jsr fill_screen
    rts

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

    ldy #$00
    jsr MOVE

    rts

    brk
    brk
    brk

ZERO
    hex 00
FF
    hex ff

pawn
    dfb %0_0000000
    dfb %0_0000000
    dfb %0_0000000
    dfb %0_0001000
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0000000

rook
    dfb %0_0000000
    dfb %0_0000000
    dfb %0_0000000
    dfb %0_0010100
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0000000

king
    dfb %0_0000000
    dfb %0_0000000
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0000000

knight
    dfb %0_0000000
    dfb %0_0010000
    dfb %0_0001100
    dfb %0_0001000
    dfb %0_0011000
    dfb %0_0010100
    dfb %0_0000000

queen
    dfb %0_0000000
    dfb %0_0101010
    dfb %0_0011100
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0111110
    dfb %0_0000000

bishop
    dfb %0_0000000
    dfb %0_0001000
    dfb %0_0001000
    dfb %0_0001000
    dfb %0_0011100
    dfb %0_0111110
    dfb %0_0000000

    brk
    brk
    brk
prog_end
