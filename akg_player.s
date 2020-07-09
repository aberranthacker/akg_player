
/*******************************************************************************
 * +                                                                         + *
 *            Arkos Tracker 2 player "generic" player.                         *
 *            By Targhan/Arkos.                                                *
 *            Psg optimization trick on CPC by Madram/Overlanders.             *
 *            Conversion for Elektronika MS-0511 by aberrant_hacker            *
 * +                                                                         + *
 *******************************************************************************/

# Use hooks for external calls? 0 if the Init/Play/Stop methods are directly called. Will save a few bytes.
.equiv PLY_AKG_USE_HOOKS, 0
# 1 to have the "stop sounds" code. Set it to 0 if you never plan on stopping your music.
.equiv PLY_AKG_STOP_SOUNDS, 1
# 0 to skip some init code/values, saving memory. Possible if you don't plan on restarting your song.
.equiv PLY_AKG_FULL_INIT_CODE, 1 

    PLY_CFG_ConfigurationIsPresent = 1
    PLY_CFG_UseEffects = 1
    PLY_CFG_UseInstrumentLoopTo = 1
    PLY_CFG_NoSoftNoHard = 1
    PLY_CFG_NoSoftNoHard_Noise = 1        # PLY_AKG_Use_NoiseRegister = 1
    PLY_CFG_SoftOnly = 1                  # PLY_AKG_UseSoftOnlyOrHardOnly 
    PLY_CFG_SoftOnly_Noise = 1            # PLY_AKG_UseSoftOnlyOrHardOnly_Noise 
    PLY_CFG_SoftOnly_SoftwareArpeggio = 1 # PLY_AKG_UseInstrumentArpeggios 
    PLY_CFG_SoftOnly_SoftwarePitch = 1    # PLY_AKG_UseInstrumentPitchs 
    PLY_CFG_UseEffect_SetVolume = 1

# Agglomerates some flags, because they are treated the same way by this player.
#----------------------------------------------------------------------------{{{
        #Special Track Used?
        .ifdef PLY_CFG_UseSpeedTracks
                PLY_AKG_UseSpecialTracks = 1
        .endif
        .ifdef PLY_CFG_UseEventTracks
                PLY_AKG_UseSpecialTracks = 1
        .endif
        #SoftwareOnly and HardOnly share some code.
        .ifdef PLY_CFG_SoftOnly
                PLY_AKG_UseSoftOnlyOrHardOnly = 1
        .endif
        .ifdef PLY_CFG_HardOnly
                PLY_AKG_UseSoftOnlyOrHardOnly = 1
        .endif
        #The same for their noise.
        .ifdef PLY_CFG_SoftOnly_Noise
                PLY_AKG_UseSoftOnlyOrHardOnly_Noise = 1
        .endif
        .ifdef PLY_CFG_HardOnly_Noise
                PLY_AKG_UseSoftOnlyOrHardOnly_Noise = 1
        .endif
        
        #Agglomerates the Forced periods (soft/hard).
        .ifdef PLY_CFG_SoftOnly_ForcedSoftwarePeriod
                PLY_AKG_UseInstrumentForcedPeriods = 1
        .endif
        .ifdef PLY_CFG_HardOnly_ForcedHardwarePeriod
                PLY_AKG_UseInstrumentForcedPeriods = 1
        .endif
        .ifdef PLY_CFG_SoftToHard_ForcedSoftwarePeriod
                PLY_AKG_UseInstrumentForcedPeriods = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_ForcedHardwarePeriod
                PLY_AKG_UseInstrumentForcedPeriods = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_ForcedSoftwarePeriod
                PLY_AKG_UseInstrumentForcedPeriods = 1
        .endif
        #Agglomerates the Instrument Arpeggios (soft/hard).
        .ifdef PLY_CFG_SoftOnly_SoftwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        .ifdef PLY_CFG_SoftToHard_SoftwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        .ifdef PLY_CFG_HardOnly_HardwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_HardwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_SoftwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_HardwareArpeggio
                PLY_AKG_UseInstrumentArpeggios = 1
        .endif
        #Agglomerates the Instrument Pitchs (soft/hard).
        .ifdef PLY_CFG_SoftOnly_SoftwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        .ifdef PLY_CFG_SoftToHard_SoftwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        .ifdef PLY_CFG_HardOnly_HardwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_HardwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_SoftwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_HardwarePitch
                PLY_AKG_UseInstrumentPitchs = 1
        .endif
        #Agglomerates the Instrument Forced Periods, Arpeggios and Pitchs (soft/hard).
        .ifdef PLY_AKG_UseInstrumentForcedPeriods
                PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
        .endif
        .ifdef PLY_AKG_UseInstrumentArpeggios
                PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
        .endif
        .ifdef PLY_AKG_UseInstrumentPitchs
                PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
        .endif
        
        #Agglomerates the Retrig flags for SoftToHard, HardToSoft, SoftAndHard.
        .ifdef PLY_CFG_SoftToHard_Retrig
                PLY_AKG_UseRetrig_StoH_HtoS_SandH = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_Retrig
                PLY_AKG_UseRetrig_StoH_HtoS_SandH = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_Retrig
                PLY_AKG_UseRetrig_StoH_HtoS_SandH = 1
        .endif
        #Agglomerates the noise flags for SoftToHard, HardToSoft, SoftAndHard.
        .ifdef PLY_CFG_SoftToHard_Noise
                PLY_AKG_UseNoise_StoH_HtoS_SandH = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_Noise
                PLY_AKG_UseNoise_StoH_HtoS_SandH = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_Noise
                PLY_AKG_UseNoise_StoH_HtoS_SandH = 1
        .endif
        #Agglomerates the noise flags to know if the code about R6 must be compiled.
        .ifdef PLY_CFG_NoSoftNoHard_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        .ifdef PLY_CFG_SoftOnly_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        .ifdef PLY_CFG_HardOnly_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        .ifdef PLY_CFG_SoftToHard_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        .ifdef PLY_CFG_HardToSoft_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        .ifdef PLY_CFG_SoftAndHard_Noise
                PLY_AKG_Use_NoiseRegister = 1
        .endif
        
        #Agglomerates the effect volume in/out.
        .ifdef PLY_CFG_UseEffect_VolumeIn
                 PLY_AKG_UseEffect_VolumeSlide = 1
        .endif
        .ifdef PLY_CFG_UseEffect_VolumeOut
                 PLY_AKG_UseEffect_VolumeSlide = 1
        .endif
        
        #Agglomerates the Arpeggios Table effects.
        .ifdef PLY_CFG_UseEffect_Arpeggio3Notes
                PLY_AKS_UseEffect_Arpeggio = 1
        .endif
        .ifdef PLY_CFG_UseEffect_Arpeggio4Notes
                PLY_AKS_UseEffect_Arpeggio = 1
        .endif
        .ifdef PLY_CFG_UseEffect_ArpeggioTable
                PLY_AKS_UseEffect_Arpeggio = 1
        .endif
        
        #Agglomerates the PitchUp/Down effects.
        .ifdef PLY_CFG_UseEffect_PitchUp
                PLY_AKS_UseEffect_PitchUpOrDown = 1
        .endif
        .ifdef PLY_CFG_UseEffect_PitchDown
                PLY_AKS_UseEffect_PitchUpOrDown = 1
        .endif
        #Agglomerates the PitchUp/Down/Glide effects.
        #IMPORTANT TO NOTE that if there is Glide, there WILL be pitch up/down, because the Glide is
        #embedded in the pitch up/down code.
        .ifdef PLY_AKS_UseEffect_PitchUpOrDown
                PLY_AKS_UseEffect_PitchUpOrDownOrGlide = 1
        .endif
        .ifdef PLY_CFG_UseEffect_PitchGlide
                PLY_AKS_UseEffect_PitchUpOrDownOrGlide = 1
        .endif
        
        #Agglomerates a special flag combining ArpeggioTable and PitchTable.
        .ifdef PLY_AKS_UseEffect_Arpeggio
                PLY_AKS_UseEffect_ArpeggioTableOrPitchTable = 1
        .endif
        .ifdef PLY_CFG_UseEffect_PitchTable
                PLY_AKS_UseEffect_ArpeggioTableOrPitchTable = 1
        .endif
