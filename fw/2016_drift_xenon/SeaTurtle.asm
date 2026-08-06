
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;SeaTurtle.c,55 :: 		void interrupt()
;SeaTurtle.c,57 :: 		if(GPIF_bit)
	BTFSS      GPIF_bit+0, BitPos(GPIF_bit+0)
	GOTO       L_interrupt0
;SeaTurtle.c,59 :: 		if(PPM && !PPM_level)
	BTFSS      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt3
	MOVF       _PPM_level+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
L__interrupt107:
;SeaTurtle.c,61 :: 		PPM_start = TMR0;
	MOVF       TMR0+0, 0
	MOVWF      _PPM_start+0
;SeaTurtle.c,62 :: 		PPM_level = 1;
	MOVLW      1
	MOVWF      _PPM_level+0
;SeaTurtle.c,63 :: 		}
	GOTO       L_interrupt4
L_interrupt3:
;SeaTurtle.c,64 :: 		else if(!PPM && PPM_level)
	BTFSC      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt7
	MOVF       _PPM_level+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt106:
;SeaTurtle.c,66 :: 		PPM_value = TMR0 - PPM_start;
	MOVF       _PPM_start+0, 0
	SUBWF      TMR0+0, 0
	MOVWF      _PPM_value+0
;SeaTurtle.c,67 :: 		PPM_level = 0;
	CLRF       _PPM_level+0
;SeaTurtle.c,68 :: 		PPM_updated = 1;
	MOVLW      1
	MOVWF      _PPM_updated+0
;SeaTurtle.c,69 :: 		}
L_interrupt7:
L_interrupt4:
;SeaTurtle.c,71 :: 		GPIF_bit = 0;
	BCF        GPIF_bit+0, BitPos(GPIF_bit+0)
;SeaTurtle.c,72 :: 		}
L_interrupt0:
;SeaTurtle.c,73 :: 		}
L_end_interrupt:
L__interrupt113:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_syncPPM:

;SeaTurtle.c,75 :: 		void syncPPM(unsigned char frames)
;SeaTurtle.c,78 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,79 :: 		while(i < frames)
L_syncPPM8:
	MOVF       FARG_syncPPM_frames+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM9
;SeaTurtle.c,81 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,82 :: 		while(!PPM_updated);
L_syncPPM10:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_syncPPM11
	GOTO       L_syncPPM10
L_syncPPM11:
;SeaTurtle.c,83 :: 		if(PPM_value > PPM_MIN_VALID)
	MOVF       _PPM_value+0, 0
	SUBLW      112
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM12
;SeaTurtle.c,84 :: 		i++;
	INCF       _i+0, 1
	GOTO       L_syncPPM13
L_syncPPM12:
;SeaTurtle.c,86 :: 		i = 0;
	CLRF       _i+0
L_syncPPM13:
;SeaTurtle.c,87 :: 		}
	GOTO       L_syncPPM8
L_syncPPM9:
;SeaTurtle.c,88 :: 		}
L_end_syncPPM:
	RETURN
; end of _syncPPM

_hardwareTest:

;SeaTurtle.c,90 :: 		void hardwareTest()
;SeaTurtle.c,92 :: 		while(1)
L_hardwareTest14:
;SeaTurtle.c,94 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,95 :: 		while(!PPM_updated);
L_hardwareTest16:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_hardwareTest17
	GOTO       L_hardwareTest16
L_hardwareTest17:
;SeaTurtle.c,97 :: 		if(PPM_value < PPM_1250_US)
	MOVLW      156
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest18
;SeaTurtle.c,99 :: 		HEAD = 0;
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,100 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,101 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,102 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,103 :: 		}
	GOTO       L_hardwareTest19
L_hardwareTest18:
;SeaTurtle.c,104 :: 		else if(PPM_value < PPM_1500_US)
	MOVLW      188
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest20
;SeaTurtle.c,106 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,107 :: 		TAIL = 0;
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,108 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,109 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,110 :: 		}
	GOTO       L_hardwareTest21
L_hardwareTest20:
;SeaTurtle.c,111 :: 		else if(PPM_value < PPM_1750_US)
	MOVLW      219
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest22
;SeaTurtle.c,113 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,114 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,115 :: 		REV = 0;
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,116 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,117 :: 		}
	GOTO       L_hardwareTest23
