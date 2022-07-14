# Player of sound effects, for AKG (Generic) the player, format V2 (including speed).
# This file is meant to be included to the AKG player, do not use it stand-alone.
# If you want sound effects without music, there is a specific player for that.
#
# Is there a loaded Player Configuration source? If no, use a default configuration.
  .ifndef PLY_CFG_SFX_ConfigurationIsPresent
        PLY_CFG_UseHardwareSounds = 1
        PLY_CFG_SFX_LoopTo = 1
        PLY_CFG_SFX_NoSoftNoHard = 1
        PLY_CFG_SFX_NoSoftNoHard_Noise = 1
        PLY_CFG_SFX_SoftOnly = 1
        PLY_CFG_SFX_SoftOnly_Noise = 1
        PLY_CFG_SFX_HardOnly = 1
        PLY_CFG_SFX_HardOnly_Noise = 1
        PLY_CFG_SFX_HardOnly_Retrig = 1
        PLY_CFG_SFX_SoftAndHard = 1
        PLY_CFG_SFX_SoftAndHard_Noise = 1
        PLY_CFG_SFX_SoftAndHard_Retrig = 1
  .endif

# Agglomerates some Player Configuration flags.
# --------------------------------------------
 # Mixes the Hardware flags into one.
  .ifdef PLY_CFG_SFX_HardOnly
        PLY_SE_HardwareSounds = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard
        PLY_SE_HardwareSounds = 1
  .endif
 # Mixes the Hardware Noise flags into one.
  .ifdef PLY_CFG_SFX_HardOnly_Noise
        PLY_SE_HardwareNoise = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard_Noise
        PLY_SE_HardwareNoise = 1
  .endif
 # Mixes the Noise flags into one.
  .ifdef PLY_SE_HardwareNoise
        PLY_SE_Noise = 1
  .endif
  .ifdef PLY_CFG_SFX_NoSoftNoHard_Noise
        PLY_SE_Noise = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftOnly
        PLY_SE_Noise = 1
  .endif
 # Mixes the Software Volume flags into one.
  .ifdef PLY_CFG_SFX_NoSoftNoHard
        PLY_SE_VolumeSoft = 1
        PLY_SE_VolumeSoftOrHard = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftOnly
        PLY_SE_VolumeSoft = 1
        PLY_SE_VolumeSoftOrHard = 1
  .endif
 # Mixes the volume (soft/hard) into one.
  .ifdef PLY_CFG_UseHardwareSounds
        PLY_SE_VolumeSoftOrHard = 1
  .endif
 # Mixes the retrig flags into one.
  .ifdef PLY_CFG_SFX_HardOnly_Retrig
        PLY_SE_UseRetrig = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard_Retrig
        PLY_SE_UseRetrig = 1
  .endif

.equiv PLY_SE_BitForSound, 0b00000100
.equiv PLY_SE_BitForNoise, 0b00100000

# Initializes the sound effects. It MUST be called at any times before a first
# sound effect is triggered.
# It doesn't matter whether the song is playing or not, or if it has been
# initialized or not.
# IN:    R5 HL = Address to the sound effects data.
PLY_SE_InitSoundEffects: # playerSoundEffects/sources/PlayerSoundEffects.asm:193
        MOV  R5,@$PLY_SE_PtSoundEffectTable
        RETURN

# Programs the playing of a sound effect.
# If a previous one was already playing on the same channel, it is replaced.
# This does not actually plays the sound effect, but programs its playing.
# Once done, call PLY_SE_Play, every frame.
# IN: R0 A = Sound effect number (>0!).
#     R1 C = The channel where to play the sound effect (0, 1, 2).
#     R2 B = Inverted volume (0 = full volume, 16 = no sound).
#            Hardware sounds are also lowered.
# corrupts R0, R3, R5
PLY_SE_PlaySoundEffect: # playerSoundEffects/sources/PlayerSoundEffects.asm:217
      # Gets the address to the sound effect.
        DEC  R0  # The 0th is not encoded.
        ASL  R0
       .equiv PLY_SE_PtSoundEffectTable, .+2
        MOV  0(R0),R3
      # Reads the header of the sound effect to get the speed.
        MOVB (R3)+,R0
      # Finds the pointer to the sound effect of the desired channel.
        MOV  PLY_SE_ChannelsDataTable(R1),R5
        MOV  R3,(R5)+ # now stores pointer to next Cell of the sound effect
        MOV  R2,(R5)+ # the inverted volume
        CLR  (R5)+    # resets the current speed
        MOVB R0,(R5)  # and stores the instrument speed

        RETURN