#----------------------------------------------------------------------------}}}

       .equiv PLY_AKG_OPCODE_CLC, 000241 # Opcode for "or a".
       .equiv PLY_AKG_OPCODE_SEC, 000261 # Opcode for "scf".

        # Includes the sound effects player, if wanted.
        # Important to do it as soon as possible, so that
        # its code can react to the Player Configuration and possibly alter it.
       .ifdef PLY_AKG_MANAGE_SOUND_EFFECTS
           .include "PlayerAkg_SoundEffects.asm"
       .endif # PLY_AKG_MANAGE_SOUND_EFFECTS
        # [[INSERT_SOUND_EFFECT_SOURCE]] # A tag for test units.
                                         # Don't touch or you're dead.

# Initializes the player.
# IN:    R5 = music address.
#        R0 = subsong index (>=0).
PLY_AKG_Init: #--------------------------------------------------------------{{{
    .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC
        ADD $4,R5 # Skip the tag
       .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:432
           .error
       .else
        INC  R5
        INC  R5
       .endif # PLY_AKS_UseEffect_Arpeggio

       .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:440
           .error
       .else
        INC  R5
        INC  R5
       .endif # PLY_CFG_UseEffect_PitchTable
    .else
       .error
    .endif # PLY_CFG_UseEffects

        MOV  (R5)+,@$PLY_AKG_InstrumentsTable

    .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:456
        MOV  (R5)+,R3
        MOV  R3,@$PLY_AKG_Channel_ReadEffects_EffectBlocks1
        MOV  R3,@$PLY_AKG_Channel_ReadEffects_EffectBlocks2
    .else
       .error
    .endif # PLY_CFG_UseEffects

        # We have reached the Subsong addresses. Which one to use?
        ASL  R0
        ADD  R0,R5

        MOV  (R5),R5 # R5 points on the Subsong metadata.
        ADD  $5,R5   # Skips the replay frequency, digichannel, psg count, loop start index, end index.
        MOVB (R5)+,@$PLY_AKG_CurrentSpeed
        MOVB (R5)+,@$PLY_AKG_BaseNoteIndex
        INC  R5 # align the pointer on word
        MOV  R5,@$PLY_AKG_ReadLinker_PtLinker

        # Initializes values. You can remove this part if you don't stop/restart your song.
   .if PLY_AKG_FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:492
        MOV  $PLY_AKG_InitTable0,R5
       .set words_count, (PLY_AKG_InitTable0_End - PLY_AKG_InitTable0) >> 1
        MOV  $words_count,R1
        CLR  R2
        CALL PLY_AKG_Init_ReadWordsAndFill

        MOV  $PLY_AKG_InitTable1,R5
       .set words_count, (PLY_AKG_InitTable1_End - PLY_AKG_InitTable1) >> 1
        MOV  $words_count,R1
        INC  R2
        CALL PLY_AKG_Init_ReadWordsAndFill

        MOV  $PLY_AKG_InitTableOrA,R5
       .set words_count, (PLY_AKG_InitTableOrA_End - PLY_AKG_InitTableOrA) >> 1
        MOV  $words_count,R1
        MOV  $PLY_AKG_OPCODE_CLC,R2 # CLC opcode
        CALL PLY_AKG_Init_ReadWordsAndFill

       .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:511
           .error
       .endif
   .endif # PLY_AKG_FULL_INIT_CODE 

        # Stores the address to the empty instrument *data* (header skipped).
        MOV  @$PLY_AKG_InstrumentsTable,R5
        MOV  (R5),R5
        INC  R5 # Skip the header
        MOV  R5,@$PLY_AKG_EmptyInstrumentDataPt
        # Sets all the instrument to "empty".
        MOV  R5,@$PLY_AKG_Channel1_PtInstrument
        MOV  R5,@$PLY_AKG_Channel2_PtInstrument
        MOV  R5,@$PLY_AKG_Channel3_PtInstrument

        # If sound effects, clears the SFX state.
       .ifdef PLY_AKG_MANAGE_SOUND_EFFECTS # playerAkg/sources/PlayerAkg.asm:550
        CLR  @$PLY_AKG_Channel1_SoundEffectData
        CLR  @$PLY_AKG_Channel2_SoundEffectData
        CLR  @$PLY_AKG_Channel3_SoundEffectData
       .endif # PLY_AKG_MANAGE_SOUND_EFFECTS

