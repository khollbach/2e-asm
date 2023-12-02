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
RNDL equ $4e
RNDH equ $4f
BUF equ $0200

    org $2000

main
    jsr HOME

    ldy #$0a
main_loop
    jsr hello3
    dey
    bne main_loop

halt
    jmp halt

; Clobbers a and x.
hello3
    ldx #$00
hello3_loop
    lda hello_world,x
    jsr COUT
    inx
    cpx #hello_world_end-hello_world
    bne hello3_loop
    jsr CROUT
    rts

    brk
    brk
    brk

hello_world
    asc "Hello, world!"
hello_world_end

    brk
    brk
    brk