L_hardwareTest22:
;SeaTurtle.c,120 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,121 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,122 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,123 :: 		EXH = 0;
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,124 :: 		}
L_hardwareTest23:
L_hardwareTest21:
L_hardwareTest19:
;SeaTurtle.c,125 :: 		}
	GOTO       L_hardwareTest14
;SeaTurtle.c,126 :: 		}
L_end_hardwareTest:
	RETURN
; end of _hardwareTest

_userSetup:

;SeaTurtle.c,128 :: 		void userSetup()
;SeaTurtle.c,131 :: 		ALL_ON();
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,134 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,135 :: 		if(PPM_value > PPM_1500_US)
	MOVF       _PPM_value+0, 0
	SUBLW      188
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup24
;SeaTurtle.c,137 :: 		PPM_reverse = 0;
	CLRF       _PPM_reverse+0
;SeaTurtle.c,138 :: 		while(i < PROGRAM_PPM_FRAMES)
L_userSetup25:
	MOVLW      150
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup26
;SeaTurtle.c,140 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,141 :: 		while(!PPM_updated);
L_userSetup27:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_userSetup28
	GOTO       L_userSetup27
L_userSetup28:
;SeaTurtle.c,143 :: 		if(PPM_value > PPM_full)
	MOVF       _PPM_value+0, 0
	SUBWF      _PPM_full+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup29
;SeaTurtle.c,145 :: 		PPM_full = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,146 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,147 :: 		}
	GOTO       L_userSetup30
L_userSetup29:
;SeaTurtle.c,149 :: 		i++;
	INCF       _i+0, 1
L_userSetup30:
;SeaTurtle.c,150 :: 		}
	GOTO       L_userSetup25
L_userSetup26:
;SeaTurtle.c,151 :: 		}
	GOTO       L_userSetup31
L_userSetup24:
;SeaTurtle.c,154 :: 		PPM_reverse = 1;
	MOVLW      1
	MOVWF      _PPM_reverse+0
;SeaTurtle.c,155 :: 		while(i < PROGRAM_PPM_FRAMES)
L_userSetup32:
	MOVLW      150
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup33
;SeaTurtle.c,157 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,158 :: 		while(!PPM_updated);
L_userSetup34:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_userSetup35
	GOTO       L_userSetup34
L_userSetup35:
;SeaTurtle.c,160 :: 		if(PPM_value < PPM_full)
	MOVF       _PPM_full+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup36
;SeaTurtle.c,162 :: 		PPM_full = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,163 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,164 :: 		}
	GOTO       L_userSetup37
L_userSetup36:
;SeaTurtle.c,166 :: 		i++;
	INCF       _i+0, 1
L_userSetup37:
;SeaTurtle.c,167 :: 		}
	GOTO       L_userSetup32
L_userSetup33:
;SeaTurtle.c,168 :: 		}
L_userSetup31:
;SeaTurtle.c,171 :: 		EEPROM_Write(EEPROM_PPMFULL, PPM_full);
	MOVLW      2
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       _PPM_full+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,173 :: 		ALL_OFF();
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,176 :: 		while(PPM_value > PPM_1600_US || PPM_value < PPM_1400_US);
L_userSetup38:
	MOVF       _PPM_value+0, 0
	SUBLW      200
	BTFSS      STATUS+0, 0
	GOTO       L__userSetup108
	MOVLW      175
	SUBWF      _PPM_value+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__userSetup108
	GOTO       L_userSetup39
L__userSetup108:
	GOTO       L_userSetup38
L_userSetup39:
;SeaTurtle.c,179 :: 		syncPPM(PROGRAM_PPM_FRAMES);
	MOVLW      150
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,180 :: 		PPM_neutral = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_neutral+0
;SeaTurtle.c,181 :: 		EEPROM_Write(EEPROM_PPMNEUTRAL, PPM_neutral);
	MOVLW      1
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       _PPM_value+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,182 :: 		EEPROM_Write(EEPROM_TESTED, 0);
	CLRF       FARG_EEPROM_Write_Address+0
	CLRF       FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,183 :: 		}
L_end_userSetup:
	RETURN
; end of _userSetup

_main:

;SeaTurtle.c,185 :: 		void main() {
;SeaTurtle.c,189 :: 		bsf STATUS, RP0
	BSF        STATUS+0, 5
;SeaTurtle.c,190 :: 		call 0x03ff
	CALL       1023
;SeaTurtle.c,191 :: 		movwf OSCCAL
	MOVWF      OSCCAL+0
;SeaTurtle.c,192 :: 		bcf STATUS, RP0
	BCF        STATUS+0, 5
;SeaTurtle.c,195 :: 		CMCON = 0b00010111;         // Comparatori OFF
	MOVLW      23
	MOVWF      CMCON+0
;SeaTurtle.c,196 :: 		OPTION_REG = 0b00000010;    // TMR0 con prescaler 1/8 (ciclo 2,048 msec), pull-up abilitati
	MOVLW      2
	MOVWF      OPTION_REG+0
;SeaTurtle.c,198 :: 		GIE_bit = 1;                // Interrupt generale abilitato
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;SeaTurtle.c,199 :: 		GPIE_bit = 1;               // Interrupt-On-Change abilitato
	BSF        GPIE_bit+0, BitPos(GPIE_bit+0)
;SeaTurtle.c,200 :: 		IOC = 0b00100000;           // IOC abilitato su GP5 (PPM)
	MOVLW      32
	MOVWF      IOC+0
;SeaTurtle.c,201 :: 		WPU = 0b00100000;           // Weak pull-up abilitato solo su GP5 (PPM)
	MOVLW      32
	MOVWF      WPU+0
;SeaTurtle.c,203 :: 		TRISIO5_bit = 1;
	BSF        TRISIO5_bit+0, BitPos(TRISIO5_bit+0)
;SeaTurtle.c,205 :: 		ALL_OFF();
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,206 :: 		GPIO = 0xFF;        // Tutti i buffer di uscita accesi
	MOVLW      255
	MOVWF      GPIO+0
;SeaTurtle.c,209 :: 		syncPPM(STARTUP_PPM_FRAMES);
	MOVLW      100
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,212 :: 		if(PPM_value < PPM_1400_US || PPM_value > PPM_1600_US)
	MOVLW      175
	SUBWF      _PPM_value+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__main111
	MOVF       _PPM_value+0, 0
	SUBLW      200
	BTFSS      STATUS+0, 0
	GOTO       L__main111
	GOTO       L_main44
L__main111:
;SeaTurtle.c,213 :: 		userSetup();
	CALL       _userSetup+0
L_main44:
;SeaTurtle.c,215 :: 		Delay_ms(500);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      138
	MOVWF      R12+0
	MOVLW      85
	MOVWF      R13+0
L_main45:
	DECFSZ     R13+0, 1
	GOTO       L_main45
	DECFSZ     R12+0, 1
	GOTO       L_main45
	DECFSZ     R11+0, 1
	GOTO       L_main45
	NOP
	NOP
;SeaTurtle.c,218 :: 		if(EEPROM_Read(EEPROM_TESTED) == 0xFF)
	CLRF       FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L_main46
;SeaTurtle.c,219 :: 		hardwareTest();
	CALL       _hardwareTest+0
L_main46:
;SeaTurtle.c,222 :: 		PPM_neutral = EEPROM_Read(EEPROM_PPMNEUTRAL);
	MOVLW      1
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _PPM_neutral+0
;SeaTurtle.c,223 :: 		PPM_minzero = PPM_neutral - NEUTRAL_RANGE;
	MOVLW      2
	SUBWF      R0+0, 0
	MOVWF      _PPM_minzero+0
;SeaTurtle.c,224 :: 		PPM_maxzero = PPM_neutral + NEUTRAL_RANGE;
	MOVLW      2
	ADDWF      R0+0, 0
	MOVWF      _PPM_maxzero+0
;SeaTurtle.c,225 :: 		PPM_full = EEPROM_Read(EEPROM_PPMFULL);
	MOVLW      2
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,226 :: 		if(PPM_full < PPM_neutral)
	MOVF       _PPM_neutral+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main47
;SeaTurtle.c,228 :: 		PPM_reverse = 1;
	MOVLW      1
	MOVWF      _PPM_reverse+0
;SeaTurtle.c,229 :: 		EXH_threshold = PPM_neutral - ((PPM_neutral - PPM_full) / 2);
	MOVF       _PPM_full+0, 0
	SUBWF      _PPM_neutral+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	BTFSS      STATUS+0, 0
	DECF       R3+1, 1
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	BTFSC      R0+1, 6
	BSF        R0+1, 7
	MOVF       R0+0, 0
	SUBWF      _PPM_neutral+0, 0
	MOVWF      _EXH_threshold+0
;SeaTurtle.c,230 :: 		}
	GOTO       L_main48
