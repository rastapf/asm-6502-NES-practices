  .inesprg 1		; 1x 16KB PRG code
  .ineschr 1		; 1x 8KB CHR data
  .inesmap 0		; mapper 0 = NROM, no bank swapping
  .inesmir 1		; background mirroring
  
  .bank 0		;setting up prg bank
  .org $C0000		;at addrs $C0000
  
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
	
Foreverloop:
	JMP Foreverloop	;jump back forever, infinite loop
	
NMI:
	RTI
	
  .bank 1
  .org $FFFA		;first of the three vectors start here
  .dw NMI		;when NPI happens (once per frame if enabled)
			;the processor will jump to NMI:
  .dw RESET		;when processor turns on or is reset
			;jump to RESET
  .dw 0			;external interrupt not used in this tut
  
  .bank2
  .org $0000
  .incbin "mario.chr"