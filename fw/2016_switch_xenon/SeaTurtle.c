/* SEATURTLE
    2016 tHeo
    Firmware 1.0
    
Changelog:

28/03/16 > Porting dal firmware RCDriftLightUnit
    
*/

#include "SeaTurtle.h"

// CONFIGURAZIONE PIN
// Utilizzo i TRIS per passare da "acceso" a "floating" in modo da evitare danni in caso di cortocircuiti

sbit PPM at GP5_bit; // Segnale PPM in ingresso da ricevente
sbit TAIL1 at TRISIO4_bit;
sbit TAIL2 at TRISIO2_bit;
sbit HEAD1 at TRISIO1_bit;
sbit HEAD2 at TRISIO0_bit;

// VARIABILI

unsigned char PPM_level = 0;
unsigned char PPM_start = 0;
unsigned char PPM_value = PPM_1500_US;
unsigned char PPM_updated = 0;
unsigned char PPM_antiglitch = ANTIGLITCH_ZERO;
unsigned char PPM_command = CMD_OFF;

unsigned int XENON_delay = 0;
unsigned char XENON_pwm = PWM_OFF;

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
    // Attendo segnale PPM valido
    i = 0;
    while(i < frames)
    {
        PPM_updated = 0;
        while(!PPM_updated);
        if(PPM_value > PPM_MIN_VALID)
            i++;
        else
            i = 0;
    }
}

void main() {
    // INIZIALIZZAZIONE HARDWARE

    asm {
        bsf STATUS, RP0
        call 0x03ff
        movwf OSCCAL
        bcf STATUS, RP0
    }                           // Calibrazione oscillatore interno

    CMCON = 0b00010111;         // Comparatori OFF
    OPTION_REG = 0b00000010;    // TMR0 con prescaler 1/8 (ciclo 2,048 msec), pull-up abilitati

    GIE_bit = 1;                // Interrupt generale abilitato
    GPIE_bit = 1;               // Interrupt-On-Change abilitato
    IOC = 0b00100000;           // IOC abilitato su GP5 (PPM)
    WPU = 0b00100000;           // Weak pull-up abilitato solo su GP5 (PPM)

    TRISIO5_bit = 1;

    ALL_OFF();
    GPIO = 0xFF;        // Tutti i buffer di uscita accesi

    // Attendo segnale
    syncPPM(STARTUP_PPM_FRAMES);
        
    // Loop principale!
     while(1)
     {
         if(PPM_updated)
         {
             // Verifica la posizione del canale
             if(PPM_value > PPM_1500_US)
             {
                 if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
                 {
                     PPM_antiglitch++;
                     PPM_command = CMD_OFF;
                 }
                 else
                     PPM_command = CMD_ON;
             }
             else
             {
                 if(PPM_antiglitch > ANTIGLITCH_ZERO)
                 {
                     PPM_antiglitch--;
                     PPM_command = CMD_ON;
                 }
                 else
                     PPM_command = CMD_OFF;
             }

             // Gestisco le uscite in base alla posizione del canale
             switch(PPM_command)
             {
                 case CMD_ON:
                     // Accendo le luci
                     if(!LIGHTS_on)
                     {
                         LIGHTS_on = 1;
                         TAIL_ON();
                         
                         // Accendo fari xenon
                         HEAD_ON();  // Primo flash
                         Delay_ms(10);
                         while(XENON_pwm < PWM_FULL)
                         {
                             Delay_us(PWM_DELAY_US);
                             
                             if(++XENON_delay == XENON_HEAT)
                             {
                                 XENON_delay = 0;
                                 XENON_pwm++;
                             }
                             
                             if(++PWM_i > PWM_CYCLE)
                                 PWM_i = 0;

                             if(XENON_pwm > PWM_i)
                             {
                                 HEAD_ON();
                             }
                             else
                             {
                                 HEAD_OFF();
                             }
                         }
                     }
                     break;

                 default:
                     // Spengo le luci
                     LIGHTS_on = 0;
                     ALL_OFF();
                     XENON_pwm = PWM_OFF;
             }

              PPM_updated = 0;
         }
     }
}