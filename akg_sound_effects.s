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
        PLY_AKG_SE_HardwareSounds = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard
        PLY_AKG_SE_HardwareSounds = 1
  .endif
 # Mixes the Hardware Noise flags into one.
  .ifdef PLY_CFG_SFX_HardOnly_Noise
        PLY_AKG_SE_HardwareNoise = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard_Noise
        PLY_AKG_SE_HardwareNoise = 1
  .endif
 # Mixes the Noise flags into one.
  .ifdef PLY_AKG_SE_HardwareNoise
        PLY_AKG_SE_Noise = 1
  .endif
  .ifdef PLY_CFG_SFX_NoSoftNoHard_Noise
        PLY_AKG_SE_Noise = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftOnly
        PLY_AKG_SE_Noise = 1
  .endif
 # If Noise, the R6 code in the music player must be compiled.
  .ifdef PLY_AKG_SE_Noise
        PLY_AKG_Use_NoiseRegister = 1
  .endif

 # Mixes the Software Volume flags into one.
  .ifdef PLY_CFG_SFX_NoSoftNoHard
        PLY_AKG_SE_VolumeSoft = 1
        PLY_AKG_SE_VolumeSoftOrHard = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftOnly
        PLY_AKG_SE_VolumeSoft = 1
        PLY_AKG_SE_VolumeSoftOrHard = 1
  .endif
 # Mixes the volume (soft/hard) into one.
  .ifdef PLY_CFG_UseHardwareSounds
        PLY_AKG_SE_VolumeSoftOrHard = 1
  .endif
 # Mixes the retrig flags into one.
  .ifdef PLY_CFG_SFX_HardOnly_Retrig
        PLY_AKG_SE_Retrig = 1
  .endif
  .ifdef PLY_CFG_SFX_SoftAndHard_Retrig
        PLY_AKG_SE_Retrig = 1
  .endif

# Initializes the sound effects. It MUST be called at any times before a first
# sound effect is triggered.
# It doesn't matter whether the song is playing or not, or if it has been
# initialized or not.
# IN:    R5 HL = Address to the sound effects data.
PLY_AKG_InitSoundEffects:
        MOV  R5,@$PtSoundEffectTable
        RETURN

# Plays a sound effect. If a previous one was already playing on the same
# channel, it is replaced.
# This does not actually plays the sound effect, but programs its playing.
# The music player, when called, will call the PLY_AKG_PlaySoundEffectsStream
# method below.
# IN: R0 A = Sound effect number (>0!).
#     R1 C = The channel where to play the sound effect (0, 1, 2).
#     R2 B = Inverted volume (0 = full volume, 16 = no sound). Hardware sounds are also lowered.
# corrupts R0, R3, R5
PLY_AKG_PlaySoundEffect:
      # Gets the address to the sound effect.
        DEC  R0  # The 0th is not encoded.
        ASL  R0
       .equiv PtSoundEffectTable, .+2
        MOV  0(R0),R3
      # Reads the header of the sound effect to get the speed.
        MOVB (R3)+,R0
      # Finds the pointer to the sound effect of the desired channel.
        MOV  ChannelsDataTable(R1),R5
        MOV  R3,(R5)+ # now stores pointer to next Cell of the sound effect
        MOV  R2,(R5)+ # the inverted volume
        CLR  (R5)+    # resets the current speed
        MOVB R0,(R5)  # and stores the instrument speed

        RETURN

# Stops a sound effect. Nothing happens if there was no sound effect.
# IN: R0 A = The channel where to stop the sound effect (0, 1, 2).
PLY_AKG_StopSoundEffectFromChannel:
      # Puts 0 to the pointer of the sound effect.
        CLR  @ChannelsDataTable(R0) # 0 means "no sound".
        RETURN

ChannelsDataTable: # Used to quickly get sound effects data for selected channel
       .word Channel1_SoundEffectData
       .word Channel2_SoundEffectData
       .word Channel3_SoundEffectData

# internal subroutines ---------------------------------------------------------
      # Plays the sound effects, if any has been triggered by the user.
      # This does not actually send registers to the PSG, it only overwrite the
      # required values of the registers of the player.
      # The sound effects initialization method must have been called before!
      # As R7 is required, this must be called after the music has been played,
      # but BEFORE the registers are sent to the PSG.
      # IN:  A = R7.
      # OUT: A = new R7.
