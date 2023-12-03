; Prompt the user for input.
; Echo the input string in reverse.
; Repeat.

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

    org $2000

main
    jsr HOME
    lda #">"
    sta PROMPT
main_loop
    jsr GETLN
    jsr echo_reverse
    jmp main_loop

halt
    jmp halt

; inputs: x, BUF
; clobbers: a
echo_reverse
    dex
    cpx FF
    beq echo_reverse_end
    lda BUF,x
    jsr COUT
    jmp echo_reverse
echo_reverse_end
    jsr CROUT
    rts

; inputs: x, BUF
; clobbers: a, y
echo
    ldy #$00
    stx $60
echo_loop
    cpy $60
    beq echo_loop_end

    lda BUF,y
    jsr COUT

    iny
    jmp echo_loop
echo_loop_end

    jsr CROUT
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
