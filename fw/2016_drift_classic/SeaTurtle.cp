#line 1 "C:/Documents and Settings/tHeo/Documenti/Dropbox/RC - Centraline/SeaTurtle/fw/2016_classic/SeaTurtle.c"
#line 1 "c:/documents and settings/theo/documenti/dropbox/rc - centraline/seaturtle/fw/2016_classic/seaturtle.h"
#line 1 "c:/programmi/mikroelektronika/mikroc pro for pic/include/built_in.h"
#line 59 "c:/documents and settings/theo/documenti/dropbox/rc - centraline/seaturtle/fw/2016_classic/seaturtle.h"
const unsigned char backfire[] = {0b10000001, 0b00101000, 0b00000001, 0b10010001};
#line 16 "C:/Documents and Settings/tHeo/Documenti/Dropbox/RC - Centraline/SeaTurtle/fw/2016_classic/SeaTurtle.c"
sbit PPM at GP5_bit;
sbit EXH at TRISIO4_bit;
sbit REV at TRISIO2_bit;
sbit TAIL at TRISIO1_bit;
sbit HEAD at TRISIO0_bit;



unsigned char PPM_level = 0;
unsigned char PPM_start = 0;
unsigned char PPM_value =  188 ;
unsigned char PPM_updated = 0;

unsigned char PPM_neutral = 0;
unsigned char PPM_full =  188 ;
unsigned char PPM_antiglitch = 0;
unsigned char PPM_reverse = 0;
unsigned char PPM_maxzero;
unsigned char PPM_minzero;
unsigned char PPM_command =  0 ;

unsigned char new_user_cmd = 0;

unsigned char REV_status = 0;

unsigned char EXH_threshold;
unsigned char EXH_heat = 0;
unsigned char EXH_sequence = 0;
unsigned char EXH_delay = 0;
unsigned char EXH_bit = 0;

unsigned char PWM_i = 0;
unsigned char TAIL_pwm =  0 ;

unsigned char i;

void interrupt()
{
 if(GPIF_bit)
 {
 if(PPM && !PPM_level)
 {
 PPM_start = TMR0;
 PPM_level = 1;
 }
 else if(!PPM && PPM_level)
 {
 PPM_value = TMR0 - PPM_start;
 PPM_level = 0;
 PPM_updated = 1;
 }

 GPIF_bit = 0;
 }
}

void syncPPM(unsigned char frames)
{

 i = 0;
 while(i < frames)
 {
 PPM_updated = 0;
 while(!PPM_updated);
 if(PPM_value >  112 )
 i++;
 else
 i = 0;
 }
}

void hardwareTest()
{
 while(1)
 {
 PPM_updated = 0;
 while(!PPM_updated);

 if(PPM_value <  156 )
 {
 HEAD = 0;
 TAIL = 1;
 REV = 1;
 EXH = 1;
 }
 else if(PPM_value <  188 )
 {
 HEAD = 1;
 TAIL = 0;
 REV = 1;
 EXH = 1;
 }
 else if(PPM_value <  219 )
 {
 HEAD = 1;
 TAIL = 1;
 REV = 0;
 EXH = 1;
 }
 else
 {
 HEAD = 1;
 TAIL = 1;
 REV = 1;
 EXH = 0;
 }
 }
}

void userSetup()
{

  HEAD = 0; TAIL = 0; REV = 0; EXH = 0; ;


 i = 0;
 if(PPM_value >  188 )
 {
 PPM_reverse = 0;
 while(i <  150 )
 {
 PPM_updated = 0;
 while(!PPM_updated);

 if(PPM_value > PPM_full)
 {
 PPM_full = PPM_value;
 i = 0;
 }
 else
 i++;
 }
 }
 else
 {
 PPM_reverse = 1;
 while(i <  150 )
 {
 PPM_updated = 0;
 while(!PPM_updated);

 if(PPM_value < PPM_full)
 {
 PPM_full = PPM_value;
 i = 0;
 }
 else
 i++;
 }
 }


 EEPROM_Write( 2 , PPM_full);

  HEAD = 1; TAIL = 1; REV = 1; EXH = 1; ;


 while(PPM_value >  200  || PPM_value <  175 );


 syncPPM( 150 );
 PPM_neutral = PPM_value;
 EEPROM_Write( 1 , PPM_neutral);
 EEPROM_Write( 0 , 0);
}