L_main47:
;SeaTurtle.c,232 :: 		EXH_threshold = PPM_neutral + ((PPM_full - PPM_neutral) / 2);
	MOVF       _PPM_neutral+0, 0
	SUBWF      _PPM_full+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	BTFSS      STATUS+0, 0
	DECF       R3+1, 1
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	BTFSC      R0+1, 6
	BSF        R0+1, 7
	MOVF       R0+0, 0
	ADDWF      _PPM_neutral+0, 0
	MOVWF      _EXH_threshold+0
L_main48:
;SeaTurtle.c,235 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,238 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,241 :: 		HEAD = 0;  // Primo flash
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,242 :: 		Delay_ms(10);
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_main49:
	DECFSZ     R13+0, 1
	GOTO       L_main49
	DECFSZ     R12+0, 1
	GOTO       L_main49
	NOP
	NOP
;SeaTurtle.c,243 :: 		while(HEAD_pwm < PWM_FULL)
L_main50:
	MOVLW      16
	SUBWF      _HEAD_pwm+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main51
;SeaTurtle.c,245 :: 		Delay_us(PWM_DELAY_US);
	MOVLW      66
	MOVWF      R13+0
L_main52:
	DECFSZ     R13+0, 1
	GOTO       L_main52
	NOP
;SeaTurtle.c,247 :: 		if(++XENON_delay == XENON_HEAT)
	INCF       _XENON_delay+0, 1
	BTFSC      STATUS+0, 2
	INCF       _XENON_delay+1, 1
	MOVF       _XENON_delay+1, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L__main118
	MOVLW      88
	XORWF      _XENON_delay+0, 0
L__main118:
	BTFSS      STATUS+0, 2
	GOTO       L_main53
;SeaTurtle.c,249 :: 		XENON_delay = 0;
	CLRF       _XENON_delay+0
	CLRF       _XENON_delay+1
;SeaTurtle.c,250 :: 		HEAD_pwm++;
	INCF       _HEAD_pwm+0, 1
;SeaTurtle.c,251 :: 		}
L_main53:
;SeaTurtle.c,253 :: 		if(++PWM_i > PWM_CYCLE)
	INCF       _PWM_i+0, 1
	MOVF       _PWM_i+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_main54
;SeaTurtle.c,254 :: 		PWM_i = 0;
	CLRF       _PWM_i+0
L_main54:
;SeaTurtle.c,255 :: 		if(HEAD_pwm > PWM_i) HEAD = 0; else HEAD = 1;
	MOVF       _HEAD_pwm+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main55
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	GOTO       L_main56
L_main55:
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
L_main56:
;SeaTurtle.c,256 :: 		if(TAIL_pwm > PWM_i) TAIL = 0; else TAIL = 1;
	MOVF       _TAIL_pwm+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main57
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	GOTO       L_main58
L_main57:
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
L_main58:
;SeaTurtle.c,257 :: 		}
	GOTO       L_main50
L_main51:
;SeaTurtle.c,260 :: 		while(1)
L_main59:
;SeaTurtle.c,262 :: 		if(PPM_updated)
	MOVF       _PPM_updated+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main61
;SeaTurtle.c,265 :: 		if(PPM_value > PPM_maxzero)
	MOVF       _PPM_value+0, 0
	SUBWF      _PPM_maxzero+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main62
;SeaTurtle.c,267 :: 		if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
	MOVLW      133
	SUBWF      _PPM_antiglitch+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main63
;SeaTurtle.c,269 :: 		PPM_antiglitch++;
	INCF       _PPM_antiglitch+0, 1
;SeaTurtle.c,270 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,271 :: 		}
	GOTO       L_main64
L_main63:
;SeaTurtle.c,274 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main65
;SeaTurtle.c,275 :: 		PPM_command = CMD_BRAKE;
	MOVLW      2
	MOVWF      _PPM_command+0
	GOTO       L_main66
L_main65:
;SeaTurtle.c,277 :: 		PPM_command = CMD_FORWARD;
	MOVLW      1
	MOVWF      _PPM_command+0
