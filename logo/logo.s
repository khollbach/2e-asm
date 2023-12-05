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

    brk ; todo

halt
    jmp halt

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

sprite
    dfb %0_0111111, %0_1111110
    dfb %0_0100000, %0_0000010
    dfb %0_0101111, %0_1111010
    dfb %0_0100101, %0_0111010
    dfb %0_0101111, %0_1111010
    dfb %0_0101001, %0_0011010
    dfb %0_0101111, %0_1111010
    dfb %0_0101111, %0_1111010
    dfb %0_0100000, %0_0000010
    dfb %0_0111111, %0_1111110
    dfb %0_0000011, %0_1100000
    dfb %0_0011111, %0_1111100
    dfb %0_0111010, %0_1010110
    dfb %0_0110101, %0_0101110
    dfb %0_0111111, %0_1111110
    dfb %0_0000000, %0_0000000

    brk
    brk
    brk
prog_end
