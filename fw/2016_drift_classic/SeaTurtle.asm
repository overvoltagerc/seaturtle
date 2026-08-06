
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;SeaTurtle.c,52 :: 		void interrupt()
;SeaTurtle.c,54 :: 		if(GPIF_bit)
	BTFSS      GPIF_bit+0, BitPos(GPIF_bit+0)
	GOTO       L_interrupt0
;SeaTurtle.c,56 :: 		if(PPM && !PPM_level)
	BTFSS      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt3
	MOVF       _PPM_level+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
L__interrupt97:
;SeaTurtle.c,58 :: 		PPM_start = TMR0;
	MOVF       TMR0+0, 0
	MOVWF      _PPM_start+0
;SeaTurtle.c,59 :: 		PPM_level = 1;
	MOVLW      1
	MOVWF      _PPM_level+0
;SeaTurtle.c,60 :: 		}
	GOTO       L_interrupt4
L_interrupt3:
;SeaTurtle.c,61 :: 		else if(!PPM && PPM_level)
	BTFSC      GP5_bit+0, BitPos(GP5_bit+0)
	GOTO       L_interrupt7
	MOVF       _PPM_level+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt7
L__interrupt96:
;SeaTurtle.c,63 :: 		PPM_value = TMR0 - PPM_start;
	MOVF       _PPM_start+0, 0
	SUBWF      TMR0+0, 0
	MOVWF      _PPM_value+0
;SeaTurtle.c,64 :: 		PPM_level = 0;
	CLRF       _PPM_level+0
;SeaTurtle.c,65 :: 		PPM_updated = 1;
	MOVLW      1
	MOVWF      _PPM_updated+0
;SeaTurtle.c,66 :: 		}
L_interrupt7:
L_interrupt4:
;SeaTurtle.c,68 :: 		GPIF_bit = 0;
	BCF        GPIF_bit+0, BitPos(GPIF_bit+0)
;SeaTurtle.c,69 :: 		}
L_interrupt0:
;SeaTurtle.c,70 :: 		}
L_end_interrupt:
L__interrupt103:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_syncPPM:

;SeaTurtle.c,72 :: 		void syncPPM(unsigned char frames)
;SeaTurtle.c,75 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,76 :: 		while(i < frames)
L_syncPPM8:
	MOVF       FARG_syncPPM_frames+0, 0
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM9
;SeaTurtle.c,78 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,79 :: 		while(!PPM_updated);
L_syncPPM10:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_syncPPM11
	GOTO       L_syncPPM10
L_syncPPM11:
;SeaTurtle.c,80 :: 		if(PPM_value > PPM_MIN_VALID)
	MOVF       _PPM_value+0, 0
	SUBLW      112
	BTFSC      STATUS+0, 0
	GOTO       L_syncPPM12
;SeaTurtle.c,81 :: 		i++;
	INCF       _i+0, 1
	GOTO       L_syncPPM13
L_syncPPM12:
;SeaTurtle.c,83 :: 		i = 0;
	CLRF       _i+0
L_syncPPM13:
;SeaTurtle.c,84 :: 		}
	GOTO       L_syncPPM8
L_syncPPM9:
;SeaTurtle.c,85 :: 		}
L_end_syncPPM:
	RETURN
; end of _syncPPM

_hardwareTest:

;SeaTurtle.c,87 :: 		void hardwareTest()
;SeaTurtle.c,89 :: 		while(1)
L_hardwareTest14:
;SeaTurtle.c,91 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,92 :: 		while(!PPM_updated);
L_hardwareTest16:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_hardwareTest17
	GOTO       L_hardwareTest16
L_hardwareTest17:
;SeaTurtle.c,94 :: 		if(PPM_value < PPM_1250_US)
	MOVLW      156
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest18
;SeaTurtle.c,96 :: 		HEAD = 0;
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,97 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,98 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,99 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,100 :: 		}
	GOTO       L_hardwareTest19