PlaySoundEffectsStream: # called by music player
      # Shifts the R7 to the left twice, so that bit 2 and 5 only can be set
      # for each track, below.
        MOV  @$PSGReg7,R2
        ASL  R2
        ASL  R2
      # Plays the sound effects on every channel.
        MOV  $Channel1_SoundEffectData,R3
        MOV  $PSGReg8,@$ChannelVolumePSGReg
        MOV  $PSGReg01_Instr,R4

      # Channel 1.
      # ----------
        CALL PSES_Play
        MOV  $Channel2_SoundEffectData,R3
        MOV  $PSGReg9,@$ChannelVolumePSGReg
        MOV  $PSGReg23_Instr,R4

      # Channel 2.
      # ----------
        ASR  R2
        CALL PSES_Play
        MOV  $Channel3_SoundEffectData,R3
        MOV  $PSGReg10,@$ChannelVolumePSGReg
        MOV  $PSGReg45_Instr,R4

      # Channel 3.
      # ----------
        ASR  R2
        CALL PSES_Play

        MOV  R2,@$PSGReg7
        RETURN


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
PSES_Play:
      # Reads the pointer pointed by IX.
        MOV  (R3),R5
        BZE  1237$ # No sound to be played? Returns immediately.

      # Reads the first byte. What type of sound is it?
PSES_ReadFirstByte:
        MOVB (R5)+,R0
        MOVB R0,R1
        ASRB R0
        BCS  PSES_SoftwareOrSoftwareAndHardware
        ASRB R0

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
        BCS  PSES_HardwareOnly
  .endif # PLY_CFG_SFX_HardOnly

      # No software, no hardware, or end/loop.
      # -------------------------------------------
      # End or loop?
        ASRB R0

  .ifdef PLY_CFG_SFX_NoSoftNoHard # CONFIG SPECIFIC. If not present, the jump is
                                  # not needed, the method is just below.
        BCS  PSES_S_EndOrLoop

      # No software, no hardware.
      # -------------------------------------------
      # Gets the volume.
        CALL PSES_ManageVolumeFromR0_Filter4Bits

      # Noise?
      .ifdef PLY_CFG_SFX_NoSoftNoHard_Noise # CONFIG SPECIFIC
        ASLB R1
        BCC  PSES_NoSoftNoHard_NoNoise
        CALL PSES_ReadNoiseAndOpenNoiseChannel
PSES_NoSoftNoHard_NoNoise:
      .endif # PLY_CFG_SFX_NoSoftNoHard_Noise

        BR   PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_NoSoftNoHard

      # **Warning!** Do not put any instruction between EndOrLoop and NoSoftNoHard.

PSES_S_EndOrLoop:
      # If no "loop to", the sounds always end, no need to test.
  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC.
      # Is it an end?
        ASRB R0
        BCS  PSES_S_Loop
  .endif # PLY_CFG_SFX_LoopTo
      # End of the sound. Marks the sound pointer with 0, meaning "no sound".
        CLR  (R3)
1237$:  RETURN

  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC.
PSES_S_Loop:
      # Loops. Reads the pointer and directly uses it.
        CLR  R0
        BISB (R5)+,R0
        SWAB R0
        BISB (R5),R0
        SWAB R0
        MOV  R0,R5
        BR   PSES_ReadFirstByte
  .endif # PLY_CFG_SFX_LoopTo


      # Saves HL into IX, and exits. This must be called at the end of each
      # Cell.
      # If the speed has not been reached, it is not saved.
PSES_SavePointerAndExit:
      # Speed reached?
        CMPB SoundEffectData_OffsetCurrentStep(R3),SoundEffectData_OffsetSpeed(R3)
        BLO  PSES_NotReached
      # The speed has been reached, so resets it and saves the pointer to the
      # next cell to read.
        CLR  SoundEffectData_OffsetCurrentStep(R3)
        MOV  R5,(R3)
        RETURN

PSES_NotReached:
      # Speed not reached. Increases it, that's all. The same cell will be read
      # next time.
        INCB SoundEffectData_OffsetCurrentStep(R3)
        RETURN

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
      # Hardware only.
      # -------------------------------------------
PSES_HardwareOnly:
      # Calls the shared code that manages everything.
        CALL PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Cuts the sound.
        BIS  $BitForSound,R2
        BR   PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_HardOnly



PSES_SoftwareOrSoftwareAndHardware:
      # Software only?
        ASRB R0
  .ifdef PLY_CFG_SFX_SoftAndHard # CONFIG SPECIFIC
        BCS  PSES_SoftwareAndHardware
  .endif # PLY_CFG_SFX_SoftAndHard

      # Software.
      # -------------------------------------------
  .ifdef PLY_CFG_SFX_SoftOnly # CONFIG SPECIFIC
      # Volume.
        CALL PSES_ManageVolumeFromR0_Filter4Bits

      # Noise?
        ASLB R1
      .ifdef PLY_CFG_SFX_SoftOnly_Noise # CONFIG SPECIFIC
        BCC  PSES_SoftOnly_NoNoise
        CALL PSES_ReadNoiseAndOpenNoiseChannel
PSES_SoftOnly_NoNoise:
      .endif # PLY_CFG_SFX_SoftOnly_Noise

      # Opens the "sound" channel.
        BIC  $BitForSound,R2

      # Reads the software period.
        CALL PSES_ReadSoftwarePeriod

        BR   PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_SoftOnly


      # Software and Hardware.
      # -------------------------------------------
  .ifdef PLY_AKG_SE_HardwareSounds # CONFIG SPECIFIC
