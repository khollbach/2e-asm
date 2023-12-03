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

;     ; expecting ~10 seconds pause
;     ldy #100
; wait_loop
;     jsr bell
;     dey
;     bne wait_loop

    jmp main_loop

halt
    jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; todo: debug bell code...
; see also: https://lateblt.tripod.com/appl2snd.htm
; * they have some good ideas about using a simple
;   timing loop, before we get fancy with `jsr WAIT`.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 0.1 second "bell"
; clobbers a, x
bell
    ; 200 * 500 us = 100 ms = 0.1 s
    ldx #200
bell_loop
    ;bit SPKR ; "click" (toggle) speaker once
    jsr wait_535_us
    dex
    bne bell_loop
    rts

; clobbers: a
wait_535_us
    ; The formula is:
    ; delay_us := (1/2)*(26 + 27a + 5a^2)
    ; If we set a=12, we get 535 us delay.
    lda #12
    jsr WAIT
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