L_hardwareTest18:
;SeaTurtle.c,101 :: 		else if(PPM_value < PPM_1500_US)
	MOVLW      188
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest20
;SeaTurtle.c,103 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,104 :: 		TAIL = 0;
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,105 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,106 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,107 :: 		}
	GOTO       L_hardwareTest21
L_hardwareTest20:
;SeaTurtle.c,108 :: 		else if(PPM_value < PPM_1750_US)
	MOVLW      219
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_hardwareTest22
;SeaTurtle.c,110 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,111 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,112 :: 		REV = 0;
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,113 :: 		EXH = 1;
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,114 :: 		}
	GOTO       L_hardwareTest23
L_hardwareTest22:
;SeaTurtle.c,117 :: 		HEAD = 1;
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,118 :: 		TAIL = 1;
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
;SeaTurtle.c,119 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,120 :: 		EXH = 0;
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,121 :: 		}
L_hardwareTest23:
L_hardwareTest21:
L_hardwareTest19:
;SeaTurtle.c,122 :: 		}
	GOTO       L_hardwareTest14
;SeaTurtle.c,123 :: 		}
L_end_hardwareTest:
	RETURN
; end of _hardwareTest

_userSetup:

;SeaTurtle.c,125 :: 		void userSetup()
;SeaTurtle.c,128 :: 		ALL_ON();
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,131 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,132 :: 		if(PPM_value > PPM_1500_US)
	MOVF       _PPM_value+0, 0
	SUBLW      188
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup24
;SeaTurtle.c,134 :: 		PPM_reverse = 0;
	CLRF       _PPM_reverse+0
;SeaTurtle.c,135 :: 		while(i < PROGRAM_PPM_FRAMES)
L_userSetup25:
	MOVLW      150
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup26
;SeaTurtle.c,137 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,138 :: 		while(!PPM_updated);
L_userSetup27:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_userSetup28
	GOTO       L_userSetup27
L_userSetup28:
;SeaTurtle.c,140 :: 		if(PPM_value > PPM_full)
	MOVF       _PPM_value+0, 0
	SUBWF      _PPM_full+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup29
;SeaTurtle.c,142 :: 		PPM_full = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,143 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,144 :: 		}
	GOTO       L_userSetup30
L_userSetup29:
;SeaTurtle.c,146 :: 		i++;
	INCF       _i+0, 1
L_userSetup30:
;SeaTurtle.c,147 :: 		}
	GOTO       L_userSetup25
L_userSetup26:
;SeaTurtle.c,148 :: 		}
	GOTO       L_userSetup31
L_userSetup24:
;SeaTurtle.c,151 :: 		PPM_reverse = 1;
	MOVLW      1
	MOVWF      _PPM_reverse+0
;SeaTurtle.c,152 :: 		while(i < PROGRAM_PPM_FRAMES)
L_userSetup32:
	MOVLW      150
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup33
;SeaTurtle.c,154 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,155 :: 		while(!PPM_updated);
L_userSetup34:
	MOVF       _PPM_updated+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_userSetup35
	GOTO       L_userSetup34
L_userSetup35:
;SeaTurtle.c,157 :: 		if(PPM_value < PPM_full)
	MOVF       _PPM_full+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_userSetup36
;SeaTurtle.c,159 :: 		PPM_full = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,160 :: 		i = 0;
	CLRF       _i+0
;SeaTurtle.c,161 :: 		}
	GOTO       L_userSetup37
L_userSetup36:
;SeaTurtle.c,163 :: 		i++;
	INCF       _i+0, 1
L_userSetup37:
;SeaTurtle.c,164 :: 		}
	GOTO       L_userSetup32
L_userSetup33:
;SeaTurtle.c,165 :: 		}
L_userSetup31:
;SeaTurtle.c,168 :: 		EEPROM_Write(EEPROM_PPMFULL, PPM_full);
	MOVLW      2
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       _PPM_full+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,170 :: 		ALL_OFF();
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,173 :: 		while(PPM_value > PPM_1600_US || PPM_value < PPM_1400_US);
L_userSetup38:
	MOVF       _PPM_value+0, 0
	SUBLW      200
	BTFSS      STATUS+0, 0
	GOTO       L__userSetup98
	MOVLW      175
	SUBWF      _PPM_value+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__userSetup98
	GOTO       L_userSetup39
