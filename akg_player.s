  SkipPSGSend = 1

/*******************************************************************************
 * +                                                                         + *
 *            Arkos Tracker 2 player "generic" player.                         *
 *            By Targhan/Arkos.                                                *
 *            Psg optimization trick on CPC by Madram/Overlanders.             *
 *            Conversion for Elektronika MS-0511 by aberrant_hacker            *
 * +                                                                         + *
 *******************************************************************************/

     # Use hooks for external calls? 0 if the Init/Play/Stop methods are
     # directly called.
     # Will save a few bytes.
     .equiv USE_HOOKS, 0
     # 1 to have the "stop sounds" code. Set it to 0 if you never plan on
     # stopping your music.
     .equiv STOP_SOUNDS, 1
     # 0 to skip some init code/values, saving memory.
     # Possible if you don't plan on restarting your song.
     .equiv FULL_INIT_CODE, 1

     .global PLY_AKG_Init
     .global PLY_AKG_Play
  .if STOP_SOUNDS
     .global PLY_AKG_Stop
  .endif

       .include "akg_player_config.s"

# Agglomerates some flags, because they are treated the same way by this player.
#----------------------------------------------------------------------------{{{
  # Special Track Used?
  .ifdef PLY_CFG_UseSpeedTracks
        UseSpecialTracks = 1
  .endif
  .ifdef PLY_CFG_UseEventTracks
        UseSpecialTracks = 1
  .endif
  # SoftwareOnly and HardOnly share some code.
  .ifdef PLY_CFG_SoftOnly
        UseSoftOnlyOrHardOnly = 1
  .endif
  .ifdef PLY_CFG_HardOnly
        UseSoftOnlyOrHardOnly = 1
  .endif
  # The same for their noise.
  .ifdef PLY_CFG_SoftOnly_Noise
        UseSoftOnlyOrHardOnly_Noise = 1
  .endif
  .ifdef PLY_CFG_HardOnly_Noise
        UseSoftOnlyOrHardOnly_Noise = 1
  .endif

  # Agglomerates the Forced periods (soft/hard).
  .ifdef PLY_CFG_SoftOnly_ForcedSoftwarePeriod
        UseInstrumentForcedPeriods = 1
  .endif
  .ifdef PLY_CFG_HardOnly_ForcedHardwarePeriod
        UseInstrumentForcedPeriods = 1
  .endif
  .ifdef PLY_CFG_SoftToHard_ForcedSoftwarePeriod
        UseInstrumentForcedPeriods = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_ForcedHardwarePeriod
        UseInstrumentForcedPeriods = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_ForcedSoftwarePeriod
        UseInstrumentForcedPeriods = 1
  .endif
  # Agglomerates the Instrument Arpeggios (soft/hard).
  .ifdef PLY_CFG_SoftOnly_SoftwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  .ifdef PLY_CFG_SoftToHard_SoftwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  .ifdef PLY_CFG_HardOnly_HardwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_HardwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_SoftwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_HardwareArpeggio
        UseInstrumentArpeggios = 1
  .endif
  # Agglomerates the Instrument Pitchs (soft/hard).
  .ifdef PLY_CFG_SoftOnly_SoftwarePitch
        UseInstrumentPitchs = 1
  .endif
  .ifdef PLY_CFG_SoftToHard_SoftwarePitch
        UseInstrumentPitchs = 1
  .endif
  .ifdef PLY_CFG_HardOnly_HardwarePitch
        UseInstrumentPitchs = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_HardwarePitch
        UseInstrumentPitchs = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_SoftwarePitch
        UseInstrumentPitchs = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_HardwarePitch
        UseInstrumentPitchs = 1
  .endif
  # Agglomerates the Instrument Forced Periods, Arpeggios and Pitchs (soft/hard).
  .ifdef UseInstrumentForcedPeriods
        UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
  .endif
  .ifdef UseInstrumentArpeggios
        UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
  .endif
  .ifdef UseInstrumentPitchs
        UseInstrumentForcedPeriodsOrArpeggiosOrPitchs = 1
  .endif

  # Agglomerates the Retrig flags for SoftToHard, HardToSoft, SoftAndHard.
  .ifdef PLY_CFG_SoftToHard_Retrig
        UseRetrig_StoH_HtoS_SandH = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_Retrig
        UseRetrig_StoH_HtoS_SandH = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_Retrig
        UseRetrig_StoH_HtoS_SandH = 1
  .endif
  # Agglomerates the noise flags for SoftToHard, HardToSoft, SoftAndHard.
  .ifdef PLY_CFG_SoftToHard_Noise
        UseNoise_StoH_HtoS_SandH = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_Noise
        UseNoise_StoH_HtoS_SandH = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_Noise
        UseNoise_StoH_HtoS_SandH = 1
  .endif
  # Agglomerates the noise flags to know if the code about R6 must be compiled.
  .ifdef PLY_CFG_NoSoftNoHard_Noise
        Use_NoiseRegister = 1
  .endif
  .ifdef PLY_CFG_SoftOnly_Noise
        Use_NoiseRegister = 1
  .endif
  .ifdef PLY_CFG_HardOnly_Noise
        Use_NoiseRegister = 1
  .endif
  .ifdef PLY_CFG_SoftToHard_Noise
        Use_NoiseRegister = 1
  .endif
  .ifdef PLY_CFG_HardToSoft_Noise
        Use_NoiseRegister = 1
  .endif
  .ifdef PLY_CFG_SoftAndHard_Noise
        Use_NoiseRegister = 1
  .endif

  # Agglomerates the effect volume in/out.
  .ifdef PLY_CFG_UseEffect_VolumeIn
        UseEffect_VolumeSlide = 1
  .endif
  .ifdef PLY_CFG_UseEffect_VolumeOut
        UseEffect_VolumeSlide = 1
  .endif

  # Agglomerates the Arpeggios Table effects.
  .ifdef PLY_CFG_UseEffect_Arpeggio3Notes
        PLY_AKS_UseEffect_Arpeggio = 1
  .endif
  .ifdef PLY_CFG_UseEffect_Arpeggio4Notes
        PLY_AKS_UseEffect_Arpeggio = 1
  .endif
  .ifdef PLY_CFG_UseEffect_ArpeggioTable
        PLY_AKS_UseEffect_Arpeggio = 1
  .endif

  # Agglomerates the PitchUp/Down effects.
  .ifdef PLY_CFG_UseEffect_PitchUp
        PLY_AKS_UseEffect_PitchUpOrDown = 1
  .endif
  .ifdef PLY_CFG_UseEffect_PitchDown
        PLY_AKS_UseEffect_PitchUpOrDown = 1
  .endif
  # Agglomerates the PitchUp/Down/Glide effects.
  # IMPORTANT TO NOTE that if there is Glide, there WILL be pitch up/down,
  # because the Glide is embedded in the pitch up/down code.
  .ifdef PLY_AKS_UseEffect_PitchUpOrDown
        PLY_AKS_UseEffect_PitchUpOrDownOrGlide = 1
  .endif
  .ifdef PLY_CFG_UseEffect_PitchGlide
        PLY_AKS_UseEffect_PitchUpOrDownOrGlide = 1
  .endif

  # Agglomerates a special flag combining ArpeggiosTable and PitchTable.
  .ifdef PLY_AKS_UseEffect_Arpeggio
        PLY_AKS_UseEffect_ArpeggioTableOrPitchTable = 1
  .endif
  .ifdef PLY_CFG_UseEffect_PitchTable
        PLY_AKS_UseEffect_ArpeggioTableOrPitchTable = 1
  .endif
#----------------------------------------------------------------------------}}}

       .equiv OPCODE_CLC, 0000241 # Opcode for "or a".
       .equiv OPCODE_SEC, 0000261 # Opcode for "scf".

       .equiv OPCODE_ADD_IMMEDIATE_R5, 0062705 # Opcode ADD (PC)+,R5
       .equiv OPCODE_SUB_IMMEDIATE_R5, 0162705 # Opcode SUB (PC)+,R5
       .equiv OPCODE_ADD_IMMEDIATE_IMMEDIATE, 0062727 # Opcode ADD (PC)+,(PC)+
       .equiv OPCODE_SUB_IMMEDIATE_IMMEDIATE, 0162727 # Opcode SUB (PC)+,(PC)+
       .equiv OPCODE_ADC_R5, 005505 # Opcode ADC R5
       .equiv OPCODE_SBC_R5, 005605 # Opcode SBC R5

        # Includes the sound effects player, if wanted.
        # Important to do it as soon as possible, so that
        # its code can react to the Player Configuration and possibly alter it.
  .ifdef MANAGE_SOUND_EFFECTS
       .include "akg_sound_effects.s"
  .endif # MANAGE_SOUND_EFFECTS
        # [[INSERT_SOUND_EFFECT_SOURCE]] # A tag for test units.
                                         # Don't touch or you're dead.

# Initializes the player.
# IN:   R5 = music address.
#       R0 = subsong index (>=0).
PLY_AKG_Init: #--------------------------------------------------------------{{{
  .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC
        ADD  $4,R5 # Skip the tag
    .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:432
        MOV  (R5)+, @$ArpeggiosTable
    .else
        INC  R5
        INC  R5
    .endif # PLY_AKS_UseEffect_Arpeggio

    .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:440
        MOV  (R5)+, @$PitchesTable
    .else
        INC  R5
        INC  R5
    .endif # PLY_CFG_UseEffect_PitchTable
  .else # No effects.
        ADD  $4+2+2,R5 # Skips the tag and the arp/pitch table.
  .endif # PLY_CFG_UseEffects

        MOV  (R5), @$InstrumentsTable1
        MOV  (R5), @$InstrumentsTable2
        MOV  (R5)+,@$InstrumentsTable3

  .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:456
        MOV  (R5)+,R3
        MOV  R3,@$Channel_ReadEffects_EffectBlocks1
        MOV  R3,@$Channel_ReadEffects_EffectBlocks2
  .else # No effects.
        INC  R5
        INC  R5 # Skips the effect block table.
  .endif # PLY_CFG_UseEffects

        # We have reached the Subsong addresses. Which one to use?
        ASL  R0
        ADD  R0,R5

        MOV  (R5),R5 # R5 points on the Subsong metadata.
        ADD  $5,R5   # Skips the replay frequency, digichannel, psg count, loop start index, end index.
        MOVB (R5)+,@$CurrentSpeed
        MOVB (R5)+,@$BaseNoteIndex

        INC  R5 # align on word boundary, kind of
        MOV  R5,@$ReadLinker_PtLinker

        # Initializes values. You can remove this part if you don't stop/restart your song.
  .if FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:492
        MOV  $InitTable0,R5
       .set words_count, (InitTable0_End - InitTable0) >> 1
        MOV  $words_count + 1,R1
        CLR  R2
        CALL Init_ReadWordsAndFill

        MOV  $InitTable1,R5
       .set words_count, (InitTable1_End - InitTable1) >> 1
        MOV  $words_count + 1,R1
        INC  R2
        CALL Init_ReadWordsAndFill

        MOV  $InitTableOrA,R5
       .set words_count, (InitTableOrA_End - InitTableOrA) >> 1
        MOV  $words_count + 1,R1
        MOV  $OPCODE_CLC,R2 # CLC opcode
        CALL Init_ReadWordsAndFill

    .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:511
      .error
    .endif
  .endif # FULL_INIT_CODE

        # Stores the address to the empty instrument *data* (header skipped).
        MOV  @$InstrumentsTable1,R5
        MOV  (R5),R5
        INC  R5 # Skip the header
        MOV  R5,@$EmptyInstrumentDataPt
        # Sets all the instrument to "empty".
        MOV  R5,@$Channel1_PtInstrument
        MOV  R5,@$Channel2_PtInstrument
        MOV  R5,@$Channel3_PtInstrument

        # If sound effects, clears the SFX state.
  .ifdef MANAGE_SOUND_EFFECTS # playerAkg/sources/PlayerAkg.asm:550
        CLR  @$Channel1_SoundEffectData
        CLR  @$Channel2_SoundEffectData
        CLR  @$Channel3_SoundEffectData
  .endif # MANAGE_SOUND_EFFECTS