# Stops a sound effect. Nothing happens if there was no sound effect.
# IN: R0 A = The channel where to stop the sound effect (0, 1, 2).
PLY_SE_StopSoundEffectFromChannel: # playerSoundEffects/sources/PlayerSoundEffects.asm:269
      # Puts 0 to the pointer of the sound effect.
        CLR  @PLY_SE_ChannelsDataTable(R0) # 0 means "no sound".
        RETURN

PLY_SE_ChannelsDataTable: # Used to quickly get sound effects data for selected channel
       .word PLY_SE_Channel1_SoundEffectData
       .word PLY_SE_Channel2_SoundEffectData
       .word PLY_SE_Channel3_SoundEffectData

# internal subroutines ---------------------------------------------------------

      # Plays the sound effects, if any has been triggered by the user.
      # This must be played every frame.
      # This sends new data to the PSG.
      # Of course, nothing will be heard unless some sound effects are
      # programmed (via PLY_SE_ProgramSoundEffect).
      # The sound effects initialization method must have been called before!
PLY_SE_PlaySoundEffectsStream:
      # Plays the sound effects on every track.
        MOV  $PLY_SE_Channel1_SoundEffectData,R3
        MOV  $PLY_SE_PSGReg8,@$PLY_SE_ChannelVolumePSGReg
        MOV  $PLY_SE_PSGReg01_Instr,R4

      # Channel 1.
      # ----------
        MOV  $0b11111100,R2
        CALL PLY_SE_PSES_Play
        MOV  $PLY_SE_Channel2_SoundEffectData,R3
        MOV  $PLY_SE_PSGReg9,@$PLY_SE_ChannelVolumePSGReg
        MOV  $PLY_SE_PSGReg23_Instr,R4

      # Channel 2.
      # ----------
        ASR  R2
        CALL PLY_SE_PSES_Play
        MOV  $PLY_SE_Channel3_SoundEffectData,R3
        MOV  $PLY_SE_PSGReg10,@$PLY_SE_ChannelVolumePSGReg
        MOV  $PLY_SE_PSGReg45_Instr,R4

      # Channel 3.
      # ----------
        ASR  R2
        CALL PLY_SE_PSES_Play

        MOV  R2,@$PLY_SE_PSGReg7

PLY_SE_SendPSGRegisters: #----------------------------------------------------------{{{
     .ifdef SkipPSGSend
        JMP  PLY_SE_end_of_the_send
     .else
        NOP
        NOP
     .endif

        MOV  $0177362,R4
        MOV  $PLY_SE_PSGReg01_Instr,R5

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
  .ifdef PLY_SE_Noise # CONFIG SPECIFIC
        MOV  R3,(R4)    # Register 6: Noise Period
        MOVB (R5)+,(R4) # Value: 5-bit period control
  .else # No noise. But R8 must still be set.
        INC  R5
  .endif

        INC  R3
        MOV  R3,(R4)    # Register 7: Enable, inverted
  .ifdef SkipPSGSend
        MOVB @$PLY_SE_PSGReg7,(R4)
  .else
       .equiv PLY_SE_PSGReg7, .+2
        MOVB $0,(R4)    # Value: IO | IOB | IOA | / Noise | C | B | A | / Tone | C | B | A |
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
    .ifdef PLY_SE_UseRetrig # CONFIG SPECIFIC
       .equiv PLY_SE_PSGReg13_OldValue, .+2
        MOV  $0xFF,R0
        # 0 = no retrig.
        # Else, should be >0xf to be sure the old value becomes a sentinel
        # (i.e. unreachable) value.
       .equiv PLY_SE_Retrig, .+2
        BIS  $0,R0
        # Is the new value still the same?
        # If yes, the new value must not be set again.
        CMP  R2,R0
        BEQ  PLY_SE_PSGReg13_End
    .else # PLY_SE_UseRetrig
       .equiv PLY_SE_PSGReg13_OldValue, .+2
        CMP  R2,$0xFF
        BEQ  PLY_SE_PSGReg13_End
    .endif # PLY_SE_UseRetrig # CONFIG SPECIFIC
        MOV  R2,@$PLY_SE_PSGReg13_OldValue

        INC  R3
        MOV  R3,(R4) # Register 13: Envelope Shape/Cycle
        MOVB R2,(R4) # value: | Cont. |  Att.  |  Alt.  |  Hold |

    .ifdef PLY_SE_UseRetrig # CONFIG SPECIFIC
        CLR  @$PLY_SE_Retrig
    .endif # PLY_CFG_UseRetrig # CONFIG SPECIFIC