L__userSetup98:
	GOTO       L_userSetup38
L_userSetup39:
;SeaTurtle.c,176 :: 		syncPPM(PROGRAM_PPM_FRAMES);
	MOVLW      150
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,177 :: 		PPM_neutral = PPM_value;
	MOVF       _PPM_value+0, 0
	MOVWF      _PPM_neutral+0
;SeaTurtle.c,178 :: 		EEPROM_Write(EEPROM_PPMNEUTRAL, PPM_neutral);
	MOVLW      1
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       _PPM_value+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,179 :: 		EEPROM_Write(EEPROM_TESTED, 0);
	CLRF       FARG_EEPROM_Write_Address+0
	CLRF       FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;SeaTurtle.c,180 :: 		}
L_end_userSetup:
	RETURN
; end of _userSetup

_main:

;SeaTurtle.c,182 :: 		void main() {
;SeaTurtle.c,186 :: 		bsf STATUS, RP0
	BSF        STATUS+0, 5
;SeaTurtle.c,187 :: 		call 0x03ff
	CALL       1023
;SeaTurtle.c,188 :: 		movwf OSCCAL
	MOVWF      OSCCAL+0
;SeaTurtle.c,189 :: 		bcf STATUS, RP0
	BCF        STATUS+0, 5
;SeaTurtle.c,192 :: 		CMCON = 0b00010111;         // Comparatori OFF
	MOVLW      23
	MOVWF      CMCON+0
;SeaTurtle.c,193 :: 		OPTION_REG = 0b00000010;    // TMR0 con prescaler 1/8 (ciclo 2,048 msec), pull-up abilitati
	MOVLW      2
	MOVWF      OPTION_REG+0
;SeaTurtle.c,195 :: 		GIE_bit = 1;                // Interrupt generale abilitato
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;SeaTurtle.c,196 :: 		GPIE_bit = 1;               // Interrupt-On-Change abilitato
	BSF        GPIE_bit+0, BitPos(GPIE_bit+0)
;SeaTurtle.c,197 :: 		IOC = 0b00100000;           // IOC abilitato su GP5 (PPM)
	MOVLW      32
	MOVWF      IOC+0
;SeaTurtle.c,198 :: 		WPU = 0b00100000;           // Weak pull-up abilitato solo su GP5 (PPM)
	MOVLW      32
	MOVWF      WPU+0
;SeaTurtle.c,200 :: 		TRISIO5_bit = 1;
	BSF        TRISIO5_bit+0, BitPos(TRISIO5_bit+0)
;SeaTurtle.c,202 :: 		ALL_OFF();
	BSF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
;SeaTurtle.c,203 :: 		GPIO = 0xFF;        // Tutti i buffer di uscita accesi
	MOVLW      255
	MOVWF      GPIO+0
;SeaTurtle.c,206 :: 		syncPPM(STARTUP_PPM_FRAMES);
	MOVLW      100
	MOVWF      FARG_syncPPM_frames+0
	CALL       _syncPPM+0
;SeaTurtle.c,209 :: 		if(PPM_value < PPM_1400_US || PPM_value > PPM_1600_US)
	MOVLW      175
	SUBWF      _PPM_value+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L__main101
	MOVF       _PPM_value+0, 0
	SUBLW      200
	BTFSS      STATUS+0, 0
	GOTO       L__main101
	GOTO       L_main44
L__main101:
;SeaTurtle.c,210 :: 		userSetup();
	CALL       _userSetup+0
L_main44:
;SeaTurtle.c,212 :: 		Delay_ms(500);
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
;SeaTurtle.c,215 :: 		if(EEPROM_Read(EEPROM_TESTED) == 0xFF)
	CLRF       FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L_main46
;SeaTurtle.c,216 :: 		hardwareTest();
	CALL       _hardwareTest+0
L_main46:
;SeaTurtle.c,219 :: 		PPM_neutral = EEPROM_Read(EEPROM_PPMNEUTRAL);
	MOVLW      1
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _PPM_neutral+0
;SeaTurtle.c,220 :: 		PPM_minzero = PPM_neutral - NEUTRAL_RANGE;
	MOVLW      2
	SUBWF      R0+0, 0
	MOVWF      _PPM_minzero+0
;SeaTurtle.c,221 :: 		PPM_maxzero = PPM_neutral + NEUTRAL_RANGE;
	MOVLW      2
	ADDWF      R0+0, 0
	MOVWF      _PPM_maxzero+0
;SeaTurtle.c,222 :: 		PPM_full = EEPROM_Read(EEPROM_PPMFULL);
	MOVLW      2
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _PPM_full+0
;SeaTurtle.c,223 :: 		if(PPM_full < PPM_neutral)
	MOVF       _PPM_neutral+0, 0
	SUBWF      R0+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main47
;SeaTurtle.c,225 :: 		PPM_reverse = 1;
	MOVLW      1
	MOVWF      _PPM_reverse+0
;SeaTurtle.c,226 :: 		EXH_threshold = PPM_neutral - ((PPM_neutral - PPM_full) / 2);
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
;SeaTurtle.c,227 :: 		}
	GOTO       L_main48