void main() {


 asm {
 bsf STATUS, RP0
 call 0x03ff
 movwf OSCCAL
 bcf STATUS, RP0
 }

 CMCON = 0b00010111;
 OPTION_REG = 0b00000010;

 GIE_bit = 1;
 GPIE_bit = 1;
 IOC = 0b00100000;
 WPU = 0b00100000;

 TRISIO5_bit = 1;

  HEAD = 1; TAIL = 1; REV = 1; EXH = 1; ;
 GPIO = 0xFF;


 syncPPM( 100 );


 if(PPM_value <  175  || PPM_value >  200 )
 userSetup();

 Delay_ms(500);


 if(EEPROM_Read( 0 ) == 0xFF)
 hardwareTest();


 PPM_neutral = EEPROM_Read( 1 );
 PPM_minzero = PPM_neutral -  2 ;
 PPM_maxzero = PPM_neutral +  2 ;
 PPM_full = EEPROM_Read( 2 );
 if(PPM_full < PPM_neutral)
 {
 PPM_reverse = 1;
 EXH_threshold = PPM_neutral - ((PPM_neutral - PPM_full) / 2);
 }
 else
 EXH_threshold = PPM_neutral + ((PPM_full - PPM_neutral) / 2);


 PPM_command =  0 ;


 TAIL_pwm =  4 ;
 HEAD = 0;


 while(1)
 {
 if(PPM_updated)
 {

 if(PPM_value > PPM_maxzero)
 {
 if(PPM_antiglitch <  128  +  5 )
 {
 PPM_antiglitch++;
 PPM_command =  0 ;
 }
 else
 {
 if(PPM_reverse)
 PPM_command =  2 ;
 else
 PPM_command =  1 ;
 }
 }
 else if(PPM_value < PPM_minzero)
 {
 if(PPM_antiglitch >  128  -  5 )
 {
 PPM_antiglitch--;
 PPM_command =  0 ;
 }
 else
 {
 if(PPM_reverse)
 PPM_command =  1 ;
 else
 PPM_command =  2 ;
 }
 }
 else
 {
 PPM_antiglitch =  128 ;
 PPM_command =  0 ;
 }


 switch(PPM_command)
 {
 case  1 :

 TAIL_pwm =  4 ;

 REV = 1;
 REV_status =  0 ;

 if(PPM_reverse)
 {
 if(PPM_value < EXH_threshold && EXH_heat <  100 )
 EXH_heat++;
 else if(EXH_heat)
 EXH_heat--;
 }
 else
 {
 if(PPM_value > EXH_threshold && EXH_heat <  100 )
 EXH_heat++;
 else if(EXH_heat)
 EXH_heat--;
 }
 break;

 case  2 :

 if(REV_status ==  2 )
 REV = 0;

 else
 {
 TAIL_pwm =  16 ;
 REV_status =  1 ;
 }

 if(EXH_heat >=  50 )
 {

 EXH_sequence = backfire[TMR0 & 0b00000011];
 EXH_bit = 7;
 EXH_heat = 0;
 }
 else if(EXH_heat)
 EXH_heat--;
 break;

 default:

 TAIL_pwm =  4 ;

 if(REV_status ==  1 )
 REV_status =  2 ;

 if(EXH_heat >=  50 )
 {

 EXH_sequence = backfire[TMR0 & 0b00000011];
 EXH_bit = 7;
 EXH_heat = 0;
 }
 else if(EXH_heat)
 EXH_heat--;
 }

 PPM_updated = 0;
 }


 if(--EXH_delay == 0)
 {
 EXH_delay =  50 ;
 if(EXH_bit)
 {
 EXH_bit--;
 EXH = !EXH_sequence.B0;
 EXH_sequence = EXH_sequence >> 1;
 }
 }

 if(++PWM_i >  16 )
 PWM_i = 0;
 if(TAIL_pwm > PWM_i) TAIL = 0; else TAIL = 1;

 Delay_us( 200 );
 }
}