PLY_SE_PSGReg13_End:
  .endif # PLY_CFG_UseHardwareSounds

PLY_SE_end_of_the_send:

        RETURN #-------------------------------------------------------------}}}

  .ifdef SkipPSGSend
    .balign 16
  .endif

        PLY_SE_PSGReg01_Instr: .word 0
        PLY_SE_PSGReg23_Instr: .word 0
        PLY_SE_PSGReg45_Instr: .word 0
        PLY_SE_PSGReg6_8_Instr:
                PLY_SE_PSGReg6: .byte 0
                PLY_SE_PSGReg8: .byte 0
        PLY_SE_PSGReg9_10_Instr:
                PLY_SE_PSGReg9:  .byte 0
                PLY_SE_PSGReg10: .byte 0
        PLY_SE_PSGHardwarePeriod_Instr: .word 0
        PLY_SE_PSGReg13_Instr: .word 0

  .ifdef SkipPSGSend
        PLY_SE_PSGReg7: .word 0
  .endif


      # Plays the sound stream from the given pointer to the sound effect.
      # If 0, no sound is played.
      # The given R7 is given shift twice to the left, so that this code MUST
      # set/reset the bit 2 (sound), and maybe reset bit 5 (noise).
      # This code MUST overwrite these bits because sound effects have priority
      # over the music.
      # IN:  R3 IX = Points on the sound effect pointer.
      #              If the sound effect pointer is 0, nothing must be played.
      #         IY = Points on the address where to store the volume for this
      #              channel.
      #      R4 HL'= Points on the address where to store the software period for
      #              this channel.
      #      R2 C = R7, shifted twice to the left.
      # OUT: The pointed pointer by IX may be modified as the sound advances.
      #      R2 C = R7, MUST be modified if there is a sound effect.
      #  R0, R1, R5 are free to use
PLY_SE_PSES_Play:
      # Reads the pointer pointed by IX.
        MOV  (R3),R5
        BZE  1237$ # No sound to be played? Returns immediately.

      # Reads the first byte. What type of sound is it?
PLY_SE_PSES_ReadFirstByte:
        MOVB (R5)+,R0
        MOVB R0,R1
        ASRB R0
        BCS  PLY_SE_PSES_SoftwareOrSoftwareAndHardware
        ASRB R0

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
        BCS  PLY_SE_PSES_HardwareOnly
  .endif # PLY_CFG_SFX_HardOnly

      # No software, no hardware, or end/loop.
      # -------------------------------------------
      # End or loop?
        ASRB R0

  .ifdef PLY_CFG_SFX_NoSoftNoHard # CONFIG SPECIFIC. If not present, the jump is
                                  # not needed, the method is just below.
        BCS  PLY_SE_PSES_S_EndOrLoop

      # No software, no hardware.
      # -------------------------------------------
      # Gets the volume.
        CALL PLY_SE_PSES_ManageVolumeFromR0_Filter4Bits

      # Noise?
      .ifdef PLY_CFG_SFX_NoSoftNoHard_Noise # CONFIG SPECIFIC
        ASLB R1
        BCC  PLY_SE_PSES_NoSoftNoHard_NoNoise
        CALL PLY_SE_PSES_ReadNoiseAndOpenNoiseChannel
PLY_SE_PSES_NoSoftNoHard_NoNoise:
      .endif # PLY_CFG_SFX_NoSoftNoHard_Noise

        BR   PLY_SE_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_NoSoftNoHard

      # **Warning!** Do not put any instruction between EndOrLoop and NoSoftNoHard.

PLY_SE_PSES_S_EndOrLoop:
      # If no "loop to", the sounds always end, no need to test.
  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC.
      # Is it an end?
        ASRB R0
        BCS  PLY_SE_PSES_S_Loop
  .endif # PLY_CFG_SFX_LoopTo
      # End of the sound. Marks the sound pointer with 0, meaning "no sound".
        CLR  (R3)