L_main47:
;SeaTurtle.c,229 :: 		EXH_threshold = PPM_neutral + ((PPM_full - PPM_neutral) / 2);
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
;SeaTurtle.c,232 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,235 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,236 :: 		HEAD = 0;
	BCF        TRISIO0_bit+0, BitPos(TRISIO0_bit+0)
;SeaTurtle.c,239 :: 		while(1)
L_main49:
;SeaTurtle.c,241 :: 		if(PPM_updated)
	MOVF       _PPM_updated+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main51
;SeaTurtle.c,244 :: 		if(PPM_value > PPM_maxzero)
	MOVF       _PPM_value+0, 0
	SUBWF      _PPM_maxzero+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main52
;SeaTurtle.c,246 :: 		if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
	MOVLW      133
	SUBWF      _PPM_antiglitch+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main53
;SeaTurtle.c,248 :: 		PPM_antiglitch++;
	INCF       _PPM_antiglitch+0, 1
;SeaTurtle.c,249 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,250 :: 		}
	GOTO       L_main54
L_main53:
;SeaTurtle.c,253 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main55
;SeaTurtle.c,254 :: 		PPM_command = CMD_BRAKE;
	MOVLW      2
	MOVWF      _PPM_command+0
	GOTO       L_main56
L_main55:
;SeaTurtle.c,256 :: 		PPM_command = CMD_FORWARD;
	MOVLW      1
	MOVWF      _PPM_command+0
L_main56:
;SeaTurtle.c,257 :: 		}
L_main54:
;SeaTurtle.c,258 :: 		}
	GOTO       L_main57
L_main52:
;SeaTurtle.c,259 :: 		else if(PPM_value < PPM_minzero)
	MOVF       _PPM_minzero+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main58
;SeaTurtle.c,261 :: 		if(PPM_antiglitch > ANTIGLITCH_ZERO - ANTIGLITCH_COUNT)
	MOVF       _PPM_antiglitch+0, 0
	SUBLW      123
	BTFSC      STATUS+0, 0
	GOTO       L_main59
;SeaTurtle.c,263 :: 		PPM_antiglitch--;
	DECF       _PPM_antiglitch+0, 1
;SeaTurtle.c,264 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,265 :: 		}
	GOTO       L_main60
L_main59:
;SeaTurtle.c,268 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main61
;SeaTurtle.c,269 :: 		PPM_command = CMD_FORWARD;
	MOVLW      1
	MOVWF      _PPM_command+0
	GOTO       L_main62
L_main61:
;SeaTurtle.c,271 :: 		PPM_command = CMD_BRAKE;
	MOVLW      2
	MOVWF      _PPM_command+0
