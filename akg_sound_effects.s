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
        MOV  R5, @$PtSoundEffectTable   # ld (PLY_AKG_PtSoundEffectTable + PLY_AKG_Offset1b),hl
        RETURN                          # ret

# Plays a sound effect. If a previous one was already playing on the same
# channel, it is replaced.
# This does not actually plays the sound effect, but programs its playing.
# The music player, when called, will call the PLY_AKG_PlaySoundEffectsStream
# method below.
# IN: R0 A = Sound effect number (>0!).
#     R1 C = The channel where to play the sound effect (0, 1, 2).
#     R2 B = Inverted volume (0 = full volume, 16 = no sound). Hardware sounds are also lowered.
# corrupts R0, R3, R5
.list
PLY_AKG_PlaySoundEffect:
      # Gets the address to the sound effect.
        DEC  R0                         # dec a ;The 0th is not encoded.
        .nolist
                                        # PLY_AKG_PtSoundEffectTable: ld hl,0
                                        # ld e,a
        ASL  R0                         # ld d,0
                                        # add hl,de
                                        # add hl,de
       .equiv PtSoundEffectTable, .+2
        MOV  0(R0),R3                   # ld e,(hl)
                                        # inc hl
                                        # ld d,(hl)
      # Reads the header of the sound effect to get the speed.
        MOVB (R3)+,R0                   # ld a,(de)
                                        # inc de
                                        # ex af,af'
                                        #
                                        # ld a,b

      # Finds the pointer to the sound effect of the desired channel.
                                        # ld hl,PLY_AKG_Channel1_SoundEffectData
                                        # ld b,0
                                        # sla c
                                        # sla c
                                        # sla c
        MOV  ChannelsDataTable(R1),R5   # add hl,bc
        MOV  R3,(R5)+                   # ld (hl),e
                                        # inc hl
                                        # ld (hl),d
                                        # inc hl
      # Now stores the inverted volume.
        MOV  R2,(R5)+                   # ld (hl),a
                                        # inc hl
      # Resets the current speed, stores the instrument speed.
        CLR  (R5)+                      # ld (hl),0
                                        # inc hl
                                        # ex af,af'
        MOVB R0,(R5)                    # ld (hl),a

        RETURN                          # ret

# Stops a sound effect. Nothing happens if there was no sound effect.
# IN: R0 A = The channel where to stop the sound effect (0, 1, 2).
PLY_AKG_StopSoundEffectFromChannel:
      # Puts 0 to the pointer of the sound effect.
                                        # add a,a
                                        # add a,a
                                        # add a,a
                                        # ld e,a
                                        # ld d,0
                                        # ld hl,PLY_AKG_Channel1_SoundEffectData
                                        # add hl,de
        CLR  @ChannelsDataTable(R0)     # ld (hl),d ;0 means "no sound".
                                        # inc hl
                                        # ld (hl),d
        RETURN                          # ret
ChannelsDataTable:
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
        ASL  R2                              # rla
        ASL  R2                              # rla
      # Plays the sound effects on every channel.
        MOV  $Channel1_SoundEffectData,R3    # ld ix,PLY_AKG_Channel1_SoundEffectData
        MOV  $PSGReg8,@$ChannelVolumePSGReg  # ld iy,PLY_AKG_PSGReg8
        MOV  $PSGReg01_Instr,R4              # ld hl,PLY_AKG_PSGReg01_Instr + PLY_AKG_Offset1b
                                             # exx
                                             # ld c,a
      # Channel 1.
      # ----------
        CALL PSES_Play                       # call PLY_AKG_PSES_Play
        MOV  $Channel2_SoundEffectData,R3    # ld ix,PLY_AKG_Channel2_SoundEffectData
        MOV  $PSGReg9,@$ChannelVolumePSGReg  # ld iy,PLY_AKG_PSGReg9
                                             # exx
        MOV  $PSGReg23_Instr,R4              # ld hl,PLY_AKG_PSGReg23_Instr + PLY_AKG_Offset1b
                                             # exx
      # Channel 2.
      # ----------
        ASR  R2                              # rr c  ;On other platforms, we don't care.
                                             #
        CALL PSES_Play                       # call PLY_AKG_PSES_Play
        MOV  $Channel3_SoundEffectData,R3    # ld ix,PLY_AKG_Channel3_SoundEffectData
        MOV  $PSGReg10,@$ChannelVolumePSGReg # ld iy,PLY_AKG_PSGReg10
                                             # exx
        MOV  $PSGReg45_Instr,R4              # ld hl,PLY_AKG_PSGReg45_Instr + PLY_AKG_Offset1b
                                             # exx
      # Channel 3.
      # ----------
        ASR  R2                              # rr c
        CALL PSES_Play                       # call PLY_AKG_PSES_Play
                                             #
        MOV  R2,@$PSGReg7                    # ld a,c
        RETURN                               # ret


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
        MOV  (R3),R5                    # ld l,(ix + 0)
                                        # ld h,(ix + 1)
                                        # ld a,l
                                        # or h
        BZE  1237$                      # ret z ;No sound to be played? Returns immediately.

