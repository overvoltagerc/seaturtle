
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;SeaTurtle.c,40 :: 		void interrupt()
;SeaTurtle.c,42 :: 		if(GPIF_bit)
	BTFSS      GPIF_bit+0, BitPos(GPIF_bit+0)
	GOTO       L_interrupt0
;SeaTurtle.c,44 :: 		if(PPM && !PPM_level)
	BTFSS      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt3
	MOVF       _PPM_level+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
L__interrupt37:
;SeaTurtle.c,46 :: 		PPM_start = TMR0;
	MOVF       TMR0+0, 0
	MOVWF      _PPM_start+0
;SeaTurtle.c,47 :: 		PPM_level = 1;
	MOVLW      1
	MOVWF      _PPM_level+0
;SeaTurtle.c,48 :: 		}
	GOTO       L_interrupt4
L_interrupt3:
;SeaTurtle.c,49 :: 		else if(!PPM && PPM_level)
	BTFSC      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt7
	MOVF       _PPM_level+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt36:
;SeaTurtle.c,51 :: 		PPM_value = TMR0 - PPM_start;
	MOVF       _PPM_start+0, 0
	SUBWF      TMR0+0, 0
	MOVWF      _PPM_value+0
;SeaTurtle.c,52 :: 		PPM_level = 0;
	CLRF       _PPM_level+0
;SeaTurtle.c,53 :: 		PPM_updated = 1;
	MOVLW      1
	MOVWF      _PPM_updated+0
;SeaTurtle.c,54 :: 		}
L_interrupt7:
L_interrupt4:
;SeaTurtle.c,56 :: 		GPIF_bit = 0;
	BCF        GPIF_bit+0, BitPos(GPIF_bit+0)
;SeaTurtle.c,57 :: 		}
L_interrupt0:
;SeaTurtle.c,58 :: 		}
L_end_interrupt:
L__interrupt39:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_syncPPM:

;SeaTurtle.c,60 :: 		void syncPPM(unsigned char frames)
;SeaTurtle.c,63 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,64 :: 		while(i < frames)
L_syncPPM8:
	MOVF       FARG_syncPPM_frames+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM9
;SeaTurtle.c,66 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,67 :: 		while(!PPM_updated);
L_syncPPM10:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_syncPPM11
	GOTO       L_syncPPM10
L_syncPPM11:
;SeaTurtle.c,68 :: 		if(PPM_value > PPM_MIN_VALID)
	MOVF       _PPM_value+0, 0
	SUBLW      112
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM12
;SeaTurtle.c,69 :: 		i++;
	INCF       _i+0, 1
	GOTO       L_syncPPM13
L_syncPPM12:
;SeaTurtle.c,71 :: 		i = 0;
	CLRF       _i+0
L_syncPPM13:
;SeaTurtle.c,72 :: 		}
	GOTO       L_syncPPM8
L_syncPPM9:
;SeaTurtle.c,73 :: 		}
L_end_syncPPM:
	RETURN
; end of _syncPPM

_main:

;SeaTurtle.c,75 :: 		void main() {
;SeaTurtle.c,79 :: 		bsf STATUS, RP0
	BSF        STATUS+0, 5
;SeaTurtle.c,80 :: 		call 0x03ff
	CALL       1023
;SeaTurtle.c,81 :: 		movwf OSCCAL
	MOVWF      OSCCAL+0
;SeaTurtle.c,82 :: 		bcf STATUS, RP0
	BCF        STATUS+0, 5
;SeaTurtle.c,85 :: 		CMCON = 0b00010111;         // Comparatori OFF
	MOVLW      23
	MOVWF      CMCON+0
;SeaTurtle.c,86 :: 		OPTION_REG = 0b00000010;    // TMR0 con prescaler 1/8 (ciclo 2,048 msec), pull-up abilitati
	MOVLW      2
	MOVWF      OPTION_REG+0
;SeaTurtle.c,88 :: 		GIE_bit = 1;                // Interrupt generale abilitato
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;SeaTurtle.c,89 :: 		GPIE_bit = 1;               // Interrupt-On-Change abilitato
	BSF        GPIE_bit+0, BitPos(GPIE_bit+0)
;SeaTurtle.c,90 :: 		IOC = 0b00100000;           // IOC abilitato su GP5 (PPM)
	MOVLW      32
	MOVWF      IOC+0
;SeaTurtle.c,91 :: 		WPU = 0b00100000;           // Weak pull-up abilitato solo su GP5 (PPM)
	MOVLW      32
	MOVWF      WPU+0
;SeaTurtle.c,93 :: 		TRISIO5_bit = 1;
	BSF        TRISIO5_bit+0, BitPos(TRISIO5_bit+0)
;SeaTurtle.c,95 :: 		ALL_OFF();
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,96 :: 		GPIO = 0xFF;        // Tutti i buffer di uscita accesi
	MOVLW      255
	MOVWF      GPIO+0
;SeaTurtle.c,99 :: 		syncPPM(STARTUP_PPM_FRAMES);
	MOVLW      100
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,102 :: 		while(1)
L_main14:
;SeaTurtle.c,104 :: 		if(PPM_updated)
	MOVF       _PPM_updated+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main16
;SeaTurtle.c,107 :: 		if(PPM_value > PPM_1500_US)
	MOVF       _PPM_value+0, 0
	SUBLW      188
	BTFSC      STATUS+0, 0
	GOTO       L_main17
;SeaTurtle.c,109 :: 		if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
	MOVLW      133
	SUBWF      _PPM_antiglitch+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main18
;SeaTurtle.c,111 :: 		PPM_antiglitch++;
	INCF       _PPM_antiglitch+0, 1
;SeaTurtle.c,112 :: 		PPM_command = CMD_OFF;
	CLRF       _PPM_command+0
;SeaTurtle.c,113 :: 		}
	GOTO       L_main19
