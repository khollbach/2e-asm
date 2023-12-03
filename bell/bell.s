; Produce a 1000 Hz tone for 0.1 second on keypress.

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
PRTAX equ $f941
SETINV equ $fe80
SETNORM equ $fe84
; Relevant memory locations
CH equ $24
CV equ $25
PROMPT equ $33
RNDL equ $4e
RNDH equ $4f
BUF equ $0200
; I/O locations
SPKR equ $c030 ; read to toggle

    org $2000

main
    jsr HOME
main_loop
    jsr RDKEY
    jsr bell
    jmp main_loop

halt
    jmp halt

bell
    ; 200 iterations.
    ; 200 * 500 us = 100 ms = 0.1 s
    ;ldx #200
    ldx #1 ; TODO
bell_loop
    ;bit SPKR ; "click" (toggle) speaker once
    ; TODO
    jsr wait_500_us
    dex
    bpl bell_loop
    rts

; clobbers: a, $60, $61
wait_500_us
    ; $61a7 = 24,999 -- so 25,000 iterations
    lda #$a7
    sta $60
    lda #$61
    sta $61
wait_500_us_loop
    ; Wait for 20 ns.
    ; 20 ns * 25,000 = 500 us
    lda #$00
    ;jsr WAIT
    ; TODO

    ; Subtract one.
    lda $60
    sec
    sbc #$01
    sta $60
    lda $61
    sbc #$00
    sta $61

    bpl wait_500_us_loop
    rts

    brk
    brk
    brk

ZERO
    hex 00
FF
    hex ff

    brk
    brk
    brk