1237$:  RETURN

  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC.
PLY_SE_PSES_S_Loop:
      # Loops. Reads the pointer and directly uses it.
        CLR  R0
        BISB (R5)+,R0
        SWAB R0
        BISB (R5),R0
        SWAB R0
        MOV  R0,R5
        BR   PLY_SE_PSES_ReadFirstByte
  .endif # PLY_CFG_SFX_LoopTo


      # Saves HL into IX, and exits. This must be called at the end of each
      # Cell.
      # If the speed has not been reached, it is not saved.
PLY_SE_PSES_SavePointerAndExit:
      # Speed reached?
        CMPB PLY_SE_SoundEffectData_OffsetCurrentStep(R3),PLY_SE_SoundEffectData_OffsetSpeed(R3)
        BLO  PLY_SE_PSES_NotReached
      # The speed has been reached, so resets it and saves the pointer to the
      # next cell to read.
        CLR  PLY_SE_SoundEffectData_OffsetCurrentStep(R3)
        MOV  R5,(R3)
        RETURN

PLY_SE_PSES_NotReached:
      # Speed not reached. Increases it, that's all. The same cell will be read
      # next time.
        INCB PLY_SE_SoundEffectData_OffsetCurrentStep(R3)
        RETURN

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
      # Hardware only.
      # -------------------------------------------
PLY_SE_PSES_HardwareOnly:
      # Calls the shared code that manages everything.
        CALL PLY_SE_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Cuts the sound.
        BIS  $PLY_SE_BitForSound,R2
        BR   PLY_SE_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_HardOnly



PLY_SE_PSES_SoftwareOrSoftwareAndHardware:
      # Software only?
        ASRB R0
  .ifdef PLY_CFG_SFX_SoftAndHard # CONFIG SPECIFIC
        BCS  PLY_SE_PSES_SoftwareAndHardware
  .endif # PLY_CFG_SFX_SoftAndHard

      # Software.
      # -------------------------------------------
  .ifdef PLY_CFG_SFX_SoftOnly # CONFIG SPECIFIC
      # Volume.
        CALL PLY_SE_PSES_ManageVolumeFromR0_Filter4Bits

      # Noise?
        ASLB R1
      .ifdef PLY_CFG_SFX_SoftOnly_Noise # CONFIG SPECIFIC
        BCC  PLY_SE_PSES_SoftOnly_NoNoise
        CALL PLY_SE_PSES_ReadNoiseAndOpenNoiseChannel
PLY_SE_PSES_SoftOnly_NoNoise:
      .endif # PLY_CFG_SFX_SoftOnly_Noise

      # Opens the "sound" channel.
        BIC  $PLY_SE_BitForSound,R2

      # Reads the software period.
        CALL PLY_SE_PSES_ReadSoftwarePeriod

        BR   PLY_SE_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_SoftOnly


      # Software and Hardware.
      # -------------------------------------------
  .ifdef PLY_SE_HardwareSounds # CONFIG SPECIFIC
PLY_SE_PSES_SoftwareAndHardware:
      # Calls the shared code that manages everything.
        CALL PLY_SE_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Reads the software period.
        CALL PLY_SE_PSES_ReadSoftwarePeriod
      # Opens the sound.
        BIC  $PLY_SE_BitForSound,R2

        BR   PLY_SE_PSES_SavePointerAndExit
  .endif # PLY_SE_HardwareSounds


  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Shared code used by the "hardware only" and "software and hardware" part.
      # Reads the Retrig flag, the Hardware Envelope, the possible noise, the
      # hardware period,
      # and sets the volume to 16. The R7 sound channel is NOT modified.
PLY_SE_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise:
      # Retrig?
        ASRB R0
      .ifdef PLY_SE_UseRetrig # CONFIG SPECIFIC
        BCC  PLY_SE_PSES_H_AfterRetrig

        MOV  $255,@$PLY_SE_PSGReg13_OldValue

PLY_SE_PSES_H_AfterRetrig:
      .endif # PLY_SE_UseRetrig

      # The hardware envelope can be set (8-15).
        BIC  $0177770,R0
        ADD  $8,R0
        MOV  R0,@$PLY_SE_PSGReg13_Instr

      .ifdef PLY_SE_HardwareNoise # CONFIG SPECIFIC.
      # B not needed after, we can put it in the condition too.
      # Noise?
        ASLB R1
        BCC  PLY_SE_PSES_H_NoNoise
        CALL PLY_SE_PSES_ReadNoiseAndOpenNoiseChannel