L_main18:
;SeaTurtle.c,115 :: 		PPM_command = CMD_ON;
	MOVLW      1
	MOVWF      _PPM_command+0
L_main19:
;SeaTurtle.c,116 :: 		}
	GOTO       L_main20
L_main17:
;SeaTurtle.c,119 :: 		if(PPM_antiglitch > ANTIGLITCH_ZERO)
	MOVF       _PPM_antiglitch+0, 0
	SUBLW      128
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;SeaTurtle.c,121 :: 		PPM_antiglitch--;
	DECF       _PPM_antiglitch+0, 1
;SeaTurtle.c,122 :: 		PPM_command = CMD_ON;
	MOVLW      1
	MOVWF      _PPM_command+0
;SeaTurtle.c,123 :: 		}
	GOTO       L_main22
L_main21:
;SeaTurtle.c,125 :: 		PPM_command = CMD_OFF;
	CLRF       _PPM_command+0
L_main22:
;SeaTurtle.c,126 :: 		}
L_main20:
;SeaTurtle.c,129 :: 		switch(PPM_command)
	GOTO       L_main23
;SeaTurtle.c,131 :: 		case CMD_ON:
L_main25:
;SeaTurtle.c,133 :: 		if(!LIGHTS_on)
	MOVF       _LIGHTS_on+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main26
;SeaTurtle.c,135 :: 		LIGHTS_on = 1;
	MOVLW      1
	MOVWF      _LIGHTS_on+0
;SeaTurtle.c,136 :: 		TAIL_ON();
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,139 :: 		HEAD_ON();  // Primo flash
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,140 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_main27:
	DECFSZ     R13+0, 1
	GOTO       L_main27
	DECFSZ     R12+0, 1
	GOTO       L_main27
	NOP
	NOP
;SeaTurtle.c,141 :: 		while(XENON_pwm < PWM_FULL)
L_main28:
	MOVLW      16
	SUBWF      _XENON_pwm+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main29
;SeaTurtle.c,143 :: 		Delay_us(PWM_DELAY_US);
	MOVLW      66
	MOVWF      R13+0
L_main30:
	DECFSZ     R13+0, 1
	GOTO       L_main30
	NOP
;SeaTurtle.c,145 :: 		if(++XENON_delay == XENON_HEAT)
	INCF       _XENON_delay+0, 1
	BTFSC      STATUS+0, 2
	INCF       _XENON_delay+1, 1
	MOVF       _XENON_delay+1, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__main42
	MOVLW      88
	XORWF      _XENON_delay+0, 0
L__main42:
	BTFSS      STATUS+0, 2
	GOTO       L_main31
;SeaTurtle.c,147 :: 		XENON_delay = 0;
	CLRF       _XENON_delay+0
	CLRF       _XENON_delay+1
;SeaTurtle.c,148 :: 		XENON_pwm++;
	INCF       _XENON_pwm+0, 1
;SeaTurtle.c,149 :: 		}
L_main31:
;SeaTurtle.c,151 :: 		if(++PWM_i > PWM_CYCLE)
	INCF       _PWM_i+0, 1
	MOVF       _PWM_i+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_main32
;SeaTurtle.c,152 :: 		PWM_i = 0;
	CLRF       _PWM_i+0
L_main32:
;SeaTurtle.c,154 :: 		if(XENON_pwm > PWM_i)
	MOVF       _XENON_pwm+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main33
;SeaTurtle.c,156 :: 		HEAD_ON();
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,157 :: 		}
	GOTO       L_main34
L_main33:
;SeaTurtle.c,160 :: 		HEAD_OFF();
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,161 :: 		}
L_main34:
;SeaTurtle.c,162 :: 		}
	GOTO       L_main28
L_main29:
;SeaTurtle.c,163 :: 		}
L_main26:
;SeaTurtle.c,164 :: 		break;
	GOTO       L_main24
;SeaTurtle.c,166 :: 		default:
L_main35:
;SeaTurtle.c,168 :: 		LIGHTS_on = 0;
	CLRF       _LIGHTS_on+0
;SeaTurtle.c,169 :: 		ALL_OFF();
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,170 :: 		XENON_pwm = PWM_OFF;
	CLRF       _XENON_pwm+0
;SeaTurtle.c,171 :: 		}
	GOTO       L_main24
L_main23:
	MOVF       _PPM_command+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main25
	GOTO       L_main35
L_main24:
;SeaTurtle.c,173 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,174 :: 		}
L_main16:
;SeaTurtle.c,175 :: 		}
	GOTO       L_main14
;SeaTurtle.c,176 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