PSES_SoftwareAndHardware:
      # Calls the shared code that manages everything.
        CALL PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Reads the software period.
        CALL PSES_ReadSoftwarePeriod
      # Opens the sound.
        BIC  $BitForSound,R2

        BR   PSES_SavePointerAndExit
  .endif # PLY_AKG_SE_HardwareSounds


  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Shared code used by the "hardware only" and "software and hardware" part.
      # Reads the Retrig flag, the Hardware Envelope, the possible noise, the
      # hardware period,
      # and sets the volume to 16. The R7 sound channel is NOT modified.
PSES_Shared_ReadRetrigHardwareEnvPeriodNoise:
      # Retrig?
        ASRB R0
      .ifdef PLY_AKG_SE_Retrig # CONFIG SPECIFIC
        BCC  PSES_H_AfterRetrig

        MOV  $255,@$PSGReg13_OldValue

PSES_H_AfterRetrig:
      .endif # PLY_AKG_SE_Retrig

      # The hardware envelope can be set (8-15).
        BIC  $0177770,R0
        ADD  $8,R0
        MOV  R0,@$PSGReg13_Instr

      .ifdef PLY_AKG_SE_HardwareNoise # CONFIG SPECIFIC.
      # B not needed after, we can put it in the condition too.
      # Noise?
        ASLB R1
        BCC  PSES_H_NoNoise
        CALL PSES_ReadNoiseAndOpenNoiseChannel
PSES_H_NoNoise:
      .endif # PLY_AKG_SE_HardwareNoise

      # Reads the hardware period.
        CALL PSES_ReadHardwarePeriod

      # Sets the volume to "hardware". It still may be decreased.
        MOV  $16,R0
        BR   PSES_ManageVolumeFromR0_Hard
  .endif # PLY_CFG_UseHardwareSounds


  .ifdef PLY_AKG_SE_Noise
      # Reads the noise pointed by HL, increases HL, and opens the noise channel.
PSES_ReadNoiseAndOpenNoiseChannel:
      # Reads the noise.
        MOVB (R5)+,@$PSGReg6

      # Opens noise channel.
        BIC  $BitForNoise,R2
        RETURN
  .endif # PLY_AKG_SE_Noise

  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Reads the hardware period from HL and sets the R11/R12 registers.
      # HL is incremented of 2.
PSES_ReadHardwarePeriod:
        MOVB (R5)+,@$PSGHardwarePeriod_Instr
        MOVB (R5)+,@$PSGHardwarePeriod_Instr+1

        RETURN
  .endif # PLY_CFG_UseHardwareSounds

      # Reads the software period from HL and sets the period registers in HL'.
      # HL is incremented of 2.
PSES_ReadSoftwarePeriod:
        MOVB (R5)+,(R4)+
        MOVB (R5)+,(R4)

        RETURN

  .ifdef PLY_AKG_SE_VolumeSoft # CONFIG SPECIFIC
      # Reads the volume in A, decreases it from the inverted volume of the
      # channel, and sets the volume via IY.
      # IN:    R0 A = volume, from 0 to 15 (no hardware envelope).
PSES_ManageVolumeFromR0_Filter4Bits:
        BIC  $0xFFF0,R0
   .endif # PLY_AKG_SE_VolumeSoft

   .ifdef PLY_AKG_SE_VolumeSoftOrHard # CONFIG SPECIFIC
      # After the filtering. Useful for hardware sound
      # (volume has been forced to 16).
PSES_ManageVolumeFromR0_Hard:
      # Decreases the volume, checks the limit.
        SUB  SoundEffectData_OffsetInvertedVolume(R3),R0
        BCC  PSES_MVFA_NoOverflow

        CLR  R0
PSES_MVFA_NoOverflow:
       .equiv ChannelVolumePSGReg, .+2
        MOVB R0,@$0x0000
        RETURN
   .endif # PLY_AKG_SE_VolumeSoftOrHard


Channel1_SoundEffectData:
       .word 0 # Points to the sound effect for the track 1, or 0 if not playing.
Channel1_SoundEffectInvertedVolume:
       .word 0 # Inverted volume.
Channel1_SoundEffectCurrentStep:
       .word 0 # Current step (>=0).
Channel1_SoundEffectSpeed:
       .word 0 # Speed (>=0).
.equiv Channel_SoundEffectDataSize, .- Channel1_SoundEffectData

Channel2_SoundEffectData:
       .space Channel_SoundEffectDataSize, 0
Channel3_SoundEffectData:
       .space Channel_SoundEffectDataSize, 0

# Offset from the beginning of the data, to reach the inverted volume.
.equiv SoundEffectData_OffsetInvertedVolume, Channel1_SoundEffectInvertedVolume - Channel1_SoundEffectData
.equiv SoundEffectData_OffsetCurrentStep, Channel1_SoundEffectCurrentStep - Channel1_SoundEffectData
.equiv SoundEffectData_OffsetSpeed, Channel1_SoundEffectSpeed - Channel1_SoundEffectData
