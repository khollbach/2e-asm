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
    bit MIXED_OFF
    bit TEXT_OFF

    ; lda sprite  ; $abcd
    ; ;lda #%0111011
    ; sta $2000
    ; jsr RDKEY
    ; lda sprite+1
    ; sta $2001
    ; jsr RDKEY
    ; lda sprite+2
    ; sta $2400
    ; jsr RDKEY
    ; lda sprite+3
    ; sta $2401
    ; jsr RDKEY

    ; lda #%0_1111110
    ; sta $2000
    ; lda #%0_0111111
    ; sta $2001
    ; lda #%0_0000010
    ; sta $2400
    ; lda #%0_0100000
    ; sta $2401
    ; lda #%0_1111010
    ; sta $2800
    ; lda #%0_0101111
    ; sta $2801
    ; lda #%0_1010010
    ; sta $2c00
    ; lda #%0_0101110
    ; sta $2c01
    ; lda #%0_1111010
    ; sta $3000
    ; lda #%0_0101111
    ; sta $3001
    ; lda #%0_1001010
    ; sta $3400
    ; lda #%0_0101100
    ; sta $3401
    ; lda #%0_1111010
    ; sta $3800
    ; lda #%0_0101111
    ; sta $3801
    ; lda #%0_1111010
    ; sta $3c00
    ; lda #%0_0101111
    ; sta $3c01
    ; lda #%0_0000010
    ; sta $2080
    ; lda #%0_0100000
    ; sta $2081
    ; lda #%0_1111110
    ; sta $2480
    ; lda #%0_0111111
    ; sta $2481
    ; lda #%0_1100000
    ; sta $2880
    ; lda #%0_0000011
    ; sta $2881
    ; lda #%0_1111100
    ; sta $2c80
    ; lda #%0_0011111
    ; sta $2c81
    ; lda #%0_0101110
    ; sta $3080
    ; lda #%0_0110101
    ; sta $3081
    ; lda #%0_1010110
    ; sta $3480
    ; lda #%0_0111010
    ; sta $3481
    ; lda #%0_1111110
    ; sta $3880
    ; lda #%0_0111111
    ; sta $3881
    ; lda #%0_0000000
    ; sta $3c80
    ; lda #%0_0000000
    ; sta $3c81

    ; lda #%0_1111110
    ; sta $2387
    ; lda #%0_0111111
    ; sta $2388
    ; lda #%0_0000010
    ; sta $2787
    ; lda #%0_0100000
    ; sta $2788
    ; lda #%0_1111010
    ; sta $2b87
    ; lda #%0_0101111
    ; sta $2b88
    ; lda #%0_1010010
    ; sta $2f87
    ; lda #%0_0101110
    ; sta $2f88
    ; lda #%0_1111010
    ; sta $3387
    ; lda #%0_0101111
    ; sta $3388
    ; lda #%0_1001010
    ; sta $3787
    ; lda #%0_0101100
    ; sta $3788
    ; lda #%0_1111010
    ; sta $3b87
    ; lda #%0_0101111
    ; sta $3b88
    ; lda #%0_1111010
    ; sta $3f87
    ; lda #%0_0101111
    ; sta $3f88
    ; lda #%0_0000010
    ; sta $202f
    ; lda #%0_0100000
    ; sta $2030
    ; lda #%0_1111110
    ; sta $242f
    ; lda #%0_0111111
    ; sta $2430
    ; lda #%0_1100000
    ; sta $282f
    ; lda #%0_0000011
    ; sta $2830
    ; lda #%0_1111100
    ; sta $2c2f
    ; lda #%0_0011111
    ; sta $2c30
    ; lda #%0_0101110
    ; sta $302f
    ; lda #%0_0110101
    ; sta $3030
    ; lda #%0_1010110
    ; sta $342f
    ; lda #%0_0111010
    ; sta $3430
    ; lda #%0_1111110
    ; sta $382f
    ; lda #%0_0111111
    ; sta $3830
    ; lda #%0_0000000
    ; sta $3c2f
    ; lda #%0_0000000
    ; sta $3c30

    lda #%0_1111110
    sta $2000
    lda #%0_0111111
    sta $2001
    lda #%0_0000010
    sta $2400
    lda #%0_0100000
    sta $2401
    lda #%0_1111010
    sta $2800
    lda #%0_0101111
    sta $2801
    lda #%0_1010010
    sta $2c00
    lda #%0_0101110
    sta $2c01
    lda #%0_1111010
    sta $3000
    lda #%0_0101111
    sta $3001
    lda #%0_1001010
    sta $3400
    lda #%0_0101100
    sta $3401
    lda #%0_1111010
    sta $3800
    lda #%0_0101111
    sta $3801
    lda #%0_1111010
    sta $3c00
    lda #%0_0101111
    sta $3c01
    lda #%0_0000010
    sta $2080
    lda #%0_0100000
    sta $2081
    lda #%0_1111110
    sta $2480
    lda #%0_0111111
    sta $2481
    lda #%0_1100000
    sta $2880
    lda #%0_0000011
    sta $2881
    lda #%0_1111100
    sta $2c80
    lda #%0_0011111
    sta $2c81
    lda #%0_0101110
    sta $3080
    lda #%0_0110101
    sta $3081
    lda #%0_1010110
    sta $3480
    lda #%0_0111010
    sta $3481
    lda #%0_1111110
    sta $3880
    lda #%0_0111111
    sta $3881
    lda #%0_0000000
    sta $3c80
    lda #%0_0000000
    sta $3c81
    lda #%0_1111110
    sta $2002
    lda #%0_0111111
    sta $2003
    lda #%0_0000010
    sta $2402
    lda #%0_0100000
    sta $2403
    lda #%0_1111010
    sta $2802
    lda #%0_0101111
    sta $2803
    lda #%0_1010010
    sta $2c02
    lda #%0_0101110
    sta $2c03
    lda #%0_1111010
    sta $3002
    lda #%0_0101111
    sta $3003
    lda #%0_1001010
    sta $3402
    lda #%0_0101100
    sta $3403
    lda #%0_1111010
    sta $3802
    lda #%0_0101111
    sta $3803
    lda #%0_1111010
    sta $3c02
    lda #%0_0101111
    sta $3c03
    lda #%0_0000010
    sta $2082
    lda #%0_0100000
    sta $2083
    lda #%0_1111110
    sta $2482
    lda #%0_0111111
    sta $2483
    lda #%0_1100000
    sta $2882
    lda #%0_0000011
    sta $2883
    lda #%0_1111100
    sta $2c82
    lda #%0_0011111
    sta $2c83
    lda #%0_0101110
    sta $3082
    lda #%0_0110101
    sta $3083
    lda #%0_1010110
    sta $3482
    lda #%0_0111010
    sta $3483
    lda #%0_1111110
    sta $3882
    lda #%0_0111111
    sta $3883
    lda #%0_0000000
    sta $3c82
    lda #%0_0000000
    sta $3c83
    lda #%0_1111110
    sta $2004
    lda #%0_0111111
    sta $2005
    lda #%0_0000010
    sta $2404
    lda #%0_0100000
    sta $2405
    lda #%0_1111010
    sta $2804
    lda #%0_0101111
    sta $2805
    lda #%0_1010010
    sta $2c04
    lda #%0_0101110
    sta $2c05
    lda #%0_1111010
    sta $3004
    lda #%0_0101111
    sta $3005
    lda #%0_1001010
    sta $3404
    lda #%0_0101100
    sta $3405
    lda #%0_1111010
    sta $3804
    lda #%0_0101111
    sta $3805
    lda #%0_1111010
    sta $3c04
    lda #%0_0101111
    sta $3c05
    lda #%0_0000010
    sta $2084
    lda #%0_0100000
    sta $2085
    lda #%0_1111110
    sta $2484
    lda #%0_0111111
    sta $2485
    lda #%0_1100000
    sta $2884
    lda #%0_0000011
    sta $2885
    lda #%0_1111100
    sta $2c84
    lda #%0_0011111
    sta $2c85
    lda #%0_0101110
    sta $3084
    lda #%0_0110101
    sta $3085
    lda #%0_1010110
    sta $3484
    lda #%0_0111010
    sta $3485
    lda #%0_1111110
    sta $3884
    lda #%0_0111111
    sta $3885
    lda #%0_0000000
    sta $3c84
    lda #%0_0000000
    sta $3c85
    lda #%0_1111110
    sta $2100
    lda #%0_0111111
    sta $2101
    lda #%0_0000010
    sta $2500
    lda #%0_0100000
    sta $2501
    lda #%0_1111010
    sta $2900
    lda #%0_0101111
    sta $2901
    lda #%0_1010010
    sta $2d00
    lda #%0_0101110
    sta $2d01
    lda #%0_1111010
    sta $3100
    lda #%0_0101111
    sta $3101
    lda #%0_1001010
    sta $3500
    lda #%0_0101100
    sta $3501
    lda #%0_1111010
    sta $3900
    lda #%0_0101111
    sta $3901
    lda #%0_1111010
    sta $3d00
    lda #%0_0101111
    sta $3d01
    lda #%0_0000010
    sta $2180
    lda #%0_0100000
    sta $2181
    lda #%0_1111110
    sta $2580
    lda #%0_0111111
    sta $2581
    lda #%0_1100000
    sta $2980
    lda #%0_0000011
    sta $2981
    lda #%0_1111100
    sta $2d80
    lda #%0_0011111
    sta $2d81
    lda #%0_0101110
    sta $3180
    lda #%0_0110101
    sta $3181
    lda #%0_1010110
    sta $3580
    lda #%0_0111010
    sta $3581
    lda #%0_1111110
    sta $3980
    lda #%0_0111111
    sta $3981
    lda #%0_0000000
    sta $3d80
    lda #%0_0000000
    sta $3d81
    lda #%0_1111110
    sta $2102
    lda #%0_0111111
    sta $2103
    lda #%0_0000010
    sta $2502
    lda #%0_0100000
    sta $2503
    lda #%0_1111010
    sta $2902
    lda #%0_0101111
    sta $2903
    lda #%0_1010010
    sta $2d02
    lda #%0_0101110
    sta $2d03
    lda #%0_1111010
    sta $3102
    lda #%0_0101111
    sta $3103
    lda #%0_1001010
    sta $3502
    lda #%0_0101100
    sta $3503
    lda #%0_1111010
    sta $3902
    lda #%0_0101111
    sta $3903
    lda #%0_1111010
    sta $3d02
    lda #%0_0101111
    sta $3d03
    lda #%0_0000010
    sta $2182
    lda #%0_0100000
    sta $2183
    lda #%0_1111110
    sta $2582
    lda #%0_0111111
    sta $2583
    lda #%0_1100000
    sta $2982
    lda #%0_0000011
    sta $2983
    lda #%0_1111100
    sta $2d82
    lda #%0_0011111
    sta $2d83
    lda #%0_0101110
    sta $3182
    lda #%0_0110101
    sta $3183
    lda #%0_1010110
    sta $3582
    lda #%0_0111010
    sta $3583
    lda #%0_1111110
    sta $3982
    lda #%0_0111111
    sta $3983
    lda #%0_0000000
    sta $3d82
    lda #%0_0000000
    sta $3d83
    lda #%0_1111110
    sta $2104
    lda #%0_0111111
    sta $2105
    lda #%0_0000010
    sta $2504
    lda #%0_0100000
    sta $2505
    lda #%0_1111010
    sta $2904
    lda #%0_0101111
    sta $2905
    lda #%0_1010010
    sta $2d04
    lda #%0_0101110
    sta $2d05
    lda #%0_1111010
    sta $3104
    lda #%0_0101111
    sta $3105
    lda #%0_1001010
    sta $3504
    lda #%0_0101100
    sta $3505
    lda #%0_1111010
    sta $3904
    lda #%0_0101111
    sta $3905
    lda #%0_1111010
    sta $3d04
    lda #%0_0101111
    sta $3d05
    lda #%0_0000010
    sta $2184
    lda #%0_0100000
    sta $2185
    lda #%0_1111110
    sta $2584
    lda #%0_0111111
    sta $2585
    lda #%0_1100000
    sta $2984
    lda #%0_0000011
    sta $2985
    lda #%0_1111100
    sta $2d84
    lda #%0_0011111
    sta $2d85
    lda #%0_0101110
    sta $3184
    lda #%0_0110101
    sta $3185
    lda #%0_1010110
    sta $3584
    lda #%0_0111010
    sta $3585
    lda #%0_1111110
    sta $3984
    lda #%0_0111111
    sta $3985
    lda #%0_0000000
    sta $3d84
    lda #%0_0000000
    sta $3d85

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

; (note that the last 7 bits are in reverse order)
sprite
    dfb %0_1111110, %0_0111111
    dfb %0_0000010, %0_0100000
    dfb %0_1111010, %0_0101111
    dfb %0_1010010, %0_0101110
    dfb %0_1111010, %0_0101111
    dfb %0_1001010, %0_0101100
    dfb %0_1111010, %0_0101111
    dfb %0_1111010, %0_0101111
    dfb %0_0000010, %0_0100000
    dfb %0_1111110, %0_0111111
    dfb %0_1100000, %0_0000011
    dfb %0_1111100, %0_0011111
    dfb %0_0101110, %0_0110101
    dfb %0_1010110, %0_0111010
    dfb %0_1111110, %0_0111111
    dfb %0_0000000, %0_0000000

    brk
    brk
    brk
prog_end
