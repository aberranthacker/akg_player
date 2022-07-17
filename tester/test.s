                .nolist

                .TITLE AKG Player Test

                .include "../macros.s"
                .include "../hwdefs.s"

                .global PPDONE

                .=040; .word start   # program’s relative start address
                .=042; .word 01000   # initial location of stack pointer
                .=050; .word end - 2 # address of the program’s highest word

# Locations 360–377 are the CCB and are are restricted for use by the system.
# The Linker stores the program memory usage bits in these eight words, which
# are called a bitmap.
# Each bit represents one 256-word block of memory and is set if the program
# occupies any part of that block of memory:
#     bit 7 of byte 360 corresponds to locations    0 through  777,
#     bit 6 of byte 360 corresponds to locations 1000 through 1777,
#     and so on.
# The monitor uses this information when it loads the program.
                .=0360
                .byte 0b11111111 #  8
                .byte 0b11111111 # 16
                .byte 0b11111111 # 24
                .byte 0b11111110 # 32
                .byte 0b00000000 # 40
                #       76543210
                .=01000

                .equiv PPUModuleSizeWords, (PPUModuleEnd - PPUModuleStart) >> 1

start:
        MOV  $PPUModuleStart,R4
        MOV  $PPUModuleSizeWords,R5

        MOV  R5,@$PS.A2        # Arg 2 - memory size, words
        MOVB $01,@$PS.Request  # 01 - allocate memory
        CALL PPUOut            # => Send request to PPU
                               # PS.A1 now contains address of allocated area
        MOV  @$PS.A1,@$PPUAllocAddr
        MOV  R4,@$PS.A2        # Arg 2 - addr of mem block in CPUs RAM
        MOV  R5,@$PS.A3        # Arg 3 - size of mem block, words
        MOVB $020,@$PS.Request # 020 - CPU to PPU memory copy
        CALL PPUOut            # => Send request to PPU
                               #
        MOVB $030,@$PS.Request # 030 - Execute programm
        CALL PPUOut            # => Send request to PPU

1$:     TST  @$PPDONE
        BMI  1$

       .exit

PPDONE: .word -1

PPUOut:         #------------------------------------------------------------{{{
        MOV  $AMP,R0        # R0 - pointer to channel's init sequence array
        MOV  $8,R1          # R1 - size of the array, 8 bytes
1$:     MOVB (R0)+,@$CCH2OD # Send a byte to channel 2

2$:     TSTB @$CCH2OS       #
        BPL  2$             # Wait until channel is ready

        SOB  R1,1$          # Next byte

        TSTB PS.Reply       # Test PPU's operation status code
        RETURN              #

AMP:   .byte  0, 0, 0, 0xFF # init sequence
       .word  PStruct       # address of parameters struct
       .byte  0xFF, 0xFF    # two termination bytes 0xff, 0xff

PStruct:    # Parameters struct (PS)
    PS.Reply:   .byte  0   # operation status code
    PS.Request: .byte  1   # request code
                           # 01 - allocate memory
                           # 02 - free memory
                           # 010 - mem copy PPU -> CPU
                           # 020 - mem copy CPU -> PPU
                           # 030 - execute
    PS.Type:    .byte  032 # device type - PPU RAM
    PS.No:      .byte  0   # device number
    PS.A1:      .word  0   # Argument 1
    PS.A2:      .word  0   # Argument 2
    PS.A3:      .word  0   # Argument 3

        .even
#----------------------------------------------------------------------------}}}

        .=023666

PPUModuleStart:
        MOV  $0177400,R1
        MOV  @$4,@$DefaultTrap4Handler
        MOV  $Trap4,@$4
      # Aberrant Sound Module uses addresses range 0177360-0177377
      # 16 addresses in total and 8 even addresses
        MOV  $8,R0
        TestNextSoundBoardAddress:
            TST  -(R1)
        SOB  R0,TestNextSoundBoardAddress

        TST  @$Trap4Detected
        BZE  PSGPresent

        MOV  $DummyPSG,R1
PSGPresent:
        MOV  R1,@$PLY_AKG_PSGAddress
        CLR  @$Trap4Detected
       .equiv DefaultTrap4Handler, .+2
        MOV  $0173362,@$4

        CLR  R0 # Subsong0
        MOV  $song, R5
        CALL PLY_AKG_Init
        MOV  $sound_effects, R5
        CALL PLY_AKG_InitSoundEffects

        100$:
            CALL PLY_AKG_Play
            WAIT

           .equiv VblanksCounter, .+2
            INC  $0
            CLR  R0
            MOV  @$VblanksCounter,R1
            DIV  $50,R0
            TST  R1
        BNE 100$

           .equiv PlaysCounter, .+2
            INC  $0
            CLR  R0                # most significant word
            MOV  @$PlaysCounter,R1 # least significant word
            DIV  $5,R0
            MOV  R1,R0             # remainder is sound effect number
            INC  R0                # sound effect number starts from 1

            CLR  R2                # most significant word
            MOV  @$PlaysCounter,R3 # least significat word
            DIV  $3,R2
            MOV  R3,R1             # remainder is channels number

            CLR  R2
            MOV  @$PlaysCounter,R3
            DIV  $17,R2
            MOV  R3,R2             # inverted volume, 0=full volume, 16=no sound

           #MOV  $3,R0
           #MOV  $0,R1
           #MOV  $0,R2
            CALL PLY_AKG_PlaySoundEffect
        BR  100$

       .include "a_harmless_grenade_playerconfig.s"
       #SkipPSGSend = 1
        PLY_AKG_MANAGE_SOUND_EFFECTS = 1
       .include "akg_player.s"
song:
       .include "a_harmless_grenade.s"
       .even
sound_effects:
       .include "sound_effects.s"
       .even

        MOV  $PPU_PPDONE,@$PBPADR
        CLR  @$PBP12D

        MOV  PC,R1
        ADD  $PPUAllocAddr-.,R1
        MOV  (R1),R1
        JMP  @$0176300       # free allocated memory and exit

Trap4:
       .equiv Trap4Detected, .+4
        MOV  $0xFFFF,$0
        RTI

DummyPSG: .word 0
PPUAllocAddr: .word 023666

PPUModuleEnd:

end:
