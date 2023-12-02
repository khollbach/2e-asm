; "hello-world" program: load two 16-bit values, add them, store their sum
; INPUTS: $600 and $602
; OUTPUT: $680

SET R1, $600
LD @R1
ST R1

SET R0, $602
LD @R0
ADD R1

SET R1, $680
ST @R1

