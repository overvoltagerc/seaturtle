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

#define PWM_CYCLE 16
#define PWM_DELAY_US 200
#define PWM_OFF 0
#define PWM_FULL 16

#define XENON_HEAT 600

#define ALL_OFF() HEAD1 = 1; HEAD2 = 1; TAIL1 = 1; TAIL2 = 1;
#define HEAD_ON() HEAD1 = 0; HEAD2 = 0;
#define HEAD_OFF() HEAD1 = 1; HEAD2 = 1;
#define TAIL_ON() TAIL1 = 0; TAIL2 = 0;

#define CMD_OFF 0
#define CMD_ON 1