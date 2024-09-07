// Rotary Encoder Inputs
#define rotary_encoder_CLK_pin 21
#define rotary_encoder_DT_pin 22
#define PB_MaxMode 5
#define PB_MinMode 1
#define PB_FALLOUT_BOY 1
#define PB_GEIGER 2
#define PB_SHOW_STATUS 3
#define PB_FLASHLIGHT 4
#define PB_RADIO 5

int PipBoy_mode = 0;
int PipBoy_mode_prev = PipBoy_mode;
int PB_mode_counter = 0;
int PB_mode_counter_prev = PB_mode_counter;
int PB_mode_StateCLK;
int PB_prev_StateCLK;
String PB_mode_encdir ="";
const char *mp3_filename = "/01 - I Don't Want To Set The World On Fire (Remastered).mp3";