L_main66:
;SeaTurtle.c,278 :: 		}
L_main64:
;SeaTurtle.c,279 :: 		}
	GOTO       L_main67
L_main62:
;SeaTurtle.c,280 :: 		else if(PPM_value < PPM_minzero)
	MOVF       _PPM_minzero+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main68
;SeaTurtle.c,282 :: 		if(PPM_antiglitch > ANTIGLITCH_ZERO - ANTIGLITCH_COUNT)
	MOVF       _PPM_antiglitch+0, 0
	SUBLW      123
	BTFSC      STATUS+0, 0
	GOTO       L_main69
;SeaTurtle.c,284 :: 		PPM_antiglitch--;
	DECF       _PPM_antiglitch+0, 1
;SeaTurtle.c,285 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,286 :: 		}
	GOTO       L_main70
L_main69:
;SeaTurtle.c,289 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main71
;SeaTurtle.c,290 :: 		PPM_command = CMD_FORWARD;
	MOVLW      1
	MOVWF      _PPM_command+0
	GOTO       L_main72
L_main71:
;SeaTurtle.c,292 :: 		PPM_command = CMD_BRAKE;
	MOVLW      2
	MOVWF      _PPM_command+0
L_main72:
;SeaTurtle.c,293 :: 		}
L_main70:
;SeaTurtle.c,294 :: 		}
	GOTO       L_main73
L_main68:
;SeaTurtle.c,297 :: 		PPM_antiglitch = ANTIGLITCH_ZERO;
	MOVLW      128
	MOVWF      _PPM_antiglitch+0
;SeaTurtle.c,298 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,299 :: 		}
L_main73:
L_main67:
;SeaTurtle.c,302 :: 		switch(PPM_command)
	GOTO       L_main74
;SeaTurtle.c,304 :: 		case CMD_FORWARD:
L_main76:
;SeaTurtle.c,306 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,308 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,309 :: 		REV_status = REV_OFF;
	CLRF       _REV_status+0
;SeaTurtle.c,311 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main77
;SeaTurtle.c,313 :: 		if(PPM_value < EXH_threshold && EXH_heat < EXH_MAX_TEMP)
	MOVF       _EXH_threshold+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main80
	MOVLW      100
	SUBWF      _EXH_heat+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main80
L__main110:
;SeaTurtle.c,314 :: 		EXH_heat++;
	INCF       _EXH_heat+0, 1
	GOTO       L_main81
L_main80:
;SeaTurtle.c,315 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main82
;SeaTurtle.c,316 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main82:
L_main81:
;SeaTurtle.c,317 :: 		}
	GOTO       L_main83
L_main77:
;SeaTurtle.c,320 :: 		if(PPM_value > EXH_threshold && EXH_heat < EXH_MAX_TEMP)
	MOVF       _PPM_value+0, 0
	SUBWF      _EXH_threshold+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main86
	MOVLW      100
	SUBWF      _EXH_heat+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main86
L__main109:
;SeaTurtle.c,321 :: 		EXH_heat++;
	INCF       _EXH_heat+0, 1
	GOTO       L_main87
L_main86:
;SeaTurtle.c,322 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main88
;SeaTurtle.c,323 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main88:
L_main87:
;SeaTurtle.c,324 :: 		}
L_main83:
;SeaTurtle.c,325 :: 		break;
	GOTO       L_main75
;SeaTurtle.c,327 :: 		case CMD_BRAKE:
L_main89:
;SeaTurtle.c,329 :: 		if(REV_status == REV_ACTIVE)
	MOVF       _REV_status+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main90
;SeaTurtle.c,330 :: 		REV = 0;
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	GOTO       L_main91
L_main90:
;SeaTurtle.c,334 :: 		TAIL_pwm = PWM_FULL;
	MOVLW      16
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,335 :: 		REV_status = REV_BRAKE;
	MOVLW      1
	MOVWF      _REV_status+0
;SeaTurtle.c,336 :: 		}
L_main91:
;SeaTurtle.c,338 :: 		if(EXH_heat >= EXH_IGNITION_TEMP)
	MOVLW      50
	SUBWF      _EXH_heat+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main92