RETURN # PLY_AKG_Init -------------------------------------------------------}}}

   .if PLY_AKG_FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:559
        # Fills all the read addresses with a byte.
        # IN:    R5 = table where the addresses are.
        #        R1 = how many items in the table + 1.
        #        R2 = byte to fill.
PLY_AKG_Init_ReadWordsAndFill_Loop:
        MOV  R2,@(R5)+
PLY_AKG_Init_ReadWordsAndFill:
        SOB  R1,PLY_AKG_Init_ReadWordsAndFill_Loop

        RETURN

# Table initializing some data with 0.
PLY_AKG_InitTable0: # playerAkg/sources/PlayerAkg.asm:576
       .word PLY_AKG_Channel1_InvertedVolumeIntegerAndDecimal 
       .word PLY_AKG_Channel2_InvertedVolumeIntegerAndDecimal 
       .word PLY_AKG_Channel3_InvertedVolumeIntegerAndDecimal 

       .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC
        .word PLY_AKG_Channel1_Pitch
        .word PLY_AKG_Channel2_Pitch
        .word PLY_AKG_Channel3_Pitch
       .endif #PLY_AKS_UseEffect_PitchUpOrDown

       .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC
        .word PLY_AKG_Retrig
       .endif #PLY_CFG_UseRetrig
PLY_AKG_InitTable0_End:

PLY_AKG_InitTable1: # playerAkg/sources/PlayerAkg.asm:598
        .word PLY_AKG_PatternDecreasingHeight
        .word PLY_AKG_TickDecreasingCounter
PLY_AKG_InitTable1_End:

PLY_AKG_InitTableOrA: # playerAkg/sources/PlayerAkg.asm:605 ----------------{{{
       .ifdef PLY_AKG_UseEffect_VolumeSlide   # CONFIG SPECIFIC
       .error
       .word PLY_AKG_Channel1_IsVolumeSlide
       .word PLY_AKG_Channel2_IsVolumeSlide
       .word PLY_AKG_Channel3_IsVolumeSlide
       .endif # PLY_AKG_UseEffect_VolumeSlide
       .ifdef PLY_AKS_UseEffect_Arpeggio      # CONFIG SPECIFIC
       .error
       .word PLY_AKG_Channel1_IsArpeggioTable
       .word PLY_AKG_Channel2_IsArpeggioTable
       .word PLY_AKG_Channel3_IsArpeggioTable
       .endif # PLY_AKS_UseEffect_Arpeggio
       .ifdef PLY_CFG_UseEffect_PitchTable    # CONFIG SPECIFIC
       .error
       .word PLY_AKG_Channel1_IsPitchTable
       .word PLY_AKG_Channel2_IsPitchTable
       .word PLY_AKG_Channel3_IsPitchTable
       .endif # PLY_CFG_UseEffect_PitchTable
       .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC
       .error
       .word PLY_AKG_Channel1_IsPitch
       .word PLY_AKG_Channel2_IsPitch
       .word PLY_AKG_Channel3_IsPitch
       .endif # PLY_AKS_UseEffect_PitchUpOrDown
PLY_AKG_InitTableOrA_End: #-------------------------------------------------}}}
   .endif # PLY_AKG_FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:629

        # New line! Is the Pattern ended? Not as long as there are lines to read.
        MOV  (PC)+,R0; PLY_AKG_PatternDecreasingHeight: .word 1 # playerAkg/sources/PlayerAkg.asm:694


################################################################################
#                      Plays one frame of the subsong.                         #
################################################################################
PLY_AKG_Play: # playerAkg/sources/PlayerAkg.asm:676
        MOV  SP,@$PLY_AKG_SaveSP

   .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
       .error
   .endif # PLY_CFG_UseEventTracks

        # Decreases the tick counter. If 0 is reached, a new line must be read.
        MOV  (PC)+,R0; PLY_AKG_TickDecreasingCounter: .word 1
        DEC  R0
        # Jumps if there is no new line: continues playing the sound stream.
        BZE  PLY_AKG_ReadLinker
        JMP  PLY_AKG_SetSpeedBeforePlayStreams

        # New line! Is the Pattern ended?
        # Not as long as there are lines to read.
PLY_AKG_ReadLinker: # playerAkg/sources/PlayerAkg.asm:704
        MOV  (PC)+,SP; PLY_AKG_ReadLinker_PtLinker: .word 0
        # Reads the address of each Track.
        MOV  (SP)+,R5
        BNZ  PLY_AKG_ReadLinker_NoLoop
        # End of the song.
        MOV  (SP)+,SP # read loop address
        MOV  (SP)+,R5 # Reads once again the address of Track 1, in the pattern looped to.
PLY_AKG_ReadLinker_NoLoop: # playerAkg/sources/PlayerAkg.asm:720
        MOV  R5,@$PLY_AKG_Channel1_PtTrack
        MOV  (SP)+,@$PLY_AKG_Channel2_PtTrack
        MOV  (SP)+,@$PLY_AKG_Channel3_PtTrack
        # Reads the address of the LinkerBlock.
        MOV  (SP)+,R5
        MOV  SP,@$PLY_AKG_ReadLinker_PtLinker
        MOV  R5,SP

        # Reads the LinkerBlock. SP = LinkerBlock.
        # Reads the height and transposition1.
        MOV  (SP)+,R5
        CLR  R2
        BISB R5,R2

   .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
       .error
   .endif # PLY_CFG_UseTranspositions

        # Reads the transposition2 and 3.
   .ifdef PLY_AKG_UseSpecialTracks # CONFIG SPECIFIC
       .error
       .ifndef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
           .error
       .endif # PLY_CFG_UseTranspositions
   .endif # PLY_AKG_UseSpecialTracks

   .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
       .error
   .endif # PLY_CFG_UseTranspositions

   .ifdef PLY_AKG_UseSpecialTracks # CONFIG SPECIFIC
       .error
        # Reads the special Tracks addresses.
       .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC
           .error
       .endif # PLY_CFG_UseSpeedTracks
        
       .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
           .error
       .endif # PLY_CFG_UseEventTracks
   .endif # PLY_AKG_UseSpecialTracks
        
        # Forces the reading of every Track and Special Track.
   .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC
        CLR  @$PLY_AKG_SpeedTrack_WaitCounter
   .endif # PLY_CFG_UseSpeedTracks

   .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
        CLR  @$PLY_AKG_EventTrack_WaitCounter
   .endif # PLY_CFG_UseEventTracks

        CLR  @$PLY_AKG_Channel1_WaitCounter
        CLR  @$PLY_AKG_Channel2_WaitCounter
        CLR  @$PLY_AKG_Channel3_WaitCounter
        MOV  R2,R0
