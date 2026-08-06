/* SEATURTLE
    2016 tHeo
    Firmware 1.0
    
Changelog:

27/03/16 > Porting dal firmware RCDriftLightUnit
    
*/

#include "SeaTurtle.h"

// CONFIGURAZIONE PIN
// Utilizzo i TRIS per passare da "acceso" a "floating" in modo da evitare danni in caso di cortocircuiti

sbit PPM at GP5_bit; // Segnale PPM in ingresso da ricevente
sbit EXH at TRISIO4_bit;
sbit REV at TRISIO2_bit;
sbit TAIL at TRISIO1_bit;
sbit HEAD at TRISIO0_bit;

// VARIABILI

unsigned char PPM_level = 0;
unsigned char PPM_start = 0;
unsigned char PPM_value = PPM_1500_US;
unsigned char PPM_updated = 0;

unsigned char PPM_neutral = 0;
unsigned char PPM_full = PPM_1500_US;
unsigned char PPM_antiglitch = 0;
unsigned char PPM_reverse = 0;
unsigned char PPM_maxzero;
unsigned char PPM_minzero;
unsigned char PPM_command = CMD_IDLE;

unsigned char new_user_cmd = 0;

unsigned char REV_status = 0;

unsigned char EXH_threshold;
unsigned char EXH_heat = 0;
unsigned char EXH_sequence = 0;
unsigned char EXH_delay = 0;
unsigned char EXH_bit = 0;

unsigned char PWM_i = 0;
unsigned char TAIL_pwm = PWM_OFF;

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

