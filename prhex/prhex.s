; Print values as hexadecimal digits.

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
    lda #$b
    jsr prhex
    lda #$a
    jsr prhex
    lda #$5
    jsr prhex
    lda #$1
    jsr prhex
    lda #$c
    jsr prhex

halt
    jmp halt

; inputs: a
; clobbers: a, x
prhex
    and #$0f ; mask just low nibble
    tax
    lda hex_digits,x
    jsr COUT
    rts

    brk
    brk
    brk

hex_digits
    asc "0123456789abcdef"
ZERO
    hex 00
FF
    hex ff

    brk
    brk
    brk
