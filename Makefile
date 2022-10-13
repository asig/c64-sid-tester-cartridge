.PHONY: clean

all: sidtester.crt

sidtester.prg: resources/sid-tester-1.zip
	@unzip -o resources/sid-tester-1.zip -d /tmp
	@c1541 -attach "/tmp/sid tester.d64" -read sidtester sidtester.prg

build_info.i: sidtester.prg autostart.asm
	@echo 'build_timestamp  .equ "'$$(date -u --iso-8601=s |  tr [:upper:] [:lower:])'"' > build_info.i

sidtester.bin: sidtester.prg autostart.asm build_info.i
	@cbmasm -plain autostart.asm sidtester.bin

sidtester.crt: sidtester.bin
	@cartconv -t normal -i sidtester.bin -o sidtester.crt -n "SID Tester" -p

clean:
	@rm -f sidtester.prg sidtester.bin sidtester.crt