.list
      # Reads the first byte. What type of sound is it?
PSES_ReadFirstByte:
        MOVB (R5)+,R0                           # ld a,(hl)
.nolist
                                                # inc hl
        MOVB R0,R1                              # ld b,a
        ASRB R0                                 # rra
        BCS  PSES_SoftwareOrSoftwareAndHardware # jr c,PLY_AKG_PSES_SoftwareOrSoftwareAndHardware
        ASRB R0                                 # rra

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
        BCS  PSES_HardwareOnly                  # jr c,PLY_AKG_PSES_HardwareOnly
  .endif # PLY_CFG_SFX_HardOnly

      # No software, no hardware, or end/loop.
      # -------------------------------------------
      # End or loop?
        ASRB R0                         # rra

  .ifdef PLY_CFG_SFX_NoSoftNoHard # CONFIG SPECIFIC. If not present, the jump is not needed, the method is just below.
        BCS  PSES_S_EndOrLoop   # jr c,PLY_AKG_PSES_S_EndOrLoop

      # No software, no hardware.
      # -------------------------------------------
      # Gets the volume.
        CALL PSES_ManageVolumeFromR0_Filter4Bits # call PLY_AKG_PSES_ManageVolumeFromA_Filter4Bits

      # Noise?
      .ifdef PLY_CFG_SFX_NoSoftNoHard_Noise # CONFIG SPECIFIC
        ASLB R1                         # rl b
        BCC  .+6                        # call c,PLY_AKG_PSES_ReadNoiseAndOpenNoiseChannel
        CALL PSES_ReadNoiseAndOpenNoiseChannel
      .endif # PLY_CFG_SFX_NoSoftNoHard_Noise

        BR   PSES_SavePointerAndExit # jr PLY_AKG_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_NoSoftNoHard

      # **Warning!** Do not put any instruction between EndOrLoop and NoSoftNoHard.

PSES_S_EndOrLoop:
      # If no "loop to", the sounds always end, no need to test.
  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC. 
      # Is it an end?
        ASRB R0                 # rra
        BCS  PSES_S_Loop        # jr c,PLY_AKG_PSES_S_Loop
  .endif # PLY_CFG_SFX_LoopTo
      # End of the sound. Marks the sound pointer with 0, meaning "no sound".
        CLR  (R3)               # xor a
                                # ld (ix + 0),a
                                # ld (ix + 1),a
1237$:  RETURN                  # ret

  .ifdef PLY_CFG_SFX_LoopTo # CONFIG SPECIFIC.
PSES_S_Loop:
      # Loops. Reads the pointer and directly uses it.
      # TODO: align loop pointers
        CLR  R0
        BISB (R5)+,R0                   # ld a,(hl)
        SWAB R0                         # inc hl
        BISB (R5),R0                    # ld h,(hl)
        SWAB R0                         # ld l,a
        MOV  R0,R5
        BR   PSES_ReadFirstByte         # jr PLY_AKG_PSES_ReadFirstByte
  .endif # PLY_CFG_SFX_LoopTo


      # Saves HL into IX, and exits. This must be called at the end of each
      # Cell.
      # If the speed has not been reached, it is not saved.
PSES_SavePointerAndExit:
      # Speed reached?
        CMPB SoundEffectData_OffsetCurrentStep(R3),SoundEffectData_OffsetSpeed(R3) 
                                        # ld a,(ix + PLY_AKG_SoundEffectData_OffsetCurrentStep)
                                        # cp (ix + PLY_AKG_SoundEffectData_OffsetSpeed)
        BLO  PSES_NotReached            # jr c,PLY_AKG_PSES_NotReached
      # The speed has been reached, so resets it and saves the pointer to the
      # next cell to read.
        CLR  SoundEffectData_OffsetCurrentStep(R3) # ld (ix + PLY_AKG_SoundEffectData_OffsetCurrentStep),0
                                                   # ld (ix + 0),l
        MOV  R5,(R3)                               # ld (ix + 1),h
        RETURN                                     # ret

