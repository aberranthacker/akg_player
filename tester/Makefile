AS=~/opt/binutils-pdp11/pdp11-dec-aout/bin/as
LD=~/opt/binutils-pdp11/pdp11-dec-aout/bin/ld
# 2.31.1

.SUFFIXES:
.SUFFIXES: .s .o

# --just-symbols= -R include only symbols from the file
# --print-map -M
# --strip-all -s

common = ../hwdefs.s ../macros.s

rt11_50sj.dsk : TEST.SAV
	../../tools/rt11dsk d rt11_50sj.dsk TEST.SAV >/dev/null
	../../tools/rt11dsk a rt11_50sj.dsk TEST.SAV

TEST.SAV : test.o
	$(LD) -T test.cmd -s
	chmod -x TEST.SAV

test.o : ../akg_player.s \
	 ../akg_sound_effects.s \
	 a_harmless_grenade_playerconfig.s \
	 a_harmless_grenade.s \
	 sound_effects.s \
         test.s $(common)
	$(AS) -alm test.s -I../ -o test.o

clean :
	rm -f *.o *.out *.SAV
