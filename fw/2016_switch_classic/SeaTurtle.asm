
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;SeaTurtle.c,33 :: 		void interrupt()
;SeaTurtle.c,35 :: 		if(GPIF_bit)
	BTFSS      GPIF_bit+0, BitPos(GPIF_bit+0)
	GOTO       L_interrupt0
;SeaTurtle.c,37 :: 		if(PPM && !PPM_level)
	BTFSS      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt3
	MOVF       _PPM_level+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
L__interrupt28:
;SeaTurtle.c,39 :: 		PPM_start = TMR0;
	MOVF       TMR0+0, 0
	MOVWF      _PPM_start+0
;SeaTurtle.c,40 :: 		PPM_level = 1;
	MOVLW      1
	MOVWF      _PPM_level+0
;SeaTurtle.c,41 :: 		}
	GOTO       L_interrupt4
L_interrupt3:
;SeaTurtle.c,42 :: 		else if(!PPM && PPM_level)
	BTFSC      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt7
	MOVF       _PPM_level+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt27:
;SeaTurtle.c,44 :: 		PPM_value = TMR0 - PPM_start;
	MOVF       _PPM_start+0, 0
	SUBWF      TMR0+0, 0
	MOVWF      _PPM_value+0
;SeaTurtle.c,45 :: 		PPM_level = 0;
	CLRF       _PPM_level+0
;SeaTurtle.c,46 :: 		PPM_updated = 1;
	MOVLW      1
	MOVWF      _PPM_updated+0
;SeaTurtle.c,47 :: 		}
L_interrupt7:
L_interrupt4:
;SeaTurtle.c,49 :: 		GPIF_bit = 0;
	BCF        GPIF_bit+0, BitPos(GPIF_bit+0)
;SeaTurtle.c,50 :: 		}
L_interrupt0:
;SeaTurtle.c,51 :: 		}
L_end_interrupt:
L__interrupt30:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_syncPPM:

;SeaTurtle.c,53 :: 		void syncPPM(unsigned char frames)
;SeaTurtle.c,56 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,57 :: 		while(i < frames)
L_syncPPM8:
	MOVF       FARG_syncPPM_frames+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM9
;SeaTurtle.c,59 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,60 :: 		while(!PPM_updated);
L_syncPPM10:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_syncPPM11
	GOTO       L_syncPPM10
L_syncPPM11:
;SeaTurtle.c,61 :: 		if(PPM_value > PPM_MIN_VALID)
	MOVF       _PPM_value+0, 0
	SUBLW      112
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM12
;SeaTurtle.c,62 :: 		i++;
	INCF       _i+0, 1
	GOTO       L_syncPPM13
L_syncPPM12:
;SeaTurtle.c,64 :: 		i = 0;
	CLRF       _i+0
L_syncPPM13:
;SeaTurtle.c,65 :: 		}
	GOTO       L_syncPPM8
L_syncPPM9:
;SeaTurtle.c,66 :: 		}
L_end_syncPPM:
	RETURN
; end of _syncPPM

_main:

;SeaTurtle.c,68 :: 		void main() {
;SeaTurtle.c,72 :: 		bsf STATUS, RP0
	BSF        STATUS+0, 5
;SeaTurtle.c,73 :: 		call 0x03ff
	CALL       1023
;SeaTurtle.c,74 :: 		movwf OSCCAL
	MOVWF      OSCCAL+0
;SeaTurtle.c,75 :: 		bcf STATUS, RP0
	BCF        STATUS+0, 5
;SeaTurtle.c,78 :: 		CMCON = 0b00010111;         // Comparatori OFF
	MOVLW      23
	MOVWF      CMCON+0
;SeaTurtle.c,79 :: 		OPTION_REG = 0b00000010;    // TMR0 con prescaler 1/8 (ciclo 2,048 msec), pull-up abilitati
	MOVLW      2
	MOVWF      OPTION_REG+0
;SeaTurtle.c,81 :: 		GIE_bit = 1;                // Interrupt generale abilitato
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;SeaTurtle.c,82 :: 		GPIE_bit = 1;               // Interrupt-On-Change abilitato
	BSF        GPIE_bit+0, BitPos(GPIE_bit+0)
;SeaTurtle.c,83 :: 		IOC = 0b00100000;           // IOC abilitato su GP5 (PPM)
	MOVLW      32
	MOVWF      IOC+0
;SeaTurtle.c,84 :: 		WPU = 0b00100000;           // Weak pull-up abilitato solo su GP5 (PPM)
	MOVLW      32
	MOVWF      WPU+0
;SeaTurtle.c,86 :: 		TRISIO5_bit = 1;
	BSF        TRISIO5_bit+0, BitPos(TRISIO5_bit+0)
;SeaTurtle.c,88 :: 		ALL_OFF();
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,89 :: 		GPIO = 0xFF;        // Tutti i buffer di uscita accesi
	MOVLW      255
	MOVWF      GPIO+0
;SeaTurtle.c,92 :: 		syncPPM(STARTUP_PPM_FRAMES);
	MOVLW      100
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,95 :: 		while(1)
L_main14:
;SeaTurtle.c,97 :: 		if(PPM_updated)
	MOVF       _PPM_updated+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main16
;SeaTurtle.c,100 :: 		if(PPM_value > PPM_1500_US)
	MOVF       _PPM_value+0, 0
	SUBLW      188
	BTFSC      STATUS+0, 0
	GOTO       L_main17
;SeaTurtle.c,102 :: 		if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
	MOVLW      133
	SUBWF      _PPM_antiglitch+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main18
;SeaTurtle.c,104 :: 		PPM_antiglitch++;
	INCF       _PPM_antiglitch+0, 1
;SeaTurtle.c,105 :: 		PPM_command = CMD_OFF;
	CLRF       _PPM_command+0
;SeaTurtle.c,106 :: 		}
	GOTO       L_main19
L_main18:
;SeaTurtle.c,108 :: 		PPM_command = CMD_ON;
	MOVLW      1
	MOVWF      _PPM_command+0
L_main19:
;SeaTurtle.c,109 :: 		}
	GOTO       L_main20
L_main17:
;SeaTurtle.c,112 :: 		if(PPM_antiglitch > ANTIGLITCH_ZERO)
	MOVF       _PPM_antiglitch+0, 0
	SUBLW      128
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;SeaTurtle.c,114 :: 		PPM_antiglitch--;
	DECF       _PPM_antiglitch+0, 1
;SeaTurtle.c,115 :: 		PPM_command = CMD_ON;
	MOVLW      1
	MOVWF      _PPM_command+0
;SeaTurtle.c,116 :: 		}
	GOTO       L_main22
L_main21:
;SeaTurtle.c,118 :: 		PPM_command = CMD_OFF;
	CLRF       _PPM_command+0
L_main22:
;SeaTurtle.c,119 :: 		}
L_main20:
;SeaTurtle.c,122 :: 		switch(PPM_command)
	GOTO       L_main23
;SeaTurtle.c,124 :: 		case CMD_ON:
L_main25:
;SeaTurtle.c,126 :: 		HEAD_ON();
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,127 :: 		TAIL_ON();
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,128 :: 		break;
	GOTO       L_main24
;SeaTurtle.c,130 :: 		default:
L_main26:
;SeaTurtle.c,132 :: 		ALL_OFF();
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,133 :: 		}
	GOTO       L_main24
L_main23:
	MOVF       _PPM_command+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main25
	GOTO       L_main26
L_main24:
;SeaTurtle.c,135 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,136 :: 		}
L_main16:
;SeaTurtle.c,137 :: 		}
	GOTO       L_main14
;SeaTurtle.c,138 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