PSES_NotReached:
      # Speed not reached. Increases it, that's all. The same cell will be read
      # next time.
        INCB SoundEffectData_OffsetCurrentStep(R3) # inc (ix + PLY_AKG_SoundEffectData_OffsetCurrentStep)
        RETURN                          # ret

  .ifdef PLY_CFG_SFX_HardOnly # CONFIG SPECIFIC
      # Hardware only.
      # -------------------------------------------
PSES_HardwareOnly:
      # Calls the shared code that manages everything.
        CALL PSES_Shared_ReadRetrigHardwareEnvPeriodNoise # call PLY_AKG_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Cuts the sound.
        BIT  $BitForSound,R2            # set 2,c
                                        #
        BR   PSES_SavePointerAndExit    # jr PLY_AKG_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_HardOnly



PSES_SoftwareOrSoftwareAndHardware:
      # Software only?
        ASRB R0                               # rra
  .ifdef PLY_CFG_SFX_SoftAndHard # CONFIG SPECIFIC
        BCS  PSES_SoftwareAndHardware         # jr c,PLY_AKG_PSES_SoftwareAndHardware
  .endif # PLY_CFG_SFX_SoftAndHard
                                              #
      # Software.
      # -------------------------------------------
  .ifdef PLY_CFG_SFX_SoftOnly # CONFIG SPECIFIC
      # Volume.
        CALL PSES_ManageVolumeFromR0_Filter4Bits # call PLY_AKG_PSES_ManageVolumeFromA_Filter4Bits
                                                #
      # Noise?
        ASLB R1                                 # rl b
      .ifdef PLY_CFG_SFX_SoftOnly_Noise                 # CONFIG SPECIFIC
        BCC  .+6                                # call c,PLY_AKG_PSES_ReadNoiseAndOpenNoiseChannel
        CALL PSES_ReadNoiseAndOpenNoiseChannel
      .endif # PLY_CFG_SFX_SoftOnly_Noise
                                                #
      # Opens the "sound" channel.
        BIC  $BitForSound,R2                    # res 2,c
                                                #
      # Reads the software period.
        CALL PSES_ReadSoftwarePeriod # call PLY_AKG_PSES_ReadSoftwarePeriod
                                                #
        BR   PSES_SavePointerAndExit            # jr PLY_AKG_PSES_SavePointerAndExit
  .endif # PLY_CFG_SFX_SoftOnly


      # Software and Hardware.
      # -------------------------------------------
  .ifdef PLY_AKG_SE_HardwareSounds # CONFIG SPECIFIC
PSES_SoftwareAndHardware:
      # Calls the shared code that manages everything.
        CALL PSES_Shared_ReadRetrigHardwareEnvPeriodNoise # call PLY_AKG_PSES_Shared_ReadRetrigHardwareEnvPeriodNoise
      # Reads the software period.
        CALL PSES_ReadSoftwarePeriod    # call PLY_AKG_PSES_ReadSoftwarePeriod
      # Opens the sound.
        BIC  $BitForSound,R2            # res 2,c
                                        #
        BR   PSES_SavePointerAndExit    # jr PLY_AKG_PSES_SavePointerAndExit
  .endif # PLY_AKG_SE_HardwareSounds
                                        #
                                        #
  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Shared code used by the "hardware only" and "software and hardware" part.
      # Reads the Retrig flag, the Hardware Envelope, the possible noise, the
      # hardware period,
      # and sets the volume to 16. The R7 sound channel is NOT modified.
PSES_Shared_ReadRetrigHardwareEnvPeriodNoise:
      # Retrig?
        ASRB R0                       # rra
      .ifdef PLY_AKG_SE_Retrig # CONFIG SPECIFIC
        BCC  PSES_H_AfterRetrig       # jr nc,PLY_AKG_PSES_H_AfterRetrig
                                      # ld d,a
                                      # ld a,255
        MOV  $255,@$PSGReg13_OldValue # ld (PLY_AKG_PSGReg13_OldValue + PLY_AKG_Offset1b),a
                                      # ld a,d