PLY_SE_PSES_H_NoNoise:
      .endif # PLY_SE_HardwareNoise

      # Reads the hardware period.
        CALL PLY_SE_PSES_ReadHardwarePeriod

      # Sets the volume to "hardware". It still may be decreased.
        MOV  $16,R0
        BR   PLY_SE_PSES_ManageVolumeFromR0_Hard
  .endif # PLY_CFG_UseHardwareSounds


  .ifdef PLY_SE_Noise
      # Reads the noise pointed by HL, increases HL, and opens the noise channel.
PLY_SE_PSES_ReadNoiseAndOpenNoiseChannel:
      # Reads the noise.
        MOVB (R5)+,@$PLY_SE_PSGReg6

      # Opens noise channel.
        BIC  $PLY_SE_BitForNoise,R2
        RETURN
  .endif # PLY_SE_Noise

  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Reads the hardware period from HL and sets the R11/R12 registers.
      # HL is incremented of 2.
PLY_SE_PSES_ReadHardwarePeriod:
        MOVB (R5)+,@$PLY_SE_PSGHardwarePeriod_Instr
        MOVB (R5)+,@$PLY_SE_PSGHardwarePeriod_Instr+1

        RETURN
  .endif # PLY_CFG_UseHardwareSounds

      # Reads the software period from HL and sets the period registers in HL'.
      # HL is incremented of 2.
PLY_SE_PSES_ReadSoftwarePeriod:
        MOVB (R5)+,(R4)+
        MOVB (R5)+,(R4)

        RETURN

  .ifdef PLY_SE_VolumeSoft # CONFIG SPECIFIC
      # Reads the volume in A, decreases it from the inverted volume of the
      # channel, and sets the volume via IY.
      # IN:    R0 A = volume, from 0 to 15 (no hardware envelope).
PLY_SE_PSES_ManageVolumeFromR0_Filter4Bits:
        BIC  $0xFFF0,R0
   .endif # PLY_SE_VolumeSoft

   .ifdef PLY_SE_VolumeSoftOrHard # CONFIG SPECIFIC
      # After the filtering. Useful for hardware sound
      # (volume has been forced to 16).
PLY_SE_PSES_ManageVolumeFromR0_Hard:
      # Decreases the volume, checks the limit.
        SUB  PLY_SE_SoundEffectData_OffsetInvertedVolume(R3),R0
        BCC  PLY_SE_PSES_MVFA_NoOverflow

        CLR  R0
PLY_SE_PSES_MVFA_NoOverflow:
       .equiv PLY_SE_ChannelVolumePSGReg, .+2
        MOVB R0,@$0x0000
        RETURN
   .endif # PLY_SE_VolumeSoftOrHard


PLY_SE_Channel1_SoundEffectData:
       .word 0 # Points to the sound effect for the track 1, or 0 if not playing.
PLY_SE_Channel1_SoundEffectInvertedVolume:
       .word 0 # Inverted volume.
PLY_SE_Channel1_SoundEffectCurrentStep:
       .word 0 # Current step (>=0).
PLY_SE_Channel1_SoundEffectSpeed:
       .word 0 # Speed (>=0).
.equiv PLY_SE_Channel_SoundEffectDataSize, .- PLY_SE_Channel1_SoundEffectData

PLY_SE_Channel2_SoundEffectData:
       .space PLY_SE_Channel_SoundEffectDataSize, 0
PLY_SE_Channel3_SoundEffectData:
       .space PLY_SE_Channel_SoundEffectDataSize, 0

# Offset from the beginning of the data, to reach the inverted volume.
.equiv PLY_SE_SoundEffectData_OffsetInvertedVolume, PLY_SE_Channel1_SoundEffectInvertedVolume - PLY_SE_Channel1_SoundEffectData
.equiv PLY_SE_SoundEffectData_OffsetCurrentStep, PLY_SE_Channel1_SoundEffectCurrentStep - PLY_SE_Channel1_SoundEffectData
.equiv PLY_SE_SoundEffectData_OffsetSpeed, PLY_SE_Channel1_SoundEffectSpeed - PLY_SE_Channel1_SoundEffectData
