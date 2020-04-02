  .inesprg 1		; 1x 16KB PRG code
  .ineschr 1		; 1x 8KB CHR data
  .inesmap 0		; mapper 0 = NROM, no bank swapping
  .inesmir 1		; background mirroring
  
  .bank 0		;setting up prg bank
  .org $C000		;at addrs $C0000
  
 RESET:
	SEI		;disable IRQs
	CLD		;disable decimal mode
	LDX #$40
	STX $4017	;disable APU frame IRQ
	LDX #$FF
	TXS		;set up stack
	INX		;now X = 0
	STX $2000	;disable NMI
	STX $2001	;disable rendering
	STX $4010	;disable DMC IRQs
	
vblankwait1:		;First wait for vblank to make sure PPU is ready
	BIT $2002
	BPL vblankwait1
	
clrmem:
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0200, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	LDA #$FE
	STA $0300, x
	INX
	BNE clrmem
	
vblankwait2:		;Second wait for vblank, PPu ready after this
	BIT $2002
	BPL vblankwait2
	
LoadPalettes:
	LDA $2002	;read PPU status to reset high/low latch
	LDA #$3F
	STA $2006	;write the high byte of $3f00 address
	LDA #$00
	STA $2006	;write the low byte of $3f00
	LDX #$00	;start at 0
LoadPalettesLoop:
	LDA background_palette, x	;load data from addrss (palette + the value in x)
			;1st time in loop it wil load palette+0
			;2nd time in loop it wil load palette+1, etc
	STA $2007	;write to PPU
	INX		;X = X + 1
	CPX #$10	;Compare x to hex 10, copying 16bytes (4 sprites)
	BNE LoadPalettesLoop	;Branch to load palettesLoop if compare != 0
	
Foreverloop:
	JMP Foreverloop	;jump back forever, infinite loop
	
NMI:
	RTI
	
  .bank 1
  .org $E000		;start of palette insertion
background_palette:
  .db $22,$29,$1A,$0F	;background palette 1
  .db $22,$36,$17,$0F	;background palette 2
  .db $22,$30,$21,$0F	;background palette 3
  .db $22,$27,$17,$0F	;background palette 4

sprite_palette:
  .db $22,$16,$27,$18	;sprite palette 1
  .db $22,$1A,$30,$27	;sprite palette 2
  .db $22,$16,$30,$27	;sprite palette 3
  .db $22,$0F,$36,$17	;sprite palette 4
;code continues after palette is loaded
  
  .org $FFFA		;first of the three vectors start here
  .dw NMI		;when NPI happens (once per frame if enabled)
			;the processor will jump to NMI:
  .dw RESET		;when processor turns on or is reset
			;jump to RESET
  .dw 0			;external interrupt not used in this tut
  
  .bank 2
  .org $0000
  .incbin "mario.chr"