L_main62:
;SeaTurtle.c,272 :: 		}
L_main60:
;SeaTurtle.c,273 :: 		}
	GOTO       L_main63
L_main58:
;SeaTurtle.c,276 :: 		PPM_antiglitch = ANTIGLITCH_ZERO;
	MOVLW      128
	MOVWF      _PPM_antiglitch+0
;SeaTurtle.c,277 :: 		PPM_command = CMD_IDLE;
	CLRF       _PPM_command+0
;SeaTurtle.c,278 :: 		}
L_main63:
L_main57:
;SeaTurtle.c,281 :: 		switch(PPM_command)
	GOTO       L_main64
;SeaTurtle.c,283 :: 		case CMD_FORWARD:
L_main66:
;SeaTurtle.c,285 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,287 :: 		REV = 1;
	BSF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
;SeaTurtle.c,288 :: 		REV_status = REV_OFF;
	CLRF       _REV_status+0
;SeaTurtle.c,290 :: 		if(PPM_reverse)
	MOVF       _PPM_reverse+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main67
;SeaTurtle.c,292 :: 		if(PPM_value < EXH_threshold && EXH_heat < EXH_MAX_TEMP)
	MOVF       _EXH_threshold+0, 0
	SUBWF      _PPM_value+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main70
	MOVLW      100
	SUBWF      _EXH_heat+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main70
L__main100:
;SeaTurtle.c,293 :: 		EXH_heat++;
	INCF       _EXH_heat+0, 1
	GOTO       L_main71
L_main70:
;SeaTurtle.c,294 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main72
;SeaTurtle.c,295 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main72:
L_main71:
;SeaTurtle.c,296 :: 		}
	GOTO       L_main73
L_main67:
;SeaTurtle.c,299 :: 		if(PPM_value > EXH_threshold && EXH_heat < EXH_MAX_TEMP)
	MOVF       _PPM_value+0, 0
	SUBWF      _EXH_threshold+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main76
	MOVLW      100
	SUBWF      _EXH_heat+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main76
L__main99:
;SeaTurtle.c,300 :: 		EXH_heat++;
	INCF       _EXH_heat+0, 1
	GOTO       L_main77
L_main76:
;SeaTurtle.c,301 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main78
;SeaTurtle.c,302 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main78:
L_main77:
;SeaTurtle.c,303 :: 		}
L_main73:
;SeaTurtle.c,304 :: 		break;
	GOTO       L_main65
;SeaTurtle.c,306 :: 		case CMD_BRAKE:
L_main79:
;SeaTurtle.c,308 :: 		if(REV_status == REV_ACTIVE)
	MOVF       _REV_status+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main80
;SeaTurtle.c,309 :: 		REV = 0;
	BCF        TRISIO2_bit+0, BitPos(TRISIO2_bit+0)
	GOTO       L_main81
L_main80:
;SeaTurtle.c,313 :: 		TAIL_pwm = PWM_FULL;
	MOVLW      16
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,314 :: 		REV_status = REV_BRAKE;
	MOVLW      1
	MOVWF      _REV_status+0
;SeaTurtle.c,315 :: 		}
L_main81:
;SeaTurtle.c,317 :: 		if(EXH_heat >= EXH_IGNITION_TEMP)
	MOVLW      50
	SUBWF      _EXH_heat+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main82
;SeaTurtle.c,320 :: 		EXH_sequence = backfire[TMR0 & 0b00000011];
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
;SeaTurtle.c,321 :: 		EXH_bit = 7;
	MOVLW      7
	MOVWF      _EXH_bit+0
;SeaTurtle.c,322 :: 		EXH_heat = 0;
	CLRF       _EXH_heat+0
;SeaTurtle.c,323 :: 		}
	GOTO       L_main83
L_main82:
;SeaTurtle.c,324 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main84
;SeaTurtle.c,325 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main84:
L_main83:
;SeaTurtle.c,326 :: 		break;
	GOTO       L_main65