RETURN # Init #--------------------------------------------------------------}}}

  .if FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:559 #-----------------{{{
        # Fills all the read addresses with a byte.
        # IN:    R5 = table where the addresses are.
        #        R1 = how many items in the table + 1.
        #        R2 = byte to fill.
Init_ReadWordsAndFill_Loop:
        MOV  R2,@(R5)+
Init_ReadWordsAndFill:
        SOB  R1,Init_ReadWordsAndFill_Loop

        RETURN

# Table initializing some data with 0.
InitTable0: # playerAkg/sources/PlayerAkg.asm:576
       .word Channel1_InvertedVolumeIntegerAndDecimal
       .word Channel2_InvertedVolumeIntegerAndDecimal
       .word Channel3_InvertedVolumeIntegerAndDecimal

    .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC
       .word Channel1_Pitch
       .word Channel2_Pitch
       .word Channel3_Pitch
    .endif #PLY_AKS_UseEffect_PitchUpOrDown

    .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC
       .word Retrig
    .endif #PLY_CFG_UseRetrig
InitTable0_End:

InitTable1: # playerAkg/sources/PlayerAkg.asm:598
       .word PatternDecreasingHeight
       .word TickDecreasingCounter
InitTable1_End:

InitTableOrA: # playerAkg/sources/PlayerAkg.asm:605 #------------------------{{{
    .ifdef UseEffect_VolumeSlide   # CONFIG SPECIFIC
       .word Channel1_IsVolumeSlide
       .word Channel2_IsVolumeSlide
       .word Channel3_IsVolumeSlide
    .endif # UseEffect_VolumeSlide
    .ifdef PLY_AKS_UseEffect_Arpeggio      # CONFIG SPECIFIC
       .word Channel1_IsArpeggioTable
       .word Channel2_IsArpeggioTable
       .word Channel3_IsArpeggioTable
    .endif # PLY_AKS_UseEffect_Arpeggio
    .ifdef PLY_CFG_UseEffect_PitchTable    # CONFIG SPECIFIC
       .word Channel1_IsPitchTable
       .word Channel2_IsPitchTable
       .word Channel3_IsPitchTable
    .endif # PLY_CFG_UseEffect_PitchTable
    .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC
       .word Channel1_IsPitch
       .word Channel2_IsPitch
       .word Channel3_IsPitch
    .endif # PLY_AKS_UseEffect_PitchUpOrDown
InitTableOrA_End: #----------------------------------------------------------}}}
  .endif # FULL_INIT_CODE # playerAkg/sources/PlayerAkg.asm:629 #------------}}}

  .if STOP_SOUNDS # playerAkg/sources/PlayerAkg.asm:654 #--------------------{{{
        # Stops the music.
        # This code can be removed if you don't intend to stop it!
PLY_AKG_Stop:
        # Only useful because the SendPSGRegisters restores it at the end.
        MOV  SP,@$SaveSP
        CLRB @$PSGReg8
        CLR  @$PSGReg9_10_Instr
        MOV  $0b00111111, @$PSGReg7
        JMP  SendPSGRegisters
  .endif # STOP_SOUNDS #-----------------------------------------------------}}}


################################################################################
#                      Plays one frame of the subsong.                         #
################################################################################
PLY_AKG_Play: # playerAkg/sources/PlayerAkg.asm:676 #
        MTPS $PR7
        MOV  SP,@$SaveSP

  .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
    .error
  .endif # PLY_CFG_UseEventTracks

        # Decreases the tick counter. If 0 is reached, a new line must be read.
        MOV  (PC)+,R0; TickDecreasingCounter: .word 1
        DEC  R0
        BZE  new_line$
        # Jumps if there is no new line: continues playing the sound stream.
        JMP  SetSpeedBeforePlayStreams

new_line$:
        # New line! Is the Pattern ended?
        # Not as long as there are lines to read.
        MOV  (PC)+,R0; PatternDecreasingHeight: .word 1
        DEC  R0
        BZE  new_pattern$ # pattern ended
        # Jumps if the pattern isn't ended.
        JMP  SetCurrentLineBeforeReadLine

new_pattern$:
        # New pattern!
        # Reads the Linker. This is called at the start of the song,
        # or at the end of every position.
ReadLinker: # playerAkg/sources/PlayerAkg.asm:704
        MOV  (PC)+,SP; ReadLinker_PtLinker: .word 0
        # Reads the address of each Track.
        MOV  (SP)+,R5
        BNZ  ReadLinker_NoLoop
        # End of the song.
        MOV  (SP)+,SP # read loop address
        MOV  (SP)+,R5 # Reads once again the address of Track 1, in the pattern looped to.
ReadLinker_NoLoop: # playerAkg/sources/PlayerAkg.asm:720
        MOV  R5,@$Channel1_PtTrack
        MOV  (SP)+,@$Channel2_PtTrack
        MOV  (SP)+,@$Channel3_PtTrack
        # Reads the address of the LinkerBlock.
        MOV  (SP)+,R5
        MOV  SP,@$ReadLinker_PtLinker
        MOV  R5,SP

        # Reads the LinkerBlock. SP = LinkerBlock.
        # Reads the height and transposition1.
        MOV  (SP)+,R5
        CLR  R2
        BISB R5,R2 # Height

  .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
        SWAB R5
        MOVB R5,R0 # can be negative, sign extension is required
        MOV  R0,@$Channel1_Transposition
  .endif # PLY_CFG_UseTranspositions

        # Reads the transposition2 and 3.
  .ifdef UseSpecialTracks # CONFIG SPECIFIC #--------------------------------{{{
    .ifndef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
        # Transpositions not used? We could stop here.
        # BUT the SpecialTracks, if present, must access their data after.
        # So in this case, the transpositions must be skipped.
        MOV  (SP)+,R5
    .endif # PLY_CFG_UseTranspositions
  .endif # UseSpecialTracks #------------------------------------------------}}}

  .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:747
        # MOVB (SP)+,dst autoincrements SP by 2 anyway
        MOV  (SP)+,R5
        MOVB R5,R0 # can be negative, sign extension is required
        MOV  R0,@$Channel2_Transposition
        SWAB R5
        MOVB R5,R0 # can be negative, sign extension is required
        MOV  R0,@$Channel3_Transposition
  .endif # PLY_CFG_UseTranspositions

  .ifdef UseSpecialTracks # CONFIG SPECIFIC #--------------------------------{{{
        # Reads the special Tracks addresses.
        # Must be performed even SpeedTracks not used, because EventTracks might
        # be present, the word must be skipped.
        MOV  (SP)+,R5
    # Reads the special Tracks addresses.
    .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC
        MOV  R5, @$SpeedTrack_PtTrack
    .endif # PLY_CFG_UseSpeedTracks

    .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
        MOV  (SP)+,R5
        MOV  R5, @$EventTrack_PtTrack
    .endif # PLY_CFG_UseEventTracks
  .endif # UseSpecialTracks #------------------------------------------------}}}

        # Forces the reading of every Track and Special Track.
  .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC #--------------------------{{{
        CLR  @$SpeedTrack_WaitCounter
  .endif # PLY_CFG_UseSpeedTracks #------------------------------------------}}}

  .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC #--------------------------{{{
        CLR  @$EventTrack_WaitCounter
  .endif # PLY_CFG_UseEventTracks #------------------------------------------}}}

        CLR  @$Channel1_WaitCounter
        CLR  @$Channel2_WaitCounter
        CLR  @$Channel3_WaitCounter
        MOV  R2,R0
SetCurrentLineBeforeReadLine: # playerAkg/sources/PlayerAkg.asm:779
        MOV  R0,@$PatternDecreasingHeight


        # Reads the new line (notes, effects, Special Tracks, etc.).
ReadLine: # playerAkg/sources/PlayerAkg.asm:784
        # Reads the Speed Track.
  .ifdef PLY_CFG_UseSpeedTracks # CONFIG SPECIFIC
        # playerAkg/sources/PlayerAkg.asm:786 #------------------------------{{{
        MOV  (PC)+,R0; SpeedTrack_WaitCounter: .word 0 # Lines to wait?
        SUB  $1,R0
        BCC  SpeedTrack_MustWait # Jump if there are still lines to wait.
        # No more lines to wait. Reads a new data.
        # It may be an event value or a wait value.
        MOV  (PC)+,R5; SpeedTrack_PtTrack: .word 0
        CLR  R0
        BISB (R5)+,R0
        ASR  R0 # Bit 0: wait?
        # Jump if wait: R0 is the wait value.
        BCS  SpeedTrack_StorePointerAndWaitCounter
        # Value found. If 0, escape value (rare).
        BNZ  SpeedTrack_NormalValue
        # Escape code. Reads the right value.
        MOVB (R5)+,R0
SpeedTrack_NormalValue:
        MOVB R0,@$CurrentSpeed

        CLR  R0 # Next time, a new value is read.
SpeedTrack_StorePointerAndWaitCounter:
        MOV  R5,@$SpeedTrack_PtTrack
SpeedTrack_MustWait:
        MOV  R0,@$SpeedTrack_WaitCounter
SpeedTrack_End:
  .endif # PLY_CFG_UseSpeedTracks #------------------------------------------}}}

        # Reads the Event Track.
        #--------------------------------------------------------------------{{{
  .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC
    .error # playerAkg/sources/PlayerAkg.asm:828
  .endif # PLY_CFG_UseEventTracks #------------------------------------------}}}


       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Reads the possible Cell of the Channel 1, 2 and 3.        *
        * Use a Macro for each channel, but the code is duplicated. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro ReadTrack cN # playerAkg/sources/PlayerAkg.asm:873 #------------------{{{
        # Lines to wait?
        DECB (PC)+; Channel\cN\()_WaitCounter: .word 0
        BMI  Channel\cN\()_ReadTrack
        # Still some lines to wait.
        JMP  Channel\cN\()_ReadCellEnd

Channel\cN\()_ReadTrack: # playerAkg/sources/PlayerAkg.asm:886
        # Points on the Cell to read.
        MOV  (PC)+,R5; Channel\cN\()_PtTrack: .word 0
        # Reads note data. It can be a note, a wait...

        CLR  R2
        BISB (R5)+,R2 # R2 = data (b5-0) + effect? (b6) + new Instrument? (b7).
        MOV  R2,R0
        BIC  $0xFFC0,R0 # R0 = data
        # 0-59: note.
        # "CMP" is preferred to "SUB" so that the "note" branch (the slowest) is note-ready.
        CMP  R0,$60
        BLO  Channel\cN\()_Note
        SUB  $60,R0
       .jmp  EQ, Channel\cN\()_MaybeEffects # 60 = no note, but maybe effects.
        DEC  R0
        BZE  Channel\cN\()_Wait             # 61 = wait, no effect.
        DEC  R0
        BZE  Channel\cN\()_SmallWait        # 62 = small wait, no effect.
        # 63 = escape code for note, maybe effects.
        # Reads the note in the next byte
        CLR  R0
        BISB (R5)+,R0
        BR   Channel\cN\()_AfterNoteKnown

        # Small wait, no effect.