PSES_H_AfterRetrig:
      .endif # PLY_AKG_SE_Retrig

      # The hardware envelope can be set (8-15).
        BIC  $0177770,R0         # and %111
        ADD  $8,R0               # add a,8
        MOV  R0,@$PSGReg13_Instr # ld (PLY_AKG_PSGReg13_Instr + PLY_AKG_Offset1b),a

      .ifdef PLY_AKG_SE_HardwareNoise # CONFIG SPECIFIC.
      # B not needed after, we can put it in the condition too.
      # Noise?
        ASLB R1                         # rl b
        BCC  .+6                        # call c,PLY_AKG_PSES_ReadNoiseAndOpenNoiseChannel
        CALL PSES_ReadNoiseAndOpenNoiseChannel
      .endif # PLY_AKG_SE_HardwareNoise
                                        #
      # Reads the hardware period.
        CALL PSES_ReadHardwarePeriod      # call PLY_AKG_PSES_ReadHardwarePeriod
                                          #
      # Sets the volume to "hardware". It still may be decreased.
        MOV  $16,R0                       # ld a,16
        BR   PSES_ManageVolumeFromR0_Hard # jp PLY_AKG_PSES_ManageVolumeFromA_Hard
  .endif # PLY_CFG_UseHardwareSounds


  .ifdef PLY_AKG_SE_Noise
      # Reads the noise pointed by HL, increases HL, and opens the noise channel.
PSES_ReadNoiseAndOpenNoiseChannel:
      # Reads the noise.
        MOVB (R5)+,@$PSGReg6            # ld a,(hl)
                                        # ld (PLY_AKG_PSGReg6),a
                                        # inc hl
      # Opens noise channel.
        BIC  $BitForNoise,R2            # res 5,c
        RETURN                          # ret
  .endif # PLY_AKG_SE_Noise

  .ifdef PLY_CFG_UseHardwareSounds # CONFIG SPECIFIC
      # Reads the hardware period from HL and sets the R11/R12 registers. HL is incremented of 2.
PSES_ReadHardwarePeriod:
                                               # ld a,(hl)
        MOVB (R5)+,@$PSGHardwarePeriod_Instr   # ld (PLY_AKG_PSGHardwarePeriod_Instr + PLY_AKG_Offset1b),a
                                               # inc hl
                                               # ld a,(hl)
        MOVB (R5)+,@$PSGHardwarePeriod_Instr+1 # ld (PLY_AKG_PSGHardwarePeriod_Instr + PLY_AKG_Offset1b + 1),a
                                               # inc hl
        RETURN                                 # ret
  .endif # PLY_CFG_UseHardwareSounds

      # Reads the software period from HL and sets the period registers in HL'.
      # HL is incremented of 2.
PSES_ReadSoftwarePeriod:
                                        # ld a,(hl)
                                        # inc hl
                                        # exx
                                        #         ld (hl),a
        MOVB (R5)+,(R4)+                #         inc hl
                                        # exx
                                        # ld a,(hl)
                                        # inc hl
                                        # exx
        MOVB (R5)+,(R4)                 #         ld (hl),a
                                        # exx
        RETURN                          # ret

  .ifdef PLY_AKG_SE_VolumeSoft # CONFIG SPECIFIC
      # Reads the volume in A, decreases it from the inverted volume of the
      # channel, and sets the volume via IY.
      # IN:    A = volume, from 0 to 15 (no hardware envelope).
PSES_ManageVolumeFromR0_Filter4Bits:
        BIC  $0xFFF0,R0                 # and %1111
   .endif # PLY_AKG_SE_VolumeSoft

   .ifdef PLY_AKG_SE_VolumeSoftOrHard # CONFIG SPECIFIC
      # After the filtering. Useful for hardware sound
      # (volume has been forced to 16).
PSES_ManageVolumeFromR0_Hard:
      # Decreases the volume, checks the limit.
        SUB  SoundEffectData_OffsetInvertedVolume(R3),R0 # sub (ix + PLY_AKG_SoundEffectData_OffsetInvertedVolume)
        BCC  PSES_MVFA_NoOverflow       # jr nc,PLY_AKG_PSES_MVFA_NoOverflow
        CLR  R0                         # xor a
PSES_MVFA_NoOverflow:
       .equiv ChannelVolumePSGReg, .+2
        MOVB R0,@$0x0000                # ld (iy + 0),a
        RETURN                          # ret
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
