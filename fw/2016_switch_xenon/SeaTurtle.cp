#line 1 "C:/Documents and Settings/tHeo/Documenti/Dropbox/RC - Centraline/SeaTurtle/fw/2016_switch_xenon/SeaTurtle.c"
#line 1 "c:/documents and settings/theo/documenti/dropbox/rc - centraline/seaturtle/fw/2016_switch_xenon/seaturtle.h"
#line 1 "c:/programmi/mikroelektronika/mikroc pro for pic/include/built_in.h"
#line 16 "C:/Documents and Settings/tHeo/Documenti/Dropbox/RC - Centraline/SeaTurtle/fw/2016_switch_xenon/SeaTurtle.c"
sbit PPM at GP5_bit;
sbit TAIL1 at TRISIO4_bit;
sbit TAIL2 at TRISIO2_bit;
sbit HEAD1 at TRISIO1_bit;
sbit HEAD2 at TRISIO0_bit;



unsigned char PPM_level = 0;
unsigned char PPM_start = 0;
unsigned char PPM_value =  188 ;
unsigned char PPM_updated = 0;
unsigned char PPM_antiglitch =  128 ;
unsigned char PPM_command =  0 ;

unsigned int XENON_delay = 0;
unsigned char XENON_pwm =  0 ;

unsigned char LIGHTS_on = 0;

unsigned char PWM_i = 0;

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

  HEAD1 = 1; HEAD2 = 1; TAIL1 = 1; TAIL2 = 1; ;
 GPIO = 0xFF;


 syncPPM( 100 );


 while(1)
 {
 if(PPM_updated)
 {

 if(PPM_value >  188 )
 {
 if(PPM_antiglitch <  128  +  5 )
 {
 PPM_antiglitch++;
 PPM_command =  0 ;
 }
 else
 PPM_command =  1 ;
 }
 else
 {
 if(PPM_antiglitch >  128 )
 {
 PPM_antiglitch--;
 PPM_command =  1 ;
 }
 else
 PPM_command =  0 ;
 }


 switch(PPM_command)
 {
 case  1 :

 if(!LIGHTS_on)
 {
 LIGHTS_on = 1;
  TAIL1 = 0; TAIL2 = 0; ;


  HEAD1 = 0; HEAD2 = 0; ;
 Delay_ms(10);
 while(XENON_pwm <  16 )
 {
 Delay_us( 200 );

 if(++XENON_delay ==  600 )
 {
 XENON_delay = 0;
 XENON_pwm++;
 }

 if(++PWM_i >  16 )
 PWM_i = 0;

 if(XENON_pwm > PWM_i)
 {
  HEAD1 = 0; HEAD2 = 0; ;
 }
 else
 {
  HEAD1 = 1; HEAD2 = 1; ;
 }
 }
 }
 break;

 default:

 LIGHTS_on = 0;
  HEAD1 = 1; HEAD2 = 1; TAIL1 = 1; TAIL2 = 1; ;
 XENON_pwm =  0 ;
 }

 PPM_updated = 0;
 }
 }
}