PLY_AKG_SetCurrentLineBeforeReadLine: # playerAkg/sources/PlayerAkg.asm:779
        MOV  R0,@$PLY_AKG_PatternDecreasingHeight
 

        # Reads the new line (notes, effects, Special Tracks, etc.).
PLY_AKG_ReadLine: # playerAkg/sources/PlayerAkg.asm:784
        # Reads the Speed Track.
        #-------------------------------------------------------------------
   .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC
       .error # playerAkg/sources/PlayerAkg.asm:786
   .endif # PLY_CFG_UseSpeedTracks

        # Reads the Event Track.
        #-------------------------------------------------------------------
   .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
       .error # playerAkg/sources/PlayerAkg.asm:828
   .endif # PLY_CFG_UseEventTracks 


       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Reads the possible Cell of the Channel 1, 2 and 3.        *
        * Use a Macro for each channel, but the code is duplicated. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro PLY_AKG_ReadTrack channelNumber
        # Lines to wait?
        DEC  (PC)+; PLY_AKG_Channel\channelNumber\()_WaitCounter: .word 0
        BMI  PLY_AKG_Channel\channelNumber\()_ReadTrack
        # Still some lines to wait.
        JMP  PLY_AKG_Channel\channelNumber\()_ReadCellEnd

PLY_AKG_Channel\channelNumber\()_ReadTrack: # playerAkg/sources/PlayerAkg.asm:886
        # Points on the Cell to read.
        MOV  (PC)+,R5; PLY_AKG_Channel\channelNumber\()_PtTrack: .word 0
        # Reads note data. It can be a note, a wait...

        CLR  R2
        BISB (R5)+,R2 # R2 = data (b5-0) + effect? (b6) + new Instrument? (b7).
        MOV  R2,R0
        BIC  $0xFFC0,R0 # R0 = data
        # 0-59: note.
        # "CMP" is preferred to "SUB" so that the "note" branch (the slowest) is note-ready.
        CMP  R0,$60 
        BLO  PLY_AKG_Channel\channelNumber\()_Note
        SUB  $60,R0
       .jmp  EQ, PLY_AKG_Channel\channelNumber\()_MaybeEffects # 60 = no note, but maybe effects.
        DEC  R0
        BZE  PLY_AKG_Channel\channelNumber\()_Wait             # 61 = wait, no effect.
        DEC  R0
        BZE  PLY_AKG_Channel\channelNumber\()_SmallWait        # 62 = small wait, no effect.
        # 63 = escape code for note, maybe effects.
        # Reads the note in the next byte (HL has already been incremented).
        MOVB (R5)+,R0
        BR   PLY_AKG_Channel\channelNumber\()_AfterNoteKnown

        # Small wait, no effect.
PLY_AKG_Channel\channelNumber\()_SmallWait: # playerAkg/sources/PlayerAkg.asm
        MOV  R2,R0 # Uses bit 6/7 to indicate how many lines to wait.
        ASH  $-6,R0
        INC  R0 # This wait start at 2 lines, to 5.
        MOV  R0,@$PLY_AKG_Channel\channelNumber\()_WaitCounter
        BR   PLY_AKG_Channel\channelNumber\()_BeforeEnd_StoreCellPointer

        # Wait, no effect.
PLY_AKG_Channel\channelNumber\()_Wait: # playerAkg/sources/PlayerAkg.asm
        # Reads the wait value on the next byte (HL has already been incremented).
        MOVB (R5)+,@$PLY_AKG_Channel\channelNumber\()_WaitCounter
        BR   PLY_AKG_Channel\channelNumber\()_BeforeEnd_StoreCellPointer

        # Little subcode put here, called just below. A bit dirty, but avoids long jump.
PLY_AKG_Channel\channelNumber\()_SameInstrument: # playerAkg/sources/PlayerAkg.asm:931
        # No new instrument. The instrument pointer must be reset.
        MOV  (PC)+,@(PC)+
        PLY_AKG_Channel\channelNumber\()_PtBaseInstrument:
       .word 0, PLY_AKG_Channel\channelNumber\()_PtInstrument
        BR   PLY_AKG_Channel\channelNumber\()_AfterInstrument

        # A note has been found, plus maybe an Instrument and effects.
        # R0 = note. R2 = still has the New Instrument/Effects flags.
PLY_AKG_Channel\channelNumber\()_Note: # playerAkg/sources/PlayerAkg.asm:943
    # Declares this only for the first channel, else refers to it.
   .if \channelNumber == 1
        # The encoded note is only from a 4 octave range, but the first note
        # depends on the best window, determined by the song generator.
        ADD  (PC)+,R0; PLY_AKG_BaseNoteIndex: .word 0
   .else
        ADD  @$PLY_AKG_BaseNoteIndex,R0
   .endif