;SeaTurtle.c,341 :: 		EXH_sequence = backfire[TMR0 & 0b00000011];
	MOVLW      3
	ANDWF      TMR0+0, 0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      _backfire+0
	ADDWF      R0+0, 1
	MOVLW      hi_addr(_backfire+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      _EXH_sequence+0
;SeaTurtle.c,342 :: 		EXH_bit = 7;
	MOVLW      7
	MOVWF      _EXH_bit+0
;SeaTurtle.c,343 :: 		EXH_heat = 0;
	CLRF       _EXH_heat+0
;SeaTurtle.c,344 :: 		}
	GOTO       L_main93
L_main92:
;SeaTurtle.c,345 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main94
;SeaTurtle.c,346 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main94:
L_main93:
;SeaTurtle.c,347 :: 		break;
	GOTO       L_main75
;SeaTurtle.c,349 :: 		default:
L_main95:
;SeaTurtle.c,351 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,353 :: 		if(REV_status == REV_BRAKE)
	MOVF       _REV_status+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main96
;SeaTurtle.c,354 :: 		REV_status = REV_ACTIVE;
	MOVLW      2
	MOVWF      _REV_status+0
L_main96:
;SeaTurtle.c,356 :: 		if(EXH_heat >= EXH_IGNITION_TEMP)
	MOVLW      50
	SUBWF      _EXH_heat+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main97
;SeaTurtle.c,359 :: 		EXH_sequence = backfire[TMR0 & 0b00000011];
	MOVLW      3
	ANDWF      TMR0+0, 0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      _backfire+0
	ADDWF      R0+0, 1
	MOVLW      hi_addr(_backfire+0)
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      ___DoICPAddr+0
	MOVF       R0+1, 0
	MOVWF      ___DoICPAddr+1
	CALL       _____DoICP+0
	MOVWF      _EXH_sequence+0
;SeaTurtle.c,360 :: 		EXH_bit = 7;
	MOVLW      7
	MOVWF      _EXH_bit+0
;SeaTurtle.c,361 :: 		EXH_heat = 0;
	CLRF       _EXH_heat+0
;SeaTurtle.c,362 :: 		}
	GOTO       L_main98
L_main97:
;SeaTurtle.c,363 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main99
;SeaTurtle.c,364 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main99:
L_main98:
;SeaTurtle.c,365 :: 		}
	GOTO       L_main75
L_main74:
	MOVF       _PPM_command+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main76
	MOVF       _PPM_command+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_main89
	GOTO       L_main95
L_main75:
;SeaTurtle.c,367 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,368 :: 		}
L_main61:
;SeaTurtle.c,371 :: 		if(--EXH_delay == 0)
	DECF       _EXH_delay+0, 1
	MOVF       _EXH_delay+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main100
;SeaTurtle.c,373 :: 		EXH_delay = EXH_DELAY_CYCLES;
	MOVLW      50
	MOVWF      _EXH_delay+0
;SeaTurtle.c,374 :: 		if(EXH_bit)
	MOVF       _EXH_bit+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main101
;SeaTurtle.c,376 :: 		EXH_bit--;
	DECF       _EXH_bit+0, 1
;SeaTurtle.c,377 :: 		EXH = !EXH_sequence.B0;
	BTFSC      _EXH_sequence+0, 0
	GOTO       L__main119
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	GOTO       L__main120
L__main119:
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
L__main120:
;SeaTurtle.c,378 :: 		EXH_sequence = EXH_sequence >> 1;
	RRF        _EXH_sequence+0, 1
	BCF        _EXH_sequence+0, 7
;SeaTurtle.c,379 :: 		}
L_main101:
;SeaTurtle.c,380 :: 		}
L_main100:
;SeaTurtle.c,382 :: 		if(++PWM_i > PWM_CYCLE)
	INCF       _PWM_i+0, 1
	MOVF       _PWM_i+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_main102
;SeaTurtle.c,383 :: 		PWM_i = 0;
	CLRF       _PWM_i+0
L_main102:
;SeaTurtle.c,384 :: 		if(TAIL_pwm > PWM_i) TAIL = 0; else TAIL = 1;
	MOVF       _TAIL_pwm+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main103
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	GOTO       L_main104
L_main103:
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
L_main104:
;SeaTurtle.c,386 :: 		Delay_us(PWM_DELAY_US);
	MOVLW      66
	MOVWF      R13+0
L_main105:
	DECFSZ     R13+0, 1
	GOTO       L_main105
	NOP
;SeaTurtle.c,387 :: 		}
	GOTO       L_main59
;SeaTurtle.c,388 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
