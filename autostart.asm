;
; Copyright (c) 2022 Andreas Signer <asigner@gmail.com>
;
; This program is free software: you can redistribute it and/or
; modify it under the terms of the GNU General Public License as
; published by the Free Software Foundation, either version 3 of the
; License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

	.platform "c64"

; Constants
; ---------
IOINIT	.equ	$fda3	; initialise SID, CIA and IRQ
RAMTAS	.equ	$fd50	; RAM test and find RAM end
RESTOR	.equ	$fd15	; restore default I/O vectors

BASIC_START	.equ $800 	; Actually, $801, but we need whole pages for our copy_mem code.

; Zeropage addresses
; ------------------
word1	.equ	$fb     ; $fb - $fe is free for program's usage
word2	.equ	$fd
keybuf	.equ	$277    ; for C128: $34a
keybuf_size	.equ	$c6    ; for C128: $d0
vartab	.equ	$2d

	.include "build_info.i"

	; Cartridge starts at $8000
	.org $8000

	; Cartridge magic header
	.word coldstart
	.word run_prg
	.byte "CBM80"

	; Make it easy for people to understand what ROM dump they're looking at :-)
	.byte " *** sid tester cartridge *** "
	.byte "built on ", build_timestamp, " "
	.byte "autostart wrapper copyright (c) 2022 andreas signer. "
	.byte "sid tester copyright (c) 2017 andrew challis. "
	.byte "find me on github: https://github.com/asig/c64-sid-tester-cartridge "

coldstart:
	; First part of Kernel Reset routine
	stx	$d016	; VIC CR2
	jsr IOINIT
	jsr RAMTAS
	jsr RESTOR

	; Fill keyboard buf with "sys251"
	ldx #0
_l0	lda kb_sys251,x
	beq done
	sta keybuf,x
	inx
	jmp _l0
done
	stx keybuf_size

	; Make sure there is something at 251: write a "jmp run_prg" to word1/word2
	lda #$4c	; JMP
	sta word1
	lda #<run_prg
	sta word1+1
	lda #>run_prg
	sta word1+2

	; Continue with Kernel Reset routine
	jmp $fcfb

kb_sys251	.byte "sys251",13,0

run_prg:
	; copy program from cartrdige to BASIC program space
	lda #<prg
	sta word1
	lda #>prg
	sta word1+1
	lda #<BASIC_START
	sta word2
	lda #>BASIC_START
	sta word2+1

pages	.equ (prg_end-prg+255)/256	; Workaround for bug in cbmasm's const size enforcement...
	ldx #pages	; # of pages to copy
copyloop:
	ldy #0
_l	lda (word1),y
	sta (word2),y
	iny
	bne _l
	inc word1+1
	inc word2+1
	dex
	bne copyloop

	; Update the variable storage start
var_start	.equ (prg_end-prg)+BASIC_START	; BASIC_START is off by 1, but so is prg, so we're good.
	lda #<var_start
	sta vartab
	lda #>var_start
	sta vartab+1

	; Fill keyboard buffer with "rU<cr>"
	lda #'r'
	sta keybuf
	lda #'U'
	sta keybuf+1
	lda #$0d
	sta keybuf+2
	lda #3
	sta keybuf_size

	rts

	.align 256
prg:
	.byte 0	; padding because we're going to copy full pages, and basic starts at $801/$1c01
	.incbin "sidtester.prg", 2	; The first 2 bytes are the load address in a prg, skip them.
prg_end:

	.if * > $a000
	.fail "Program too big!"
	.endif

	.org $a000