PLY_AKG_Channel\channelNumber\()_AfterNoteKnown: # playerAkg/sources/PlayerAkg.asm:957
   .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
        # Adds the Track transposition.
        ADD  (PC)+,R0; PLY_AKG_Channel\channelNumber\()_Transposition: .word 0
   .endif # PLY_CFG_UseTranspositions

        MOVB R0,@$PLY_AKG_Channel\channelNumber\()_TrackNote

        # HL = next data. C = data byte.
        ROLB R2 # New Instrument?
        BCC  PLY_AKG_Channel\channelNumber\()_SameInstrument
        # Gets the new Instrument.
        CLR  R4
        BISB (R5)+,R4

        ASL  R4
   .if \channelNumber == 1 # Declares this only for the first channel, else refers to it.
        # Points on the Instruments table of the music (set on song initialization).
        ADD  (PC)+,R4; PLY_AKG_InstrumentsTable: .word 0 # playerAkg/sources/PlayerAkg.asm:982
   .else
        # Points on the Instruments table of the music (set on song initialization).
        ADD  @$PLY_AKG_InstrumentsTable,R4
   .endif
        MOV  (R4),R4
          
        # No need to store an "original speed" if "force instrument speed" effect is not used.
   .ifdef PLY_CFG_UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC
        MOVB (R4)+,@$PLY_AKG_Channel\channelNumber\()_InstrumentOriginalSpeed
   .else
        MOVB (R4)+,@$PLY_AKG_Channel\channelNumber\()_InstrumentSpeed
   .endif # PLY_CFG_UseEffect_ForceInstrumentSpeed
        MOV  R4,@$PLY_AKG_Channel\channelNumber\()_PtInstrument
        # Useful when playing another note with the same instrument.
        MOV  R4,@$PLY_AKG_Channel\channelNumber\()_PtBaseInstrument


PLY_AKG_Channel\channelNumber\()_AfterInstrument: # playerAkg/sources/PlayerAkg.asm:1008
        # There is a new note. The instrument pointer has already been reset.
        # -------------------------------------------------------------------
        # Instrument number is set.
        # Arpeggio and Pitch Table are reset.
        
        # The track pitch and glide, instrument step are reset.
   .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
        CLR  @$PLY_AKG_Channel\channelNumber\()_Pitch
   .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
        CLR  @$PLY_AKG_Channel\channelNumber\()_ArpeggioTableCurrentStep
   .endif # PLY_AKS_UseEffect_Arpeggio

   .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC
        CLR  @$PLY_AKG_Channel\channelNumber\()_PitchTableCurrentStep
   .endif # PLY_CFG_UseEffect_PitchTable
        CLR  @$PLY_AKG_Channel\channelNumber\()_InstrumentStep
        
    # If the "force instrument speed" effect is used,
    # the instrument speed must be reset to its original value.
   .ifdef PLY_CFG_UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC
       .error
        MOV  (PC)+,@(PC)+; PLY_AKG_Channel\channelNumber\()_InstrumentOriginalSpeed:
       .word 0,  PLY_AKG_Channel\channelNumber\()_InstrumentSpeed
   .endif # PLY_CFG_UseEffect_ForceInstrumentSpeed
        
   .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC
       .error
        MOV  $PLY_AKG_OPCODE_CLC, @$PLY_AKG_Channel\channelNumber\()_IsPitch
   .endif # PLY_AKS_UseEffect_PitchUpOrDown
        
        # Resets the speed of the Arpeggio and the Pitch.
   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
       .error
        MOV  @$PLY_AKG_Channel\channelNumber\()_ArpeggioBaseSpeed, @$PLY_AKG_Channel\channelNumber\()_ArpeggioTableSpeed
   .endif # PLY_AKS_UseEffect_Arpeggio

   .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC
       .error
        MOV  @$PLY_AKG_Channel\channelNumber\()_PitchBaseSpeed, @$PLY_AKG_Channel\channelNumber\()_PitchTableSpeed
   .endif # PLY_CFG_UseEffect_PitchTable

   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
       .error
        # Points to the first value of the Arpeggio.
        MOV  @$PLY_AKG_Channel\channelNumber\()_ArpeggioTableBase, @$PLY_AKG_Channel\channelNumber\()_ArpeggioTable
   .endif # PLY_AKS_UseEffect_Arpeggio

   .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC
       .error
        # Points to the first value of the Pitch.
        MOV  @$PLY_AKG_Channel\channelNumber\()_PitchTableBase, @$PLY_AKG_Channel\channelNumber\()_PitchTable
   .endif # PLY_CFG_UseEffect_PitchTable

   .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC
        # Effects?
        ROLB R2
       .jmp  CS,PLY_AKG_Channel\channelNumber\()_ReadEffects
   .endif # PLY_CFG_UseEffects

        # No effects. Nothing more to read for this cell.
PLY_AKG_Channel\channelNumber\()_BeforeEnd_StoreCellPointer:
        MOV  R5,@$PLY_AKG_Channel\channelNumber\()_PtTrack
PLY_AKG_Channel\channelNumber\()_ReadCellEnd:

.endm # PLY_AKG_ReadTrack

        # Generates the code for each channel, from the macro above.
        PLY_AKG_ReadTrack 1
        PLY_AKG_ReadTrack 2
        PLY_AKG_ReadTrack 3



        MOV  (PC)+,R0; PLY_AKG_CurrentSpeed: .word 0