Channel\cN\()_SmallWait: # playerAkg/sources/PlayerAkg.asm:914
        ASH  $-6,R2 # Uses bit 6/7 to indicate how many lines to wait.
        INC  R2 # This wait start at 2 lines, to 5.
        MOV  R2,@$Channel\cN\()_WaitCounter
        BR   Channel\cN\()_BeforeEnd_StoreCellPointer

        # Wait, no effect.
Channel\cN\()_Wait: # playerAkg/sources/PlayerAkg.asm:924
        # Reads the wait value on the next byte (HL has already been incremented).
        MOVB (R5)+,@$Channel\cN\()_WaitCounter
        BR   Channel\cN\()_BeforeEnd_StoreCellPointer

        # Little subcode put here, called just below. A bit dirty, but avoids long jump.
Channel\cN\()_SameInstrument: # playerAkg/sources/PlayerAkg.asm:931
        # No new instrument. The instrument pointer must be reset.
        MOV  (PC)+,@(PC)+
        Channel\cN\()_PtBaseInstrument:
       .word 0, Channel\cN\()_PtInstrument
        BR   Channel\cN\()_AfterInstrument

        # A note has been found, plus maybe an Instrument and effects.
        # R0 = note. R2 = still has the New Instrument/Effects flags.
Channel\cN\()_Note: # playerAkg/sources/PlayerAkg.asm:943
    # Declares this only for the first channel, else refers to it.
  .if \cN == 1
        # The encoded note is only from a 4 octave range, but the first note
        # depends on the best window, determined by the song generator.
        ADD  (PC)+,R0; BaseNoteIndex: .word 0
  .else
        ADD  @$BaseNoteIndex,R0
  .endif

Channel\cN\()_AfterNoteKnown: # playerAkg/sources/PlayerAkg.asm:957
  .ifdef PLY_CFG_UseTranspositions # CONFIG SPECIFIC
        # Adds the Track transposition.
        ADD  (PC)+,R0; Channel\cN\()_Transposition: .word 0
  .endif # PLY_CFG_UseTranspositions

        MOV  R0,@$Channel\cN\()_TrackNote

        # R5 = next data. R2 = data byte.
        ROLB R2 # New Instrument?
        BCC  Channel\cN\()_SameInstrument
        # Gets the new Instrument.
        MOVB (R5)+,R4 # NOTE: 127 instruments supported only

        ASL  R4
        MOV  0(R4),R4
        # Points on the Instruments table of the music (set on song initialization).
       .equiv InstrumentsTable\cN, .-2

        # No need to store an "original speed" if "force instrument speed"
        # effect is not used.
  .ifdef PLY_CFG_UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC
        MOVB (R4)+,@$Channel\cN\()_InstrumentOriginalSpeed
  .else
        MOVB (R4)+,@$Channel\cN\()_InstrumentSpeed
  .endif # PLY_CFG_UseEffect_ForceInstrumentSpeed

        MOV  R4,@$Channel\cN\()_PtInstrument
        # Useful when playing another note with the same instrument.
        MOV  R4,@$Channel\cN\()_PtBaseInstrument


Channel\cN\()_AfterInstrument: # playerAkg/sources/PlayerAkg.asm:1008
        # There is a new note. The instrument pointer has already been reset.
        # -------------------------------------------------------------------
        # Instrument number is set.
        # Arpeggio and Pitch Table are reset.

        # The track pitch and glide, instrument step are reset.
  .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC #----------{{{
        CLR  @$Channel\cN\()_Pitch
        MOV  $OPCODE_CLC, @$Channel\cN\()_IsPitch
  .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide #--------------------------}}}

        # Resets the speed of the Arpeggio and the Pitch.
  .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC #----------------------{{{
        CLR  @$Channel\cN\()_ArpeggioTableCurrentStep
        # Resets the speed of the Arpeggio
        MOV  @$Channel\cN\()_ArpeggioBaseSpeed, @$Channel\cN\()_ArpeggioTableSpeed
        # Points to the first value of the Arpeggio.
        MOV  @$Channel\cN\()_ArpeggioTableBase, @$Channel\cN\()_ArpeggioTable
  .endif # PLY_AKS_UseEffect_Arpeggio #--------------------------------------}}}

  .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC #--------------------{{{
        CLR  @$Channel\cN\()_PitchTableCurrentStep
        # Resets the speed of the Pitch.
        MOV  @$Channel\cN\()_PitchBaseSpeed, @$Channel\cN\()_PitchTableSpeed
        # Points to the first value of the Pitch.
        MOV  @$Channel\cN\()_PitchTableBase, @$Channel\cN\()_PitchTable
  .endif # PLY_CFG_UseEffect_PitchTable #------------------------------------}}}

        CLR  @$Channel\cN\()_InstrumentStep

    # If the "force instrument speed" effect is used,
    # the instrument speed must be reset to its original value.
  .ifdef PLY_CFG_UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC #----------{{{
    .error
        MOV  (PC)+,@(PC)+;
        Channel\cN\()_InstrumentOriginalSpeed:
       .word 0, Channel\cN\()_InstrumentSpeed
  .endif # PLY_CFG_UseEffect_ForceInstrumentSpeed #--------------------------}}}


  .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC
        # Effects?
        ROLB R2
       .jmp  CS, Channel\cN\()_ReadEffects
  .endif # PLY_CFG_UseEffects

        # No effects. Nothing more to read for this cell.
Channel\cN\()_BeforeEnd_StoreCellPointer:
        MOV  R5, @$Channel\cN\()_PtTrack
Channel\cN\()_ReadCellEnd:

.endm # ReadTrack # playerAkg/sources/PlayerAkg.asm:1081 #-------------------}}}

        # Generates the code for each channel, from the macro above.
        ReadTrack 1
        ReadTrack 2
        ReadTrack 3



        MOV  (PC)+,R0; CurrentSpeed: .word 0