void hardwareTest()
{
    while(1)
    {
        PPM_updated = 0;
        while(!PPM_updated);
        
        if(PPM_value < PPM_1250_US)
        {
            HEAD = 0;
            TAIL = 1;
            REV = 1;
            EXH = 1;
        }
        else if(PPM_value < PPM_1500_US)
        {
            HEAD = 1;
            TAIL = 0;
            REV = 1;
            EXH = 1;
        }
        else if(PPM_value < PPM_1750_US)
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
    // PROGRAMMAZIONE UTENTE
    ALL_ON();

    // Leggo il segnale massimo
    i = 0;
    if(PPM_value > PPM_1500_US)
    {
        PPM_reverse = 0;
        while(i < PROGRAM_PPM_FRAMES)
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
        while(i < PROGRAM_PPM_FRAMES)
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

    // Salvo valore gas massimo
    EEPROM_Write(EEPROM_PPMFULL, PPM_full);
    
    ALL_OFF();
    
    // Aspetto che l'utente lasci il comando
    while(PPM_value > PPM_1600_US || PPM_value < PPM_1400_US);
    
    // Salvo valore gas neutro
    syncPPM(PROGRAM_PPM_FRAMES);
    PPM_neutral = PPM_value;
    EEPROM_Write(EEPROM_PPMNEUTRAL, PPM_neutral);
    EEPROM_Write(EEPROM_TESTED, 0);
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
    
    // Se sto accelerando, entro in programmazione
    if(PPM_value < PPM_1400_US || PPM_value > PPM_1600_US)
        userSetup();
        
    Delay_ms(500);

    // Prima accensione
    if(EEPROM_Read(EEPROM_TESTED) == 0xFF)
        hardwareTest();
    
    // Carico programmazione
    PPM_neutral = EEPROM_Read(EEPROM_PPMNEUTRAL);
    PPM_minzero = PPM_neutral - NEUTRAL_RANGE;
    PPM_maxzero = PPM_neutral + NEUTRAL_RANGE;
    PPM_full = EEPROM_Read(EEPROM_PPMFULL);
    if(PPM_full < PPM_neutral)
    {
        PPM_reverse = 1;
        EXH_threshold = PPM_neutral - ((PPM_neutral - PPM_full) / 2);
    }
    else
        EXH_threshold = PPM_neutral + ((PPM_full - PPM_neutral) / 2);

    // Inizializzazione comando
    PPM_command = CMD_IDLE;
    
    // Accendo le luci
    TAIL_pwm = PWM_DIM;
    HEAD = 0;
        
    // Loop principale!
     while(1)
     {
         if(PPM_updated)
         {
             // Verifica la posizione del canale
             if(PPM_value > PPM_maxzero)
             {
                 if(PPM_antiglitch < ANTIGLITCH_ZERO + ANTIGLITCH_COUNT)
                 {
                     PPM_antiglitch++;
                     PPM_command = CMD_IDLE;
                 }
                 else
                 {
                     if(PPM_reverse)
                         PPM_command = CMD_BRAKE;
                     else
                         PPM_command = CMD_FORWARD;
                 }
             }
             else if(PPM_value < PPM_minzero)
             {
                 if(PPM_antiglitch > ANTIGLITCH_ZERO - ANTIGLITCH_COUNT)
                 {
                     PPM_antiglitch--;
                     PPM_command = CMD_IDLE;
                 }
                 else
                 {
                     if(PPM_reverse)
                         PPM_command = CMD_FORWARD;
                     else
                         PPM_command = CMD_BRAKE;
                 }
             }
             else
             {
                 PPM_antiglitch = ANTIGLITCH_ZERO;
                 PPM_command = CMD_IDLE;
             }

             // Gestisco le uscite in base alla posizione del canale
             switch(PPM_command)
             {
                 case CMD_FORWARD:
                     // Spengo luci di stop
                     TAIL_pwm = PWM_DIM;
                     // Disattivo la retromarcia
                     REV = 1;
                     REV_status = REV_OFF;
                     // Temperatura di scarico
                     if(PPM_reverse)
                     {
                         if(PPM_value < EXH_threshold && EXH_heat < EXH_MAX_TEMP)
                             EXH_heat++;
                         else if(EXH_heat)
                             EXH_heat--;
                     }
                     else
                     {
                       if(PPM_value > EXH_threshold && EXH_heat < EXH_MAX_TEMP)
                           EXH_heat++;
                       else if(EXH_heat)
                           EXH_heat--;
                     }
                     break;

                 case CMD_BRAKE:
                     // Se ho già frenato, accendo le luci di retromarcia
                     if(REV_status == REV_ACTIVE)
                         REV = 0;
                     // Altrimenti accendo gli stop e attivo la retro per la prossima frenata
                     else
                     {
                         TAIL_pwm = PWM_FULL;
                         REV_status = REV_BRAKE;
                     }
                     // Gestione fiammata
                     if(EXH_heat >= EXH_IGNITION_TEMP)
                     {
                         // Attivazione sequenza fiammata
                         EXH_sequence = backfire[TMR0 & 0b00000011];
                         EXH_bit = 7;
                         EXH_heat = 0;
                     }
                     else if(EXH_heat)
                         EXH_heat--;
                     break;

                 default:
                     // Spengo luci di stop
                     TAIL_pwm = PWM_DIM;
                     // Preparo la retro in caso si freni ancora
                     if(REV_status == REV_BRAKE)
                         REV_status = REV_ACTIVE;
                     // Gestione fiammata
                     if(EXH_heat >= EXH_IGNITION_TEMP)
                     {
                         // Attivazione sequenza fiammata
                         EXH_sequence = backfire[TMR0 & 0b00000011];
                         EXH_bit = 7;
                         EXH_heat = 0;
                     }
                     else if(EXH_heat)
                         EXH_heat--;
             }

              PPM_updated = 0;
         }

        // Fiammata
        if(--EXH_delay == 0)
        {
            EXH_delay = EXH_DELAY_CYCLES;
             if(EXH_bit)
            {
                EXH_bit--;
                EXH = !EXH_sequence.B0;
                EXH_sequence = EXH_sequence >> 1;
            }
        }
             
        if(++PWM_i > PWM_CYCLE)
            PWM_i = 0;
        if(TAIL_pwm > PWM_i) TAIL = 0; else TAIL = 1;

        Delay_us(PWM_DELAY_US);
     }
}