PLY_AKG_SetSpeedBeforePlayStreams: # playerAkg/sources/PlayerAkg.asm:1104
        MOV  R0,@$PLY_AKG_TickDecreasingCounter



        /* * * * * * * * * * * * * * * * * * * * * * * * * * *
         * Applies the trailing effects for channel 1, 2, 3. *
         * Uses a macro instead of duplicating the code.     *
         * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro PLY_AKG_ApplyTrailingEffects channelNumber #--------------------------{{{

        # Use Volume slide?
        #----------------------------
        MOV  (PC)+,R5; PLY_AKG_Channel\channelNumber\()_InvertedVolumeIntegerAndDecimal: .word 0 

        # playerAkg/sources/PlayerAkg.asm:1127
       .equiv PLY_AKG_Channel\channelNumber\()_InvertedVolumeInteger, PLY_AKG_Channel\channelNumber\()_InvertedVolumeIntegerAndDecimal + 1

   .ifdef PLY_AKG_UseEffect_VolumeSlide # CONFIG SPECIFIC #------------------{{{
        # Is there a Volume Slide ? Automodified. SCF if yes, OR A if not.
        PLY_AKG_Channel\channelNumber\()_IsVolumeSlide: CLC

        BCC nc,PLY_AKG_Channel\channelNumber\()_VolumeSlide_End
 
        # May be negative.
        MOV  (PC)+,R3; PLY_AKG_Channel\channelNumber\()_VolumeSlideValue: .word 0 

        ADD  R3,R5
        BMI  PLY_AKG_Channel\channelNumber\()_VolumeNotOverflow

        CLR  R5 # No need to set L to 0... Shouldn't make any hearable difference.
        BR   PLY_AKG_Channel\channelNumber\()_VolumeSetAgain

PLY_AKG_Channel\channelNumber\()_VolumeNotOverflow:
        # Higher than 15?
        SWAB R5
        CMPB R5,$16
        BLO  PLY_AKG_Channel\channelNumber\()_VolumeSetAgain
        CLRB R5
        BISB $15,R5
PLY_AKG_Channel\channelNumber\()_VolumeSetAgain:
        SWAB R5
        MOV  R5,@$PLY_AKG_Channel\channelNumber\()_InvertedVolumeIntegerAndDecimal
PLY_AKG_Channel{channelNumber}_VolumeSlide_End:
   .endif # PLY_AKG_UseEffect_VolumeSlide #----------------------------------}}}

        SWAB R5
        MOVB R5,@$PLY_AKG_Channel\channelNumber\()_GeneratedCurrentInvertedVolume
        
        # Use Arpeggio table? OUT: C = value.
        #----------------------------------------
   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1169
       .error
   .endif # PLY_AKS_UseEffect_Arpeggio

        # Use Pitch table? OUT: DE = pitch value.
        # C must NOT be modified!
        #-----------------------
        CLR  R3 # Default value.

   .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1232
       .error
   .endif # PLY_CFG_UseEffect_PitchTable

        # Pitch management. The Glide is embedded, but relies on the Pitch
        # (Pitch can exist without Glide, but Glide can not without Pitch).
        # Do NOT modify C or DE.
        #------------------------------------------------------------------------------------------
   .ifndef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1276
        CLR  R5 # No pitch.
        # Some dirty duplication in case there is no pitch up/down/glide.
        # The "real" vars are a bit below.
# Put here, no need for better place (see the real label below, with the same name).
PLY_AKG_Channel\channelNumber\()_SoundStream_RelativeModifierAddress:
       .ifdef PLY_AKS_UseEffect_ArpeggioTableOrPitchTable # CONFIG SPECIFIC
           .error
       .endif # PLY_AKS_UseEffect_ArpeggioTableOrPitchTable
   .else # PLY_AKS_UseEffect_PitchUpOrDownOrGlide # playerAkg/sources/PlayerAkg.asm:1301
        .error
   .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

        ADD  R3,R5 # Adds the Pitch Table value.
        MOV  R5,@$PLY_AKG_Channel\channelNumber\()_GeneratedCurrentPitch

   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
       .error
   .endif # PLY_AKS_UseEffect_Arpeggio

.endm #----------------------------------------------------------------------}}}
 
        PLY_AKG_ApplyTrailingEffects 1
        PLY_AKG_ApplyTrailingEffects 2
        PLY_AKG_ApplyTrailingEffects 3



        # The stack must NOT be diverted during the Play Streams!
        MOV  @$PLY_AKG_SaveSP,SP

       /* * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Plays the instrument on channel 1, 2, 3.          *
        * The PSG registers related to the channels are set.*
        * A macro is used instead of duplicating the code.  *
        * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro PLY_AKG_PlayInstrument channelNumber # playerAkg/sources/PlayerAkg.asm:1504 -{{{
# This must be placed at the any location to allow reaching the variables via IX/IY.
PLY_AKG_Channel\channelNumber\()_PlayInstrument_RelativeModifierAddress:                   

        # What note to play?
        # The pitch to add to the real note, according to the Pitch Table + Pitch/Glide effect.
        MOV  (PC)+,R4; PLY_AKG_Channel\channelNumber\()_GeneratedCurrentPitch: .word 0

   .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
       .error
   .else # PLY_AKS_UseEffect_Arpeggio
        # Not automodified, stays this way.
        MOV  (PC)+,R3; PLY_AKG_Channel\channelNumber\()_TrackNote: .word 0
   .endif # PLY_AKS_UseEffect_Arpeggio

        # exx # playerAkg/sources/PlayerAkg.asm:1539

       #MOV  (PC)+,R1; PLY_AKG_Channel\channelNumber\()_InstrumentStep: .word 0
        MOV  (PC)+,@(PC)+;
        PLY_AKG_Channel\channelNumber\()_InstrumentStep:
       .word 0, R_Retrig
        # Instrument data to read (past the header).
        MOV  (PC)+,R5; PLY_AKG_Channel\channelNumber\()_PtInstrument: .word 0      

   .if \channelNumber == 1 # Different code for the first channel.
        # R7, shift twice TO THE LEFT.
        # By default, the noise is cut (111), the sound is on (most usual case).
        MOV  (PC)+,R2; PLY_AKG_Channel\channelNumber\()_GeneratedCurrentInvertedVolume: .word 0b11100000 << 8 + 15       
   .else
        MOV  (PC)+,R2; PLY_AKG_Channel\channelNumber\()_GeneratedCurrentInvertedVolume: .word 15       
   .endif

        # R_Reg7  = Reg7
        # R2   = inverted volume.
        # D'   = 0,
        # R3   = note (instrument + Track transposition).
        # R4   = track pitch.
        # R5   = PtInstrument

        CALL PLY_AKG_ReadInstrumentCell # playerAkg/sources/PlayerAkg.asm:1567

        # The new and increased Instrument pointer is stored only if its speed has been reached.
        # (>0) # playerAkg/sources/PlayerAkg.asm:1577
        CMP  R0,(PC)+; PLY_AKG_Channel\channelNumber\()_InstrumentSpeed: .word 0

.endm # PLY_AKG_PlayInstrument ----------------------------------------------}}}
        
        # Generates the code for all channels using the macro above.
        PLY_AKG_PlayInstrument 1
        PLY_AKG_PlayInstrument 2
        PLY_AKG_PlayInstrument 3

# Plays the sound effects, if desired.
#-------------------------------------------
   .ifdef PLY_AKG_MANAGE_SOUND_EFFECTS # playerAkg/sources/PlayerAkg.asm:1638
        # IN : A = R7
        # OUT: A = R7, possibly modified.
        CALL PLY_AKG_PlaySoundEffectsStream
   .endif # PLY_AKG_MANAGE_SOUND_EFFECTS
 
/*  -----------------------------------------------------------------------  
                               PSG access.
    -----------------------------------------------------------------------  */

        # playerAkg/sources/PlayerAkg.asm:2209
        MOV  (PC)+,SP; PLY_AKG_SaveSP: .word 0

        RETURN # playerAkg/sources/PlayerAkg.asm:2216

       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Channel1/2/3 sub-codes. Uses a macro to mutualize the code. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