SetSpeedBeforePlayStreams: # playerAkg/sources/PlayerAkg.asm:1104
        MOV  R0,@$TickDecreasingCounter



        /* * * * * * * * * * * * * * * * * * * * * * * * * * *
         * Applies the trailing effects for channel 1, 2, 3. *
         * Uses a macro instead of duplicating the code.     *
         * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro ApplyTrailingEffects cN #---------------------------------------------{{{

        # Use Volume slide?
        #----------------------------
        MOV  (PC)+,R5; Channel\cN\()_InvertedVolumeIntegerAndDecimal: .word 0

        # playerAkg/sources/PlayerAkg.asm:1127
  .equiv Channel\cN\()_InvertedVolumeInteger, Channel\cN\()_InvertedVolumeIntegerAndDecimal + 1

  .ifdef UseEffect_VolumeSlide # CONFIG SPECIFIC #---------------------------{{{
       .error "724"
        # Is there a Volume Slide ?
        # Automodified. SEC if yes, CLC if not.
      Channel\cN\()_IsVolumeSlide:
        CLC
        BCC  Channel\cN\()_VolumeSlide_End

        ADD  (PC)+,R5
        Channel\cN\()_VolumeSlideValue: .word 0 # May be negative.
        BVC  Channel\cN\()_VolumeNotOverflow
        # Went below 0
        CLR  R5
        BR   Channel\cN\()_VolumeSetAgain

Channel\cN\()_VolumeNotOverflow:
        # Higher than 15?
        SWAB R5
        CMPB R5,$15
        BLOS Channel\cN\()_VolumeSetAgain
        CLRB R5
        BISB $15,R5
Channel\cN\()_VolumeSetAgain:
        SWAB R5
        MOV  R5,@$Channel\cN\()_InvertedVolumeIntegerAndDecimal
Channel\cN\()_VolumeSlide_End:
  .endif # UseEffect_VolumeSlide #-------------------------------------------}}}

        SWAB R5
        MOVB R5,@$Channel\cN\()_GeneratedCurrentInvertedVolume

        # Use Arpeggio table? OUT: R2 = value.
        #----------------------------------------
  .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1169 {{{
        CLR  R2
Channel\cN\()_IsArpeggioTable:
        CLC # Is there an arpeggio table? Automodified. SEC if yes, CLC if not.
        BCC Channel\cN\()_ArpeggioTable_End

        # We can read the Arpeggio table for a new value.
        MOV  (PC)+,R5
        Channel\cN\()_ArpeggioTable: .word 0 # Points on the data, after the header.
        MOVB (R5)+,R2 # Reads the value.
        CMP  R2,$-128 # Loop?
        BNE  Channel\cN\()_ArpeggioTable_AfterLoopTest
        # Loop. Where to?
        INC  R5 # align at word boundary
        MOV  (R5),R5

        MOVB (R5),R2 # Reads the value. Safe, we know there is no loop here.

        # R5 = pointer on what is follows.
        # R2 = value to use.
Channel\cN\()_ArpeggioTable_AfterLoopTest:
        # Checks the speed.
        # If reached, the pointer can be saved to read a new value next time.
        MOV  (PC)+,R0; Channel\cN\()_ArpeggioTableCurrentStep: .word 0
        INC  R0
        CMP  R0,@$Channel\cN\()_ArpeggioTableSpeed # From 1 to 256.
        # The current step may be higher than the limit if
        # Force Speed effect is used.
        BLO  Channel\cN\()_ArpeggioTable_BeforeEnd_SaveStep
        # Stores the pointer to read a new value next time.
        MOV  R5,@$Channel\cN\()_ArpeggioTable

        CLR  R0
Channel\cN\()_ArpeggioTable_BeforeEnd_SaveStep:
        MOV  R0,@$Channel\cN\()_ArpeggioTableCurrentStep
Channel\cN\()_ArpeggioTable_End:
  .endif # PLY_AKS_UseEffect_Arpeggio #--------------------------------------}}}


        # Use Pitch table? OUT: R3 = pitch value.
        # R2 must NOT be modified!
        #-----------------------
        CLR  R3 # Default value.

  .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC #--------------------{{{
        # playerAkg/sources/PlayerAkg.asm:1232
Channel\cN\()_IsPitchTable:
        CLC  # Is there an pitch table? Automodified. SEC if yes, CLC if not.
        BCC  Channel\cN\()_PitchTable_End

        MOV  (PC)+,R5 # Read the Pitch table for a value.
        Channel\cN\()_PitchTable: .word 0
        MOV  (R5)+,R3 # Reads the value.
        MOV  (R5),R5  # Reads the pointer to the next value. Manages the loop automatically!

        # Checks the speed.
        # If reached, the pointer can be saved (advance in the Pitch).
        MOV  (PC)+,R0
        Channel\cN\()_PitchTableCurrentStep: .word 0
        INC  R0
        CMPB R0,@$Channel\cN\()_PitchTableSpeed # From 1 to 256.
        # The current step may be higher than the limit if Force Speed effect is used.
        BLO  Channel\cN\()_PitchTable_BeforeEnd_SaveStep
        # Advances in the Pitch.
        MOV  R5,@$Channel\cN\()_PitchTable

        CLR  R0
Channel\cN\()_PitchTable_BeforeEnd_SaveStep:
        MOV  R0,@$Channel\cN\()_PitchTableCurrentStep
Channel\cN\()_PitchTable_End:
  .endif # PLY_CFG_UseEffect_PitchTable #------------------------------------}}}

        # Pitch management. The Glide is embedded, but relies on the Pitch
        # (Pitch can exist without Glide, but Glide can not without Pitch).
        # Do NOT modify R2 or R3.
        #-----------------------------------------------------------------------
  .ifndef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
        # playerAkg/sources/PlayerAkg.asm:1276

        CLR  R5 # No pitch.
        # Some dirty duplication in case there is no pitch up/down/glide.
        # The "real" vars are a bit below.

# Put here, no need for better place (see the real label below, with the same name).
Channel\cN\()_SoundStream_RelativeModifierAddress:

    .ifdef PLY_AKS_UseEffect_ArpeggioTableOrPitchTable # CONFIG SPECIFIC #---{{{
        BR   Channel\cN\()_AfterArpeggioPitchVariables
      .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1284 {{{
Channel\cN\()_ArpeggioTableSpeed: .word 0
Channel\cN\()_ArpeggioBaseSpeed: .word 0
Channel\cN\()_ArpeggioTableBase: .word 0
      .endif # PLY_AKS_UseEffect_Arpeggio #----------------------------------}}}

      .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:1291 {{{
Channel\cN\()_PitchTableSpeed: .word 0
Channel\cN\()_PitchBaseSpeed: .word 0
Channel\cN\()_PitchTableBase: .word 0
      .endif # PLY_CFG_UseEffect_PitchTable #--------------------------------}}}
Channel\cN\()_AfterArpeggioPitchVariables:
    .endif # PLY_AKS_UseEffect_ArpeggioTableOrPitchTable #-------------------}}}
  .else # PLY_AKS_UseEffect_PitchUpOrDownOrGlide # playerAkg/sources/PlayerAkg.asm:1301
        MOV  (PC)+,R5; Channel\cN\()_Pitch: .word 0 # #----------------------{{{

Channel\cN\()_IsPitch:
        CLC # Is there a Pitch? Automodified. SEC if yes, CLC if not.
        BCC  Channel\cN\()_Pitch_End

        # R2 must NOT be modified, stores it.
    .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
        # NOTE: в оригинале, содержимое C сохраняется в
        # Channel\cN\()_GeneratedCurrentArpNote в самом конце
        # ApplyTrailingEffects, и больше нигде не используется
        # почему нельзя было сохранить прям отсюда???
       #ld ixl,c
        # R2 ниже нигде не изменятся и тоже сохраняется в
        # самом конце макроса
    .endif # PLY_AKS_UseEffect_Arpeggio

Channel\cN\()_PitchTrackAddOrSub:
        ADD  (PC)+,R5 # WILL BE AUTOMODIFIED to ADD or SUB
        # Value from the user. ALWAYS POSITIVE. Does not evolve. MSB is always 0.
        Channel\cN\()_PitchTrack: .word 0

        # Makes the decimal part evolves.
        # Value from the user.
Channel\cN\()_PitchTrackDecimalInstr:
        ADD  (PC)+,(PC)+ #  WILL BE AUTOMODIFIED to ADD or SUB.
        Channel\cN\()_PitchTrackDecimalValue: .word 0
        # the label is present in original code
        # but here it acts as a commentary
        # the only result we use down below is the carry flag
        Channel\cN\()_PitchTrackDecimalCounter: .word 0

Channel\cN\()_PitchTrackIntegerAdcOrSbc:
        ADC  R5 # WILL BE AUTOMODIFIED to ADC or SBC

        MOV  R5,@$Channel\cN\()_Pitch

        # This must be placed at the any location to allow reaching
        # the variables via R2/R3
Channel\cN\()_SoundStream_RelativeModifierAddress:

    .ifdef PLY_CFG_UseEffect_PitchGlide # CONFIG SPECIFIC #------------------{{{
        # playerAkg/sources/PlayerAkg.asm:1360
        # Glide?
        # 0 = no glide. 1 = glide/pitch up. 2 = glide/pitch down.
        MOV  (PC)+,R0; Channel\cN\()_GlideDirection: .word 0
        # Is there a Glide?
        BZE  Channel\cN\()_Glide_End

        MOV  R5,R4

        MOV  @$Channel\cN\()_TrackNote, R1
        ASLB R1
        ADD  PeriodTable(R1),R4
        # R4 is now the current period (track pitch + note period).

        # Period to reach (note given by the user, converted to period).
        MOV  (PC)+,R1; Channel\cN\()_GlideToReach: .word 0

        # Have we reached the glide destination?
        # Depends on the direction.
        RORB R0
        BCC  Channel\cN\()_GlideDownCheck

        # Glide up. Check.
        # The glide period should be lower than the current pitch.
        SUB  R1,R4
        # If not reached yet, continues the pitch.
        BCC  Channel\cN\()_Glide_End
        BR   Channel\cN\()_GlideOver

Channel\cN\()_GlideDownCheck:
        # The glide period should be higher than the current pitch.
        SUB  R1,R4
        # If not reached yet, continues the pitch.
        BCS  Channel\cN\()_Glide_End

Channel\cN\()_GlideOver:
        # The glide is over. However, it may be over, so we can't simply use
        # the current pitch period. We have to set the exact needed value.
        MOV  R1,R5
        MOV  @$Channel\cN\()_TrackNote, R1
        ASLB R1
        SUB  PeriodTable(R1),R5

        MOV  R5,Channel\cN\()_Pitch
        MOV  $OPCODE_CLC,@$Channel\cN\()_IsPitch

        BR   Channel\cN\()_Glide_End
        #--------------------------------------------------------------------}}}
    .else # PLY_CFG_UseEffect_PitchGlide not defined
        # Skips the variables below, if there are present.
      .ifdef PLY_AKS_UseEffect_ArpeggioTableOrPitchTable # CONFIG SPECIFIC
        BR   Channel\cN\()_AfterArpeggioPitchVariables
      .endif # PLY_AKS_UseEffect_ArpeggioTableOrPitchTable
    .endif # PLY_CFG_UseEffect_PitchGlide # playerAkg/sources/PlayerAkg.asm:1429

        # A small place to stash some vars which have to be within relative
        # range. Dirty, but no choice.
        # Note that the vars just below are duplicated due to the conditional
        # assembling (they are a bit above).
    .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC #--------------------{{{
Channel\cN\()_ArpeggioTableSpeed: .word 0
Channel\cN\()_ArpeggioBaseSpeed: .word 0
Channel\cN\()_ArpeggioTableBase: .word 0
    .endif # PLY_AKS_UseEffect_Arpeggio #------------------------------------}}}

    .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC #------------------{{{
Channel\cN\()_PitchTableSpeed: .word 0
Channel\cN\()_PitchBaseSpeed: .word 0
Channel\cN\()_PitchTableBase: .word 0
    .endif # PLY_CFG_UseEffect_PitchTable #----------------------------------}}}

Channel\cN\()_AfterArpeggioPitchVariables:

    .ifdef PLY_CFG_UseEffect_PitchGlide # CONFIG SPECIFIC #------------------{{{
Channel\cN\()_Glide_End:
    .endif # PLY_CFG_UseEffect_PitchGlide #----------------------------------}}}

Channel\cN\()_Pitch_End:
        #--------------------------------------------------------------------}}}
  .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide # playerAkg/sources/PlayerAkg.asm:1466

        ADD  R3,R5 # Adds the Pitch Table value.
        MOV  R5,@$Channel\cN\()_GeneratedCurrentPitch

  .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
        MOV  R2,@$Channel\cN\()_GeneratedCurrentArpNote
  .endif # PLY_AKS_UseEffect_Arpeggio

.endm #----------------------------------------------------------------------}}}

        ApplyTrailingEffects 1
        ApplyTrailingEffects 2
        ApplyTrailingEffects 3



        # The stack must NOT be diverted during the Play Streams!
        MOV  @$SaveSP,SP # playerAkg/sources/PlayerAkg.asm:1496
        MTPS $PR0

       /* * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Plays the instrument on channel 1, 2, 3.          *
        * The PSG registers related to the channels are set.*
        * A macro is used instead of duplicating the code.  *
        * * * * * * * * * * * * * * * * * * * * * * * * * * */

.macro PlayInstrument cN # playerAkg/sources/PlayerAkg.asm:1504 #------------{{{
# This must be placed at the any location to allow reaching the variables via IX/IY.
Channel\cN\()_PlayInstrument_RelativeModifierAddress:

        # What note to play?
        # The pitch to add to the real note,
        # according to the Pitch Table + Pitch/Glide effect.
        MOV  (PC)+,R4; Channel\cN\()_GeneratedCurrentPitch: .word 0

  .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
        MOV  (PC)+,R3; Channel\cN\()_TrackNote: .word 0
        # Adds the arpeggio value.
        ADD  (PC)+,R3; Channel\cN\()_GeneratedCurrentArpNote: .word 0
        # the most significat byte has to be cleared if result is negative
        BIC  $0xFF00,R3
  .else # PLY_AKS_UseEffect_Arpeggio
        # Not automodified, stays this way.
        MOV  (PC)+,R3; Channel\cN\()_TrackNote: .word 0
  .endif # PLY_AKS_UseEffect_Arpeggio

        # playerAkg/sources/PlayerAkg.asm:1539

  .ifdef PLY_CFG_UseRetrig
    .error
        MOV  (PC)+, @(PC)+
        Channel\cN\()_InstrumentStep:
       .word 0, R_Retrig
  .endif # PLY_CFG_UseRetrig

        # Instrument data to read (past the header).
        MOV  (PC)+,R5; Channel\cN\()_PtInstrument: .word 0
        MOV  (PC)+,R2; Channel\cN\()_GeneratedCurrentInvertedVolume: .word 15
  .if \cN == 1
        # For the first channel, sets the R7 value to no noise, all channel on
        # by default ().
        MOV  $0b11100000, @$PSGReg7
  .endif

        # PSGReg7  = Reg7
        # R2   = inverted volume.
        # R3   = note (instrument + Track transposition).
        # R4   = track pitch.
        # R5   = PtInstrument

        CALL ReadInstrumentCell # playerAkg/sources/PlayerAkg.asm:1567

        # The new and increased Instrument pointer is stored only if its speed
        # has been reached. (>0)
  .ifdef PLY_CFG_UseRetrig
    .error
        MOV  @(PC)+,R0
        R_Retrig: .word 0
  .else
        MOV  (PC)+,R0
        Channel\cN\()_InstrumentStep: .word 0
  .endif # PLY_CFG_UseRetrig

        INC  R0
        # playerAkg/sources/PlayerAkg.asm:1577
        CMP  R0,(PC)+; Channel\cN\()_InstrumentSpeed: .word 0
        # Checks C, not only NZ because since the speed can be changed via
        # an effect, the step can get beyond the limit, this must be taken
        # in account.
        BLO  Channel\cN\()_SetInstrumentStep
        # The speed is reached. We can go to the next line on the next frame.
        MOV  R5, @$Channel\cN\()_PtInstrument
        CLR  R0
