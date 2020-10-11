AS=~/opt/binutils-pdp11/pdp11-dec-aout/bin/as
LD=~/opt/binutils-pdp11/pdp11-dec-aout/bin/ld
# 2.31.1

.SUFFIXES:
.SUFFIXES: .s .o

# --just-symbols= -R include only symbols from the file
# --print-map -M
# --strip-all -s

common = hwdefs.s macros.s

TEST.SAV : test.o
	$(LD) -T test.cmd -s
	chmod -x TEST.SAV
	../tools/rt11dsk d rt11sj.dsk TEST.SAV
	../tools/rt11dsk a rt11sj.dsk TEST.SAV

test.o : akg_player.s \
         akg_player_config.s \
         Tom&Jerry\ -\ Sudoku\ -\ Menu.akg.s \
         test.s $(common)
	$(AS) -al test.s -o test.o

clean :
	rm -f *.o *.out *.SAV
