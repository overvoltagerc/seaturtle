/* SEATURTLE
    2016 tHeo
*/

#include "built_in.h"

#define PPM_MIN_VALID 112
#define PPM_1000_US 125
#define PPM_1166_US 146
#define PPM_1200_US 150
#define PPM_1250_US 156
#define PPM_1333_US 167
#define PPM_1400_US 175
#define PPM_1500_US 188
#define PPM_1600_US 200
#define PPM_1666_US 208
#define PPM_1750_US 219
#define PPM_1800_US 225
#define PPM_1833_US 229
#define PPM_2000_US 250

#define ANTIGLITCH_ZERO 128
#define ANTIGLITCH_COUNT 5
#define PROG_NEUTRAL_RANGE 15
#define NEUTRAL_RANGE 2

#define STARTUP_PPM_FRAMES 100
#define PROGRAM_PPM_FRAMES 150

#define FLASH_DELAY_MS 200
#define PROG_FLASH_DELAY_MS 1000

#define PWM_CYCLE 16
#define PWM_DELAY_US 200
#define PWM_OFF 0
#define PWM_DIM 4
#define PWM_FULL 16

#define CMD_IDLE 0
#define CMD_FORWARD 1
#define CMD_BRAKE 2
#define CMD_NULL 3

#define XENON_HEAT 600

#define REV_OFF 0
#define REV_BRAKE 1
#define REV_ACTIVE 2

#define EXH_MAX_TEMP 100
#define EXH_IGNITION_TEMP 50
#define EXH_DELAY_CYCLES 50

#define ALL_ON() HEAD = 0; TAIL = 0; REV = 0; EXH = 0;
#define ALL_OFF() HEAD = 1; TAIL = 1; REV = 1; EXH = 1;

#define EEPROM_TESTED 0
#define EEPROM_PPMNEUTRAL 1
#define EEPROM_PPMFULL 2

const unsigned char backfire[] = {0b10000001, 0b00101000, 0b00000001, 0b10010001};