Channel\cN\()_SetInstrumentStep: # # playerAkg/sources/PlayerAkg.asm:1585
        MOV  R0, @$Channel\cN\()_InstrumentStep

        # Saves the software period and volume for the PSG to send later.
  .if \cN == 1
        MOV  R3, @$PSGReg01_Instr
        MOVB R2, @$PSGReg8
  .elseif \cN == 2
        MOV  R3, @$PSGReg23_Instr
        MOVB R2, @$PSGReg9
  .elseif \cN == 3
        MOV  R3, @$PSGReg45_Instr
        MOVB R2, @$PSGReg10
  .endif

  .if \cN != 3
        RORB  @$PSGReg7
  .endif
.endm # PlayInstrument ------------------------------------------------------}}}

        # Generates the code for all channels using the macro above.
        PlayInstrument 1
        PlayInstrument 2
       .list
        PlayInstrument 3
       .nolist

# Plays the sound effects, if desired.
#-------------------------------------------
  .ifdef MANAGE_SOUND_EFFECTS # playerAkg/sources/PlayerAkg.asm:1638
       .error
        # IN : A = R7
        # OUT: A = R7, possibly modified.
        CALL PlaySoundEffectsStream
  .endif # MANAGE_SOUND_EFFECTS

/*  -----------------------------------------------------------------------
                               PSG access.
    -----------------------------------------------------------------------  */
# Sends the registers to the PSG. Only general registers are sent,
# the specific ones have already been sent.
SendPSGRegisters: # playerAkg/sources/PlayerAkg.asm:1652 # ------------------{{{
     .ifdef SkipPSGSend
        JMP  end_of_the_send
     .else
        NOP
        NOP
     .endif

        MOV  $0177360,R4
        MOV  $PSGReg01_Instr,R5

        CLR  R3
        MOV  R3,(R4)    # Register 0: Channel A Tone Period
        MOVB (R5)+,(R4) # Value: 8-bit fine tune A

        INC  R3
        MOV  R3,(R4)    # Register 1: Channel A Tone Period
        MOVB (R5)+,(R4) # Value: 4-bit coarse tune A

        INC  R3
        MOV  R3,(R4)    # Register 2: Channel B Tone Period
        MOVB (R5)+,(R4) # Value : 8-bit fine tune B

        INC  R3
        MOV  R3,(R4)    # Register 3: Channel B Tone Period
        MOVB (R5)+,(R4) # Value: 4-bit coarse tune B

        INC  R3
        MOV  R3,(R4)    # Register 4: Channel C Tone Period
        MOVB (R5)+,(R4) # Value : 8-bit fine tune C

        INC  R3
        MOV  R3,(R4)    # Register 5: Channel C Tone Period
        MOVB (R5)+,(R4) # Value: 4-bit coarse tune C

        INC  R3
  .ifdef Use_NoiseRegister # CONFIG SPECIFIC
        MOV  R3,(R4)    # Register 6: Noise Period
        MOVB (R5)+,(R4) # Value: 5-bit period control
  .else # No noise. But R8 must still be set.
        INC  R5
  .endif

        INC  R3
        MOV  R3,(R4)    # Register 7: Enable, inverted
  .ifdef SkipPSGSend
        MOVB @$PSGReg7,(R4)
  .else
        MOVB (PC)+,(R4) # Value: IO | IOB | IOA | / Noise | C | B | A | / Tone | C | B | A |
        PSGReg7: .word 0
  .endif

        INC  R3
        MOV  R3,(R4)    # Register 8: Channel A Amplitude
        MOVB (R5)+,(R4) # Value: | M | L3 | L2 | L1 | L0 |

        INC  R3
        MOV  R3,(R4)    # Register 9: Channel B Amplitude
        MOVB (R5)+,(R4) # Value: | M | L3 | L2 | L1 | L0 |

        INC  R3
        MOV  R3,(R4)    # Register 10: Channel C Amplitude
        MOVB (R5)+,(R4) # Value: | M | L3 | L2 | L1 | L0 |

  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
        INC  R3
        MOV  R3,(R4)    # Register 11: Envelope Period
        MOVB (R5)+,(R4) # Value: 8-bit Fine Tune E

        INC  R3
        MOV  R3,(R4)    # Register 12: Envelope Period
        MOVB (R5)+,(R4) # Value: 8-bit Coarse Tune E

        MOV  (R5),R2
    .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC
        MOV  (PC)+,R0; PSGReg13_OldValue: .word 0xFF
        # 0 = no retrig.
        # Else, should be >0xf to be sure the old value becomes a sentinel
        # (i.e. unreachable) value.
        BIS  (PC)+,R0; Retrig: .word 0
        # Is the new value still the same?
        # If yes, the new value must not be set again.
        CMP  R2,R0
        BEQ  PSGReg13_End
    .else # PLY_CFG_UseRetrig
        CMP  R2,(PC)+; PSGReg13_OldValue: .word 0xFF
        BEQ  PSGReg13_End
    .endif # PLY_CFG_UseRetrig # CONFIG SPECIFIC
        MOV  R2,@$PSGReg13_OldValue

        INC  R3
        MOV  R3,(R4) # Register 13: Envelope Shape/Cycle
        MOVB R2,(R4) # value: | Cont. |  Att.  |  Alt.  |  Hold |

    .ifdef PLY_CFG_UseRetrig # CONFIG SPECIFIC
        CLR  @$Retrig
    .endif # PLY_CFG_UseRetrig # CONFIG SPECIFIC
PSGReg13_End:
  .endif # PLY_CFG_UseHardwareSounds

end_of_the_send:

        # playerAkg/sources/PlayerAkg.asm:2209
        MOV  (PC)+,SP; SaveSP: .word 0

.list
        RETURN # playerAkg/sources/PlayerAkg.asm:2216 #----------------------}}}

  .ifdef SkipPSGSend
    .balign 16
  .endif
        PSGReg01_Instr: .word 0
.nolist
        PSGReg23_Instr: .word 0
        PSGReg45_Instr: .word 0
        PSGReg6_8_Instr:
                PSGReg6: .byte 0
                PSGReg8: .byte 0
        PSGReg9_10_Instr:
                PSGReg9:  .byte 0
                PSGReg10: .byte 0
        PSGHardwarePeriod_Instr: .word 0
        PSGReg13_Instr: .word 0
  .ifdef SkipPSGSend
        PSGReg7: .word 0
        FrameNumber: .word -1
  .endif



       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * Channel1/2/3 sub-codes. Uses a macro to mutualize the code. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
.macro ChannelSubcodes cN # playerAkg/sources/PlayerAkg.asm:2234 #-----------{{{
Channel\cN\()_MaybeEffects:
        # There is one wait in all cases.
        # CLR  R0 # R0 is supposed to be 0.
        MOV  R0,@$Channel\cN\()_WaitCounter
  .ifndef PLY_CFG_UseEffects # CONFIG SPECIFIC
        JMP  Channel\cN\()_BeforeEnd_StoreCellPointer
  .else
        BIT  $0x40,R2 # Effects?
       .jmp  ZE, Channel\cN\()_BeforeEnd_StoreCellPointer
        # Manage effects.

# Reads the effects.
# IN:    R5 = Points on the effect blocks
# OUT:   R5 = Points after on the effect blocks
Channel\cN\()_ReadEffects: # playerAkg/sources/PlayerAkg.asm:2250
        MOV  $Channel\cN\()_PlayInstrument_RelativeModifierAddress, R2
        MOV  $Channel\cN\()_SoundStream_RelativeModifierAddress, R3
        MOV  $Channel\cN\()_BeforeEnd_StoreCellPointer, @$Channel_ReadEffects_EndJump
        # Only adds a jump if this is not the last channel,
        # as the code only need to jump below.
    .if \cN != 3
        BR   Channel_ReadEffects
    .endif
  .endif # PLY_CFG_UseEffects

Channel\cN\()_ReadEffectsEnd:

.endm # ChannelSubcodes #----------------------------------------------------}}}

        # Generates the code thanks to the macro declare above.
        ChannelSubcodes 1
        ChannelSubcodes 2
        ChannelSubcodes 3

        # ** NO CODE between the code above and below! **
  .ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC
        # playerAkg/sources/PlayerAkg.asm:2269 #-----------------------------{{{
# IN:   R5 = Points on the effect blocks
# OUT:  R5 = Points after on the effect blocks
Channel_ReadEffects:
        # Makes sure this code is directly below the one above.
       .=Channel3_ReadEffectsEnd

        CLR  R4
        BISB (R5)+,R4 # Reads the effect block.
        ASLB R4       #  It may be an index or a relative address.
        BCS  Channel_ReadEffects_RelativeAddress

        # Index.
        # The index is already *2.
        MOV  0(R4),R4 # Gets the address referred by the table.
       .equiv Channel_ReadEffects_EffectBlocks1, . - 2

Channel_RE_EffectAddressKnown:
        # R4 points on the current effect block header/data.
        MOVB (R4)+,R0 # Gets the effect number/more effect flag.
        # Stores the flag indicating whether there are more effects.
        MOVB R0,@$Channel_RE_ReadNextEffectInBlock

        # Gets the effect number.
        BIC  $0xFF01,R0       # Effect is already * 2.
        JMP  @EffectTable(R0) # Jumps to the effect code.

        # All the effects return here.
Channel_RE_EffectReturn:
        # Is there another effect?
        # Bit 0 indicates whether there are more effects.
        RORB (PC)+; Channel_RE_ReadNextEffectInBlock: .word 0
        BCS  Channel_RE_EffectAddressKnown

        # No more effects.

        JMP  @(PC)+ # Channel1/2/3_BeforeEnd_StoreCellPointer
        Channel_ReadEffects_EndJump: .word 0


Channel_ReadEffects_RelativeAddress:
        ASR  R4       # R0 was the relative MSB. Only 7 relevant bits.
        SWAB R4
        BISB (R5)+,R4 # Reads the relative LSB.
        ADD  (PC)+,R4; Channel_ReadEffects_EffectBlocks2: .word 0
        BR   Channel_RE_EffectAddressKnown
  .endif # PLY_CFG_UseEffects # playerAkg/sources/PlayerAkg.asm:2359 #-------}}}


# ---------------------------------
# Codes that read InstrumentCells.
# IN:    R5  = pointer on the Instrument data cell to read.
#        IX  = can be modified.
#  R_Retrig = Instrument step (>=0). Useful for retrig.
#        SP = normal use of the stack, do not pervert it!
#   PSGReg7 = register 7, as if it was the channel 3 (so, bit 2 and 5 filled only).
#             By default, the noise is OFF, the sound is ON, so no need to do
#             anything if these values match.
#        R0 = SET BELOW: first byte of the data, shifted of 3 bits to the right.
#        R1 = SET BELOW: first byte of the data, unmodified.
#        R2 = inverted volume.
#        R3 = 0 / note (instrument + Track transposition).
#        R4 = track pitch.
#     R_Tmp = temp, use at will. SRC

# OUT:   R5 = new pointer on the Instrument (may be on the empty sound).
#             If not relevant, any value can be returned, it doesn't matter.
#  R_Retrig = Not 0 if retrig for this channel.
#   PSGReg7 = register 7, updated, as if it was the channel 1
#             (so, bit 2 and 5 filled only).
#        R2 = volume to encode (0-16).
#        R3 = output period.
#        R4 = software period. If not relevant, do not set it.

.equiv BitForSound, 0b00000100
.equiv BitForNoise, 0b00100000
  .ifdef UseRetrig_StoH_HtoS_SandH
R_Retrig: .word 0
  .endif
  .ifdef PLY_CFG_HardOnly_Retrig
R_Retrig: .word 0
  .endif

ReadInstrumentCell: # playerAkg/sources/PlayerAkg.asm:2391
        MOVB (R5)+,R0 # Gets the first byte of the cell.
        MOV  R0,R1    # Stores the first byte, handy in many cases.

        # What type if the cell?
        # First bit of the type.
        RORB R0
       .jmp CS, S_Or_H_Or_SaH_Or_EndWithLoop

        # No Soft No Hard, or Soft To Hard, or Hard To Soft, or End without loop.
        RORB R0
        BCS  StH_Or_EndWithoutLoop

        # No Soft No Hard, or Hard to Soft.
        RORB R0
  .ifdef PLY_CFG_HardToSoft # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2408
        BCC  HardToSoft
  .endif # PLY_CFG_HardToSoft

       /* * * * * * * * * * * *
        * "No soft, no hard". *
        * * * * * * * * * * * */
NoSoftNoHard: # playerAkg/sources/PlayerAkg.asm:2420
        BIC  $0xFFF0,R0 # Necessary, we don't know what crap is in the 4th bit of A.
        SUB  R2,R0      # Decreases the volume, watching for overflow.
        BCC  10$        # Checks for overflow.
        CLR  R0
10$:    MOV  R0,R2      # Sets the volume.

  .ifdef PLY_CFG_NoSoftNoHard_Noise # CONFIG SPECIFIC #----------------------{{{
        ROLB R1 # Noise?
        BCC  NSNH_NoNoise
        # Noise
        MOVB (R5)+,@$PSGReg6
        BIS  $BitForSound,@$PSGReg7 # Noise, no sound (both non-default values).
        BIC  $BitForNoise,@$PSGReg7

        RETURN
     NSNH_NoNoise:
  .endif # PLY_CFG_NoSoftNoHard_Noise #--------------------------------------}}}

        BIS  $BitForSound,@$PSGReg7 # ;No noise (default), no sound.

        RETURN


       /* * * * * * * * *
        * "Soft only".  *
        * * * * * * * * */
  .ifdef PLY_CFG_SoftOnly # CONFIG SPECIFIC
Soft: # playerAkg/sources/PlayerAkg.asm:2453
        # Calculates the volume.
        BIC  $0xFFF0,R0 # Necessary, we don't know what crap is in the 4th bit of A.
        SUB  R2,R0      # Decreases the volume, watching for overflow.
        BCC  10$        # Checks for overflow.
        CLR  R0
10$:    MOV  R0,R2      # Sets the volume.
  .endif # PLY_CFG_SoftOnly

  .ifdef UseSoftOnlyOrHardOnly #---------------------------------------------{{{
        # This code is also used by "Hard only".
SoftOnly_HardOnly_TestSimple_Common: # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2464
        # Simple sound? Gets the bit, let the subroutine do the job.
        ROLB R1
        BCC  S_NotSimple
        # Simple.
        # WARNING, the following code must NOT modify the Carry!
        MOV  $0,-(SP) # This will force the noise to 0.
        BR   S_AfterSimpleTest

S_NotSimple: # playerAkg/sources/PlayerAkg.asm:2471
        # Not simple. Reads and keeps the next byte, containing the noise.
        # WARNING, the following code must NOT modify the Carry!
        MOVB (R5)+,R1
        MOV  R1,-(SP)
S_AfterSimpleTest:

        CALL S_Or_H_CheckIfSimpleFirst_CalculatePeriod

    .ifdef UseSoftOnlyOrHardOnly_Noise # CONFIG SPECIFIC #-------------------{{{
        MOV  (SP)+,R0 # Noise?
        BIC  $0xFFE0,R0
        BZE  1237$ # if noise not present, sound present, we can stop here,
                   # R7 is fine.
        # Noise is present
        MOVB R0, @$PSGReg6
        BIC  $BitForNoise, @$PSGReg7
    .endif # UseSoftOnlyOrHardOnly_Noise #-----------------------------------}}}

1237$:  RETURN
  .endif # UseSoftOnlyOrHardOnly #-------------------------------------------}}}

       /* * * * * * * * * *
        * "Hard to soft". *
        * * * * * * * * * */
  .ifdef PLY_CFG_HardToSoft # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2499
    .error
        # We have the ratio jump calculated and the primary period too.
        # It must be divided to get the software frequency.
  .endif # PLY_CFG_HardToSoft


       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        * End without loop. Put here to satisfy the BR range below. *
        * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
EndWithoutLoop: # playerAkg/sources/PlayerAkg.asm:2575
        # Loops to the "empty" instrument, and makes another iteration.
        MOV  (PC)+,R5; EmptyInstrumentDataPt: .word 0

        # No need to read the data, consider a void value.
        INC  R5
        CLR  R0
        CLR  R1

        BR   NoSoftNoHard

StH_Or_EndWithoutLoop: # playerAkg/sources/PlayerAkg.asm:2596
        RORB R0
  .ifndef PLY_CFG_SoftToHard # CONFIG SPECIFIC
        BR   EndWithoutLoop
  .else
        BCS  EndWithoutLoop

       /* * * * * * * * * *
        * "Soft to Hard". *
        * * * * * * * * * */

        CALL StoH_HToS_SandH_Common
        # instrument period is calculated, so R4 is finally free to use
        MOV  R3,R4
        # We have the negated ratio calculated and the primary period too.
        # It must be divided to get the hardware frequency.
        ASH  R0,R4
        ADC  R4

    .ifdef PLY_CFG_SoftToHard_HardwarePitch # CONFIG SPECIFIC #--------------{{{
       .error
        # Gets R1, we need the bit to know if a hardware pitch shift is added.
        MOV  R1,R0
        # Any Hardware pitch shift?
        ROLB R0
        BCC  SH_NoHardwarePitchShift
        # Pitch shift. Reads it.
        CLR  R0
        BISB (R5)+,R0
        SWAB R0
        BISB (R5)+,R0
        SWAB R0
        ADD  R0,R4
SH_NoHardwarePitchShift:
    .endif # PLY_CFG_SoftToHard_HardwarePitch #------------------------------}}}

        MOV  R4,@$PSGHardwarePeriod_Instr

        RETURN # out of ReadInsrumentCell
  .endif

S_Or_H_Or_SaH_Or_EndWithLoop: # playerAkg/sources/PlayerAkg.asm:2687
        # Second bit of the type.
        RORB R0
        BCS  H_Or_EndWithLoop
        # Third bit of the type.
        RORB R0
  .ifdef PLY_CFG_SoftOnly # CONFIG SPECIFIC
       .jmp CC, Soft
  .endif # PLY_CFG_SoftOnly

  .ifdef PLY_CFG_SoftAndHard # CONFIG SPECIFIC
    .error
  .endif # PLY_CFG_SoftAndHard

H_Or_EndWithLoop: # playerAkg/sources/PlayerAkg.asm:2725
  .ifdef PLY_CFG_HardOnly # CONFIG SPECIFIC
    .error
  .endif # PLY_CFG_HardOnly

        # ** WARNING! ** Do not put instructions here between
        # HardOnly and EndWithLoop, else conditional assembling will fail.

       /* * * * * * * * *
        * End with loop *
        * * * * * * * * */
  .ifdef PLY_CFG_UseInstrumentLoopTo # CONFIG SPECIFIC
        # Loops to the encoded pointer, and makes another iteration.
        INC  R5      # align on word boundary
        MOV  (R5),R5 # NOTE: may not work on a computer other than UKNC
        JMP  ReadInstrumentCell
  .endif # PLY_CFG_UseInstrumentLoopTo


# Common code for calculating the period, regardless of Soft or Hard.
# The same register constraints as the methods above apply.
# IN:   R5  = the next bytes to read.
#       R4  = track pitch
#       R3  = note + transposition.
#       R2  = do not modify.
#       R1  = contains three bits:
#             b7: forced period? (if yes, the two other bits are irrelevant)
#             b6: arpeggio?
#             b5: pitch?
#       Carry: Simple sound?
#
# OUT:  R1 = shift three times to the left.
#       R2 = unmodified.
#       R3 = calculated period.
#       R5 = advanced.
S_Or_H_CheckIfSimpleFirst_CalculatePeriod:
        # Simple sound? Checks the carry.
  .ifdef UseInstrumentForcedPeriodsOrArpeggiosOrPitchs # CONFIG SPECIFIC
        BCC  S_Or_H_NextByte
  .endif # UseInstrumentForcedPeriodsOrArpeggiosOrPitchs
        # No more bytes to read, the sound is "simple".
        # The software period must still be calculated.
        # Calculates the note period from the note of the track.
        # This is the same code as below.
        ASLB R3
        MOV  PeriodTable(R3),R3
        ADD  R4,R3
        # Important: the bits must be shifted so that R1 is in the same state
        # as if it were not a "simple" sound.
        ROLB R1
        ROLB R1
        ROLB R1
        # No need to modify PSG R7.
RETURN

  .ifdef UseInstrumentForcedPeriodsOrArpeggiosOrPitchs # CONFIG SPECIFIC
S_Or_H_NextByte: # playerAkg/sources/PlayerAkg.asm:2835
        # Not simple. Reads the next bits to know if there is pitch/arp/forced software period.

        # Forced period?
        ROLB R1
    .ifdef UseInstrumentForcedPeriods # CONFIG SPECIFIC
        BCS  S_Or_H_ForcedPeriod
    .endif # UseInstrumentForcedPeriods

        # No forced period. Arpeggio?
        ROLB R1
    .ifdef UseInstrumentArpeggios # CONFIG SPECIFIC
        BCC  S_Or_H_AfterArpeggio
        MOVB (R5)+,R0 # can be negative, sign extension is welcome
        ADD  R0,R3 # We don't care about overflow, no time for that.
        # the most significant byte has to be cleared if the result is negative
        BIC  $0xFF00,R3
S_Or_H_AfterArpeggio:
    .endif # UseInstrumentArpeggios

        # Pitch?
        ROLB R1
    .ifdef UseInstrumentPitchs # CONFIG SPECIFIC ----------------------------{{{
        BCC  S_Or_H_AfterPitch
        # Reads the pitch. Slow, but shouldn't happen so often.
        CLR  R0
        BISB (R5)+,R0
        SWAB R0
        BISB (R5)+,R0
        SWAB R0
        ADD  R0,R4 # Adds the cell pitch to the track pitch
S_Or_H_AfterPitch:
    .endif # UseInstrumentPitchs --------------------------------------------}}}
        # Calculates the note period from the note of the track.
        # note + arpeggio may be over 127 (but not over 127+127)
        # and we want the same behavior as on 8-bit CPU
        ASLB R3
        MOV  PeriodTable(R3),R3
        ADD  R4,R3

RETURN
  .endif # UseInstrumentForcedPeriodsOrArpeggiosOrPitchs

  .ifdef UseInstrumentForcedPeriods # CONFIG SPECIFIC
S_Or_H_ForcedPeriod: # playerAkg/sources/PlayerAkg.asm:2893
        # Reads the period. A bit slow, but doesn't happen often.
        CLR  R4
        BISB (R5)+,R4
        SWAB R4
        BISB (R5)+,R4
        SWAB R4

        # The pitch and arpeggios have been skipped, since the period is forced,
        # the bits must be compensated.
        ROLB R1
        ROLB R1
RETURN
  .endif # UseInstrumentForcedPeriods

        #------------------------------------------------------------------
        # Common code for SoftToHard and HardToSoft, and even Soft And Hard.
        # The same register constraints as the methods above apply.
        # OUT:   R3 = frequency.
        #        R0 = negated ratio
        #             ready to be used in ASH to multiply/divide the frequency.
        #        R1 = bit states, shifted four times to the left
        #            (for StoH/HtoS, the msb will be "pitch shift?")
        #            (hardware for SoftTohard, software for HardToSoft).
  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2917
StoH_HToS_SandH_Common:
        MOV  $16,R2 # Sets the hardware volume.

        # Retrig?
        RORB R0
    .ifdef UseRetrig_StoH_HtoS_SandH # CONFIG SPECIFIC
      .error
    .endif # UseRetrig_StoH_HtoS_SandH

        # Calculates the hardware envelope.
        # The value given is from 8-15, but encoded as 0-7.
        BIC  $0177770,R0
        ADD  $8,R0
        MOV  R0,@$PSGReg13_Instr

        # Noise? If yes, reads the next byte.
        ROLB R1 # NOTE: is this correct register???
    .ifdef UseNoise_StoH_HtoS_SandH # CONFIG SPECIFIC
      .error
    .endif # UseNoise_StoH_HtoS_SandH

        # Read the next data byte.
        MOVB (R5)+,R0
        MOV  R0,R1
        # Simple (no need to test the other bits)?
        # The carry is transmitted to the called code below.
        ROLB R1
        # Call another common subcode.
        CALL S_Or_H_CheckIfSimpleFirst_CalculatePeriod
        # Let's calculate the hardware frequency from it.
        BIC  $0177770,R0
        # convert the inverted ratio to number of right shifts for use with ASH
        SUB  $7,R0
RETURN
  .endif # PLY_CFG_UseHardwareSounds

# ------------------------------------------------------------------------------
# Effects management.
# ------------------------------------------------------------------------------
.ifdef PLY_CFG_UseEffects # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:2981
        # All the effects code.
EffectTable:
   .ifdef PLY_CFG_UseEffect_Reset                # CONFIG SPECIFIC
       .word Effect_ResetFullVolume             # 0
       .word Effect_Reset                       # 1
   .else
       .word 0
       .word 0
   .endif # PLY_CFG_UseEffect_Reset

   .ifdef PLY_CFG_UseEffect_SetVolume            # CONFIG SPECIFIC
       .word Effect_Volume                      # 2
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_SetVolume

   .ifdef PLY_AKS_UseEffect_Arpeggio             # CONFIG SPECIFIC
       .word Effect_ArpeggioTable               # 3
       .word Effect_ArpeggioTableStop           # 4
   .else
       .word 0
       .word 0
   .endif # PLY_AKS_UseEffect_Arpeggio

   .ifdef PLY_CFG_UseEffect_PitchTable           # CONFIG SPECIFIC
       .word Effect_PitchTable                  # 5
       .word Effect_PitchTableStop              # 6
   .else
       .word 0
       .word 0
   .endif # PLY_CFG_UseEffect_PitchTable

   .ifdef UseEffect_VolumeSlide                  # CONFIG SPECIFIC
      .error
       .word Effect_VolumeSlide                 # 7
       .word Effect_VolumeSlideStop             # 8
   .else
       .word 0
       .word 0
   .endif # UseEffect_VolumeSlide

   .ifdef PLY_CFG_UseEffect_PitchUp              # CONFIG SPECIFIC
       .word Effect_PitchUp                     # 9
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_PitchUp

   .ifdef PLY_CFG_UseEffect_PitchDown            # CONFIG SPECIFIC
       .word Effect_PitchDown                   # 10
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_PitchDown

   .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
       .word Effect_PitchStop                   # 11
   .else
       .word 0
   .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

   .ifdef PLY_CFG_UseEffect_PitchGlide           # CONFIG SPECIFIC
       .word Effect_GlideWithNote               # 12
       .word Effect_GlideSpeed                  # 13
   .else
       .word 0
       .word 0
   .endif # PLY_CFG_UseEffect_PitchGlide

   .ifdef PLY_CFG_UseEffect_Legato               # CONFIG SPECIFIC
       .word Effect_Legato                      # 14
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_Legato

   .ifdef PLY_CFG_UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC
     .error
       .word Effect_ForceInstrumentSpeed        # 15
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_ForceInstrumentSpeed

   .ifdef PLY_CFG_UseEffect_ForceArpeggioSpeed   # CONFIG SPECIFIC
     .error
       .word Effect_ForceArpeggioSpeed          # 16
   .else
       .word 0
   .endif # PLY_CFG_UseEffect_ForceArpeggioSpeed

   .ifdef PLY_CFG_UseEffect_ForcePitchTableSpeed # CONFIG SPECIFIC
     .error
       .word Effect_ForcePitchSpeed             # 17
   .endif # PLY_CFG_UseEffect_ForcePitchTableSpeed
    # Last effect: no need to use padding with .word

# Effects.
# ----------------------------------------------------------------
# For all effects:
# IN:   R0 = Can be modified at will.
#       R1 = Can be modified at will.
#       R2 = Address from which the data of the instrument are modified.
#       R3 = Address from which the data of the channels (pitch, volume, etc) are modified.
#       R4 = Points on the data of this effect.
#       R5 = Must NOT be modified.
#
#       SP = Can be modified at will.
#
# OUT:  R4 = Points after on the data of this effect.
# ----------------------------------------------------------------

  .ifdef PLY_CFG_UseEffect_Reset # CONFIG SPECIFIC #-------------------------{{{
Effect_ResetFullVolume: # playerAkg/sources/PlayerAkg.asm:3087
        CLR  R0 # The inverted volume is 0 (full volume).
        BR   Effect_ResetVolume_AfterReading

Effect_Reset:
        MOVB (R4)+,R0

Effect_ResetVolume_AfterReading:
       .set offset, Channel1_InvertedVolumeInteger - Channel1_SoundStream_RelativeModifierAddress
        MOVB R0, offset(R3)

        # The current pitch is reset.
    .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
       .set offset, Channel1_Pitch - Channel1_SoundStream_RelativeModifierAddress
        CLR  offset(R3)
    .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

        MOV  $OPCODE_CLC, R0

    .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
       .set offset, Channel1_IsPitch - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)
    .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

    .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC
       .set offset, Channel1_IsPitchTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)
    .endif # PLY_CFG_UseEffect_PitchTable

    .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC
       .set offset, Channel1_IsArpeggioTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)
    .endif # PLY_AKS_UseEffect_Arpeggio

    .ifdef UseEffect_VolumeSlide # CONFIG SPECIFIC
       .set offset, Channel1_IsVolumeSlide - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)
    .endif # UseEffect_VolumeSlide

        JMP  Channel_RE_EffectReturn
  .endif # PLY_CFG_UseEffect_Reset #-----------------------------------------}}}

  .ifdef PLY_CFG_UseEffect_SetVolume # CONFIG SPECIFIC #---------------------{{{
Effect_Volume: # playerAkg/sources/PlayerAkg.asm:3123
       .set offset, Channel1_InvertedVolumeInteger - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+, offset(R3) # Reads the inverted volume.

    .ifdef UseEffect_VolumeSlide # CONFIG SPECIFIC
       .set offset, Channel1_IsVolumeSlide - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)
    .endif # UseEffect_VolumeSlide

        JMP  Channel_RE_EffectReturn
  .endif # PLY_CFG_UseEffect_SetVolume #-------------------------------------}}}

  .ifdef PLY_AKS_UseEffect_Arpeggio # CONFIG SPECIFIC #----------------------{{{
Effect_ArpeggioTable: # playerAkg/sources/PlayerAkg.asm:3137
        MOVB (R4)+,R1 # Reads the arpeggio table index.
        ASL  R1
        MOV  0(R1),R1 # Finds the address of the Arpeggio.
       .equiv ArpeggiosTable, .-2

        # Reads the speed.
        MOVB (R1)+,R0
       .set offset, Channel1_ArpeggioTableSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOVB R0, offset(R3)
       .set offset, Channel1_ArpeggioBaseSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOVB R0, offset(R3)

       .set offset, Channel1_ArpeggioTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  R1, offset(R3)
       .set offset, Channel1_ArpeggioTableBase - Channel1_SoundStream_RelativeModifierAddress
        MOV  R1, offset(R3)

       .set offset, Channel1_IsArpeggioTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SEC, offset(R3)
       .set offset, Channel1_ArpeggioTableCurrentStep - Channel1_SoundStream_RelativeModifierAddress
        CLR  offset(R3)

        JMP  Channel_RE_EffectReturn

Effect_ArpeggioTableStop:
       .set offset, Channel1_IsArpeggioTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)

        JMP  Channel_RE_EffectReturn
  .endif # PLY_AKS_UseEffect_Arpeggio #--------------------------------------}}}

 .ifdef PLY_CFG_UseEffect_PitchTable # CONFIG SPECIFIC #---------------------{{{
        # Pitch table. Followed by the Pitch Table index.
Effect_PitchTable: # playerAkg/sources/PlayerAkg.asm:3182
        MOVB (R4)+,R1 # Reads the Pitch table index.
        ASL  R1
        MOV  0(R1),R1 # Finds the address of the Pitch
       .equiv PitchesTable, .-2

        # Reads the speed.
        MOV  (R1)+,R0
       .set offset, Channel1_PitchTableSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)
       .set offset, Channel1_PitchBaseSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOV  R0, offset(R3)

       .set offset, Channel1_PitchTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  R1, offset(R3)
       .set offset, Channel1_PitchTableBase - Channel1_SoundStream_RelativeModifierAddress
        MOV  R1, offset(R3)

       .set offset, Channel1_IsPitchTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SEC, offset(R3)

       .set offset, Channel1_PitchTableCurrentStep - Channel1_SoundStream_RelativeModifierAddress
        CLR  offset(R3)

        JMP  Channel_RE_EffectReturn

        # Stops the pitch table.
Effect_PitchTableStop:
        # Only the pitch is stopped, but the value remains.
       .set offset, Channel1_IsPitchTable - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)

        JMP  Channel_RE_EffectReturn
  .endif # PLY_CFG_UseEffect_PitchTable #------------------------------------}}}

  .ifdef UseEffect_VolumeSlide # CONFIG SPECIFIC
        # Volume slide effect. Followed by the volume, as a word.
Effect_VolumeSlide:
       .set offset, Channel1_VolumeSlideValue - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+, offset(R3)
       .set offset, Channel1_VolumeSlideValue + 1 - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+, offset(R3)

       .set offset, Channel1_IsVolumeSlide - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SEC, offset(R3)

        JMP  Channel_RE_EffectReturn

        # Volume slide stop effect.
Effect_VolumeSlideStop:
        # Only stops the slide, don't reset the value.
       .set offset, Channel1_IsVolumeSlide - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)

        JMP  Channel_RE_EffectReturn
  .endif # UseEffect_VolumeSlide #-------------------------------------------}}}

        # Pitch track effect. Followed by the pitch, as a word.
  .ifdef PLY_CFG_UseEffect_PitchDown # CONFIG SPECIFIC #---------------------{{{