;SeaTurtle.c,328 :: 		default:
L_main85:
;SeaTurtle.c,330 :: 		TAIL_pwm = PWM_DIM;
	MOVLW      4
	MOVWF      _TAIL_pwm+0
;SeaTurtle.c,332 :: 		if(REV_status == REV_BRAKE)
	MOVF       _REV_status+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main86
;SeaTurtle.c,333 :: 		REV_status = REV_ACTIVE;
	MOVLW      2
	MOVWF      _REV_status+0
L_main86:
;SeaTurtle.c,335 :: 		if(EXH_heat >= EXH_IGNITION_TEMP)
	MOVLW      50
	SUBWF      _EXH_heat+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main87
;SeaTurtle.c,338 :: 		EXH_sequence = backfire[TMR0 & 0b00000011];
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
;SeaTurtle.c,339 :: 		EXH_bit = 7;
	MOVLW      7
	MOVWF      _EXH_bit+0
;SeaTurtle.c,340 :: 		EXH_heat = 0;
	CLRF       _EXH_heat+0
;SeaTurtle.c,341 :: 		}
	GOTO       L_main88
L_main87:
;SeaTurtle.c,342 :: 		else if(EXH_heat)
	MOVF       _EXH_heat+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main89
;SeaTurtle.c,343 :: 		EXH_heat--;
	DECF       _EXH_heat+0, 1
L_main89:
L_main88:
;SeaTurtle.c,344 :: 		}
	GOTO       L_main65
L_main64:
	MOVF       _PPM_command+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main66
	MOVF       _PPM_command+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_main79
	GOTO       L_main85
L_main65:
;SeaTurtle.c,346 :: 		PPM_updated = 0;
	CLRF       _PPM_updated+0
;SeaTurtle.c,347 :: 		}
L_main51:
;SeaTurtle.c,350 :: 		if(--EXH_delay == 0)
	DECF       _EXH_delay+0, 1
	MOVF       _EXH_delay+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main90
;SeaTurtle.c,352 :: 		EXH_delay = EXH_DELAY_CYCLES;
	MOVLW      50
	MOVWF      _EXH_delay+0
;SeaTurtle.c,353 :: 		if(EXH_bit)
	MOVF       _EXH_bit+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main91
;SeaTurtle.c,355 :: 		EXH_bit--;
	DECF       _EXH_bit+0, 1
;SeaTurtle.c,356 :: 		EXH = !EXH_sequence.B0;
	BTFSC      _EXH_sequence+0, 0
	GOTO       L__main108
	BSF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
	GOTO       L__main109
L__main108:
	BCF        TRISIO4_bit+0, BitPos(TRISIO4_bit+0)
L__main109:
;SeaTurtle.c,357 :: 		EXH_sequence = EXH_sequence >> 1;
	RRF        _EXH_sequence+0, 1
	BCF        _EXH_sequence+0, 7
;SeaTurtle.c,358 :: 		}
L_main91:
;SeaTurtle.c,359 :: 		}
L_main90:
;SeaTurtle.c,361 :: 		if(++PWM_i > PWM_CYCLE)
	INCF       _PWM_i+0, 1
	MOVF       _PWM_i+0, 0
	SUBLW      16
	BTFSC      STATUS+0, 0
	GOTO       L_main92
;SeaTurtle.c,362 :: 		PWM_i = 0;
	CLRF       _PWM_i+0
L_main92:
;SeaTurtle.c,363 :: 		if(TAIL_pwm > PWM_i) TAIL = 0; else TAIL = 1;
	MOVF       _TAIL_pwm+0, 0
	SUBWF      _PWM_i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main93
	BCF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
	GOTO       L_main94
L_main93:
	BSF        TRISIO1_bit+0, BitPos(TRISIO1_bit+0)
L_main94:
;SeaTurtle.c,365 :: 		Delay_us(PWM_DELAY_US);
	MOVLW      66
	MOVWF      R13+0
L_main95:
	DECFSZ     R13+0, 1
	GOTO       L_main95
	NOP
;SeaTurtle.c,366 :: 		}
	GOTO       L_main49
;SeaTurtle.c,367 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