.macro PLY_AKG_ChannelSubcodes channelNumber
PLY_AKG_Channel\channelNumber\()_MaybeEffects:

# Reads the effects.
# IN:    HL = Points on the effect blocks
# OUT:   HL = Points after on the effect blocks
PLY_AKG_Channel\channelNumber\()_ReadEffects: # playerAkg/sources/PlayerAkg.asm:2250
.endm # PLY_AKG_ChannelSubcodes

        # Generates the code thanks to the macro declare above.
        PLY_AKG_ChannelSubcodes 1
        PLY_AKG_ChannelSubcodes 2
        PLY_AKG_ChannelSubcodes 3

        # playerAkg/sources/PlayerAkg.asm:2296
        MOV  (PC)+,R3; PLY_AKG_Channel_ReadEffects_EffectBlocks1: .word 0

        # playerAkg/sources/PlayerAkg.asm:2351
        MOV  (PC)+,R3; PLY_AKG_Channel_ReadEffects_EffectBlocks2: .word 0

# ---------------------------------
# Codes that read InstrumentCells.
# IN:    R5  = pointer on the Instrument data cell to read.
#        IX  = can be modified.
#            = Instrument step (>=0). Useful for retrig.
R_Retrig: .word 0
#        SP  = normal use of the stack, do not pervert it!
#            = register 7, as if it was the channel 3 (so, bit 2 and 5 filled only).
#              By default, the noise is OFF, the sound is ON, so no need to do
#              anything if these values match.
R_Reg7: .word 0
#        R2  = inverted volume.
#        R0  = SET BELOW: first byte of the data, shifted of 3 bits to the right.
#        R1  = SET BELOW: first byte of the data, unmodified.
#        R4  = track pitch.
#R_TrackPitch: .word 0
#        R3 = 0 / note (instrument + Track transposition).
#        BC' = temp, use at will.
R_Tmp: .word 0

# OUT:   R5  = new pointer on the Instrument (may be on the empty sound).
#              If not relevant, any value can be returned, it doesn't matter.
#        R_Retrig = Not 0 if retrig for this channel.
#        R_Reg7   = register 7, updated, as if it was the channel 1 (so, bit 2 and 5 filled only).
#        R2  = volume to encode (0-16).
#        R4  = software period. If not relevant, do not set it.
#        R3  = output period.

.equiv PLY_AKG_BitForSound, 0b00000100
.equiv PLY_AKG_BitForNoise, 0b00100000

PLY_AKG_ReadInstrumentCell: # playerAkg/sources/PlayerAkg.asm:2391
        MOVB (R5)+,R0
        MOV  R0,R1 # Stores the first byte, handy in many cases.

        # What type if the cell?
        # First bit of the type.
        RORB R0
       .jmp CS,PLY_AKG_S_Or_H_Or_SaH_Or_EndWithLoop
        # No Soft No Hard, or Soft To Hard, or Hard To Soft, or End without loop.
        RORB R0
        BCS  PLY_AKG_StH_Or_EndWithoutLoop
        # No Soft No Hard, or Hard to Soft.
        RORB R0
   .ifdef PLY_CFG_HardToSoft # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2408
       .error
   .endif # PLY_CFG_HardToSoft

       /* * * * * * * * * * * *
        * "No soft, no hard". *
        * * * * * * * * * * * */
PLY_AKG_NoSoftNoHard: # playerAkg/sources/PlayerAkg.asm:2420
        BIC  $0xFFF0,R0 # Necessary, we don't know what crap is in the 4th bit of A.

       /* * * * * * * * *
        * "Soft only".  *
        * * * * * * * * */
   .ifdef PLY_CFG_SoftOnly # CONFIG SPECIFIC
PLY_AKG_Soft: # playerAkg/sources/PlayerAkg.asm:2453
        # Calculates the volume.
        BIC  $0xFFF0,R0 # Necessary, we don't know what crap is in the 4th bit of A.
        SUB  R2,R0
        BCC  10$
        CLR  R0
10$:    MOV  R0,R2
.endif # PLY_CFG_SoftOnly

   .ifdef PLY_AKG_UseSoftOnlyOrHardOnly
        # This code is also used by "Hard only".
PLY_AKG_SoftOnly_HardOnly_TestSimple_Common: # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2464
        # Simple sound? Gets the bit, let the subroutine do the job.
        ROLB R1
        BCC  PLY_AKG_S_NotSimple
        # Simple.
        CLR  @$R_Tmp # This will force the noise to 0.
        BR   PLY_AKG_S_AfterSimpleTest
PLY_AKG_S_NotSimple: # playerAkg/sources/PlayerAkg.asm:2471
        # Not simple. Reads and keeps the next byte, containing the noise.
        # WARNING, the following code must NOT modify the Carry!
        MOVB (R5)+,R1
        MOV  R2,@$R_Tmp