Effect_PitchDown: # playerAkg/sources/PlayerAkg.asm:3251
        # Changes the sign of the operations.
       .set offset, Channel1_PitchTrackAddOrSub - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADD_IMMEDIATE_R5, offset(R3)

       .set offset, Channel1_PitchTrackDecimalInstr - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADD_IMMEDIATE_IMMEDIATE, offset(R3)

       .set offset, Channel1_PitchTrackIntegerAdcOrSbc - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADC_R5, offset(R3)
  .endif # PLY_CFG_UseEffect_PitchDown #-------------------------------------}}}

  .ifdef PLY_AKS_UseEffect_PitchUpOrDown # CONFIG SPECIFIC #-----------------{{{
        # The Pitch up will jump here.
Effect_PitchUpDown_Common: # playerAkg/sources/PlayerAkg.asm:3259
        # Authorizes the pitch, disabled the glide.
       .set offset, Channel1_IsPitch - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SEC, offset(R3)

    .ifdef PLY_CFG_UseEffect_PitchGlide # CONFIG SPECIFIC
       .set offset, Channel1_GlideDirection - Channel1_SoundStream_RelativeModifierAddress
        CLR  offset(R3)
    .endif # PLY_CFG_UseEffect_PitchGlide

        # Reads the Pitch.
       .set offset, Channel1_PitchTrackDecimalValue - Channel1_SoundStream_RelativeModifierAddress
        # the value will be added/subtracted to/from PitchTrackDecimalCounter
        # PitchTrackDecimalCounter is 8-bit in original Z80 source code
        # so we write the value into MSB to immitate 8-bit counter
        MOVB (R4)+, offset+1(R3)

       .set offset, Channel1_PitchTrack - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+, offset(R3)

        JMP  Channel_RE_EffectReturn
  .endif # PLY_AKS_UseEffect_PitchUpOrDown #---------------------------------}}}

  .ifdef PLY_CFG_UseEffect_PitchUp # CONFIG SPECIFIC #-----------------------{{{
Effect_PitchUp: # playerAkg/sources/PlayerAkg.asm:3276
        # Changes the sign of the operations.
       .set offset, Channel1_PitchTrackAddOrSub - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SUB_IMMEDIATE_R5, offset(R3)

       .set offset, Channel1_PitchTrackDecimalInstr - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SUB_IMMEDIATE_IMMEDIATE, offset(R3)

       .set offset, Channel1_PitchTrackIntegerAdcOrSbc - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SBC_R5, offset(R3)

        BR   Effect_PitchUpDown_Common
  .endif # PLY_CFG_UseEffect_PitcUp #----------------------------------------}}}

  .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC #----------{{{
        # Pitch track stop. Used by Pitch up/down/glide.
Effect_PitchStop: # playerAkg/sources/PlayerAkg.asm:3287
        # Only stops the pitch, don't reset the value.
        # No need to reset the Glide either.
       .set offset, Channel1_IsPitch - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)

        JMP  Channel_RE_EffectReturn
  .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide #--------------------------}}}

  .ifdef PLY_CFG_UseEffect_PitchGlide # CONFIG SPECIFIC #--------------------{{{
        # Glide, with a note.
Effect_GlideWithNote: # playerAkg/sources/PlayerAkg.asm:3295
        # Reads the note to reach.
        MOVB (R4)+,R1
        # Finds the period related to the note, stores it.
        ASLB R1 # The note is 7 bits only, so it fits.
        MOV  PeriodTable(R1),R1 # R1 = period to reach.

       .set offset, Channel1_GlideToReach - Channel1_SoundStream_RelativeModifierAddress
        MOV  R1, offset(R3)

        # Calculates the period of the current note to calculate the difference.
       .set offset, Channel1_TrackNote - Channel1_PlayInstrument_RelativeModifierAddress
        MOV  offset(R2),R0
        ASLB R0
        MOV  PeriodTable(R0),R0 # R0 = current period.

        # Adds the current Track Pitch to have the current period, else
        # the direction may be biased.
       .set offset, Channel1_Pitch - Channel1_SoundStream_RelativeModifierAddress
        ADD  offset(R3),R0

        # What is the difference?
        CMP  R0,R1
        BLO  Effect_Glide_PitchDown

        # Pitch up.
       .set offset, Channel1_GlideDirection - Channel1_SoundStream_RelativeModifierAddress
        MOV  $1, offset(R3)

       .set offset, Channel1_PitchTrackAddOrSub - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SUB_IMMEDIATE_R5, offset(R3)

       .set offset, Channel1_PitchTrackDecimalInstr - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SUB_IMMEDIATE_IMMEDIATE, offset(R3)

       .set offset, Channel1_PitchTrackIntegerAdcOrSbc - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SBC_R5, offset(R3)

        # Reads the Speed, which is actually the "pitch".
Effect_Glide_ReadSpeed:
Effect_GlideSpeed: # This is an effect.
        # Reads the Pitch.
       .set offset, Channel1_PitchTrackDecimalValue - Channel1_SoundStream_RelativeModifierAddress
        # the value will be added/subtracted to/from PitchTrackDecimalCounter
        # PitchTrackDecimalCounter is 8-bit in original Z80 source code
        # so we write the value into MSB to immitate 8-bit counter
        MOVB (R4)+, offset+1(R3)

       .set offset, Channel1_PitchTrack - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+, offset(R3)

        # Enables the pitch, as the Glide relies on it.
        # The Glide is enabled below, via its direction.
       .set offset, Channel1_IsPitch - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_SEC, offset(R3)

        JMP  Channel_RE_EffectReturn

Effect_Glide_PitchDown:
        # Pitch down.
       .set offset, Channel1_GlideDirection - Channel1_SoundStream_RelativeModifierAddress
        MOV  $2, offset(R3)

       .set offset, Channel1_PitchTrackAddOrSub - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADD_IMMEDIATE_R5, offset(R3)

       .set offset, Channel1_PitchTrackDecimalInstr - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADD_IMMEDIATE_IMMEDIATE, offset(R3)

       .set offset, Channel1_PitchTrackIntegerAdcOrSbc - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_ADC_R5, offset(R3)

        JMP  Effect_Glide_ReadSpeed
  .endif # PLY_CFG_UseEffect_PitchGlide #------------------------------------}}}

  .ifdef UseEffect_Legato # CONFIG SPECIFIC #--------------------------------{{{
        # Legato. Followed by the note to play.
Effect_Legato: # playerAkg/sources/PlayerAkg.asm:3371
        # Reads and sets the new note to play.
       .set offset, Channel1_TrackNote - Channel1_PlayInstrument_RelativeModifierAddress
        MOVB (R4)+, offset(R2)

        # Stops the Pitch effect, resets the Pitch.
    .ifdef PLY_AKS_UseEffect_PitchUpOrDownOrGlide # CONFIG SPECIFIC
       .set offset, Channel1_IsPitch - Channel1_SoundStream_RelativeModifierAddress
        MOV  $OPCODE_CLC, offset(R3)

       .set offset, Channel1_Pitch - Channel1_SoundStream_RelativeModifierAddress
        CLR  offset(R3)
    .endif # PLY_AKS_UseEffect_PitchUpOrDownOrGlide

        JMP  Channel_RE_EffectReturn
  .endif # UseEffect_Legato #------------------------------------------------}}}

  .ifdef UseEffect_ForceInstrumentSpeed # CONFIG SPECIFIC #------------------{{{
    .error
        # Forces the Instrument Speed. Followed by the speed.
Effect_ForceInstrumentSpeed: # playerAkg/sources/PlayerAkg.asm:3392
        # Reads and sets the new speed.
       .set offset, Channel1_InstrumentSpeed - Channel1_PlayInstrument_RelativeModifierAddress
        MOVB (R4)+, offset(R2)

        JMP  Channel_RE_EffectReturn
  .endif # UseEffect_ForceInstrumentSpeed #----------------------------------}}}

  .ifdef UseEffect_ForceArpeggioSpeed # CONFIG SPECIFIC #--------------------{{{
    .error
        # Forces the Arpeggio Speed. Followed by the speed.
Effect_ForceArpeggioSpeed: # playerAkg/sources/PlayerAkg.asm:3404
    .ifdef UseEffect_Arpeggio # CONFIG SPECIFIC
      .error
        # Is IT possible to use a Force Arpeggio even if there is no Arpeggio.
        # Unlikely, but...
        # Reads and sets the new speed.
       .set offset, Channel1_ArpeggioTableSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+,offset(R3)
    .else
      .error
        INC  R4
    .endif # UseEffect_Arpeggio

        JMP  Channel_RE_EffectReturn
  .endif # UseEffect_ForceArpeggioSpeed #------------------------------------}}}

  .ifdef UseEffect_ForcePitchTableSpeed # CONFIG SPECIFIC #------------------{{{
    .error
# Forces the Pitch Speed. Followed by the speed.
Effect_ForcePitchSpeed: # playerAkg/sources/PlayerAkg.asm:3420
    .ifdef UseEffect_PitchTable # CONFIG SPECIFIC
      .error
        # Is IT possible to use a Force Arpeggio even if there is no Arpeggio.
        # Unlikely, but...
        # Reads and sets the new speed.
       .set offset, Channel1_PitchTableSpeed - Channel1_SoundStream_RelativeModifierAddress
        MOVB (R4)+,offset(R3)
    .else
      .error
        INC  R4
    .endif # PLY_CFG_UseEffect_PitchTable

        JMP  Channel_RE_EffectReturn
  .endif # PLY_CFG_UseEffect_ForcePitchTableSpeed #--------------------------}}}

.endif # PLY_CFG_UseEffects # CONFIG SPECIFIC # playerAkg/sources/PlayerAkg.asm:3434

  .ifdef PLY_CFG_UseEventTracks # CONFIG SPECIFIC #
Event: .word 0 # Possible event sent from the music for the caller to interpret.
  .endif # PLY_CFG_UseEventTracks #


# The period table for each note (from 0 to 127 included).
PeriodTable: # playerAkg/sources/PlayerAkg.asm:3450
    # base_freq = 1789772.5 Hz
    #       C     C#    D     D#    E     F     F#    G     G#    A     A#    B
    .word 6841, 6457, 6095, 5753, 5430, 5125, 4837, 4566, 4310, 4068, 3839, 3624 # Octave 0
    .word 3420, 3229, 3047, 2876, 2715, 2562, 2419, 2283, 2155, 2034, 1920, 1812 # Octave 1
    .word 1710, 1614, 1524, 1438, 1357, 1281, 1209, 1141, 1077, 1017,  960,  906 # Octave 2
    .word  855,  807,  762,  719,  679,  641,  605,  571,  539,  508,  480,  453 # Octave 3
    .word  428,  404,  381,  360,  339,  320,  302,  285,  269,  254,  240,  226 # Octave 4
    .word  214,  202,  190,  180,  170,  160,  151,  143,  135,  127,  120,  113 # Octave 5
    .word  107,  101,   95,   90,   85,   80,   76,   71,   67,   64,   60,   57 # Octave 6
    .word   53,   50,   48,   45,   42,   40,   38,   36,   34,   32,   30,   28 # Octave 7
    .word   27,   25,   24,   22,   21,   20,   19,   18,   17,   16,   15,   14 # Octave 8
    .word   13,   13,   12,   11,   11,   10,    9,    9,    8,    8,    7,    7 # Octave 9
    .word    7,    6,    6,    6,    5,    5,    5,    4                         # Octave 10
PeriodTable_End:
