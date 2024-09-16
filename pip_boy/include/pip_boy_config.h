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
#define MAX_IMAGE_WIDTH 320 // this is our screen width in pixels

// mode starting values should initialize us to mode 0 first time through
int PipBoy_mode = 1;
int PipBoy_mode_prev = 0;
int PB_mode_counter = 0;
int PB_mode_counter_prev = PB_mode_counter;
int PB_mode_StateCLK;
int PB_prev_StateCLK;
String PB_mode_encdir ="";
const char *MP3_FILENAME = "/I Don't Want To Set The World On Fire.mp3";
const char *FALLOUT_BOY = "/fallout-boy320x480.jpg";
const char *SHOW_STATUS = "/status_320x480.jpg";
const char *RADIO_JPG = "/radio320x480.jpg";