PLY_AKG_S_AfterSimpleTest:

        call PLY_AKG_S_Or_H_CheckIfSimpleFirst_CalculatePeriod

       .ifdef PLY_AKG_UseSoftOnlyOrHardOnly_Noise # CONFIG SPECIFIC
            .error
       .endif # PLY_AKG_UseSoftOnlyOrHardOnly_Noise
   .endif # PLY_AKG_UseSoftOnlyOrHardOnly

       /* * * * * * * * * *
        * "Hard to soft". *
        * * * * * * * * * */
   .ifdef PLY_CFG_HardToSoft # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2499
   .endif # PLY_CFG_HardToSoft


       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * End without loop. Put here to satisfy the BR range below. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
PLY_AKG_EndWithoutLoop: # playerAkg/sources/PlayerAkg.asm:2575
        # Loops to the "empty" instrument, and makes another iteration.
        MOV  (PC)+,R5; PLY_AKG_EmptyInstrumentDataPt: .word 0

        # No need to read the data, consider a void value.
        INC  R5
        CLR  R0
        CLR  R1

        BR   PLY_AKG_NoSoftNoHard

PLY_AKG_StH_Or_EndWithoutLoop: # playerAkg/sources/PlayerAkg.asm:2596
        RORB R0
   .ifndef PLY_CFG_SoftToHard # CONFIG SPECIFIC
        BR   PLY_AKG_EndWithoutLoop
   .else
       .error
   .endif

PLY_AKG_S_Or_H_Or_SaH_Or_EndWithLoop: # playerAkg/sources/PlayerAkg.asm:2687
        # Second bit of the type.
        RORB R0
        BCS  PLY_AKG_H_Or_EndWithLoop
        # Third bit of the type.
        RORB R0
   .ifdef PLY_CFG_SoftOnly # CONFIG SPECIFIC
       .jmp CC, PLY_AKG_Soft
   .endif # PLY_CFG_SoftOnly

   .ifdef PLY_CFG_SoftAndHard # CONFIG SPECIFIC
       .error
   .endif # PLY_CFG_SoftAndHard

PLY_AKG_H_Or_EndWithLoop: # playerAkg/sources/PlayerAkg.asm:2725

# Common code for calculating the period, regardless of Soft or Hard.
# The same register constraints as the methods above apply.
# IN:    R5  = the next bytes to read.
#        R4  = track pitch
#        R3  = note + transposition.
#        R2  = do not modify.
#        R1  = contains three bits:
#                b7: forced period? (if yes, the two other bits are irrelevant)
#                b6: arpeggio?
#                b5: pitch?
#        Carry: Simple sound?
#
# OUT:   R1 = shift three times to the left.
#        R2 = unmodified.
#        R4 = calculated period.
#        R5 = advanced.
PLY_AKG_S_Or_H_CheckIfSimpleFirst_CalculatePeriod:
        # Simple sound? Checks the carry.
   .ifdef PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs # CONFIG SPECIFIC
        BCC  PLY_AKG_S_Or_H_NextByte
   .endif # PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs
        # No more bytes to read, the sound is "simple". The software period must still be calculated.
        # Calculates the note period from the note of the track. This is the same code as below.
        ASL  R3
        ADD  @PLY_AKG_PeriodTable(R3),R4
        # Important: the bits must be shifted so that B is in the same state
        # as if it were not a "simple" sound.
        ROLB R1
        ROLB R1
        ROLB R1
        # No need to modify R7.
RETURN

   .ifdef PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs # CONFIG SPECIFIC
PLY_AKG_S_Or_H_NextByte: # playerAkg/sources/PlayerAkg.asm:2835
        # Not simple. Reads the next bits to know if there is pitch/arp/forced software period.        

        # Forced period?
        ROLB R1
       .ifdef PLY_AKG_UseInstrumentForcedPeriods # CONFIG SPECIFIC
           .error
        BCS   PLY_AKG_S_Or_H_ForcedPeriod
       .endif # PLY_AKG_UseInstrumentForcedPeriods

        # No forced period. Arpeggio?
        ROLB R1
       .ifdef PLY_AKG_UseInstrumentArpeggios # CONFIG SPECIFIC
           .error
        BCC  PLY_AKG_S_Or_H_AfterArpeggio
        MOVB (R5)+,R0
        # exx
        #         add a,e                         ;We don't care about overflow, no time for that.
        #         ld e,a
        # exx

PLY_AKG_S_Or_H_AfterArpeggio:
       .endif # PLY_AKG_UseInstrumentArpeggios

        # Pitch?
        ROLB R1
       .ifdef PLY_AKG_UseInstrumentPitchs # CONFIG SPECIFIC
           .error
       .endif # PLY_AKG_UseInstrumentPitchs
        # Calculates the note period from the note of the track.
RETURN
   .endif # PLY_AKG_UseInstrumentForcedPeriodsOrArpeggiosOrPitchs
 


# The period table for each note (from 0 to 127 included).
PLY_AKG_PeriodTable: # playerAkg/sources/PlayerAkg.asm:3450
        # PSG running to 1773400 Hz.
    .word 6778, 6398, 6039, 5700, 5380, 5078, 4793, 4524, 4270, 4030, 3804, 3591 # Octave 0
    .word 3389, 3199, 3019, 2850, 2690, 2539, 2397, 2262, 2135, 2015, 1902, 1795 # Octave 1
    .word 1695, 1599, 1510, 1425, 1345, 1270, 1198, 1131, 1068, 1008,  951,  898 # Octave 2
    .word  847,  800,  755,  712,  673,  635,  599,  566,  534,  504,  476,  449 # Octave 3
    .word  424,  400,  377,  356,  336,  317,  300,  283,  267,  252,  238,  224 # Octave 4
    .word  212,  200,  189,  178,  168,  159,  150,  141,  133,  126,  119,  112 # Octave 5
    .word  106,  100,   94,   89,   84,   79,   75,   71,   67,   63,   59,   56 # Octave 6
    .word   53,   50,   47,   45,   42,   40,   37,   35,   33,   31,   30,   28 # Octave 7
    .word   26,   25,   24,   22,   21,   20,   19,   18,   17,   16,   15,   14 # Octave 8
    .word   13,   12,   12,   11,   11,   10,    9,    9,    8,    8,    7,    7 # Octave 9
    .word    7,    6,    6,    6,    5,    5,    5,    4                         # Octave 10
PLY_AKG_PeriodTable_End:
