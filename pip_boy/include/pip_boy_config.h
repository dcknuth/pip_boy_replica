// Rotary Encoder Inputs
#define rotary_encoder_CLK_pin 21
#define rotary_encoder_DT_pin 22
#define GeigerSerial 35
#define PB_MaxMode 5
#define PB_MinMode 1
#define PB_FALLOUT_BOY 1
#define PB_GEIGER 2
#define PB_SHOW_STATUS 3
#define PB_FLASHLIGHT 4
#define PB_RADIO 5

// mode starting values should initialize us to mode 1 first time through
long PipBoy_mode = 1;
long PipBoy_mode_prev = 0;
const char *MP3_FILENAME = "/I Don't Want To Set The World On Fire.mp3";
const char *FALLOUT_BOY = "/fallout-boy480x320.jpg";
const char *GEIGER_BG = "/rads_dial.jpg";
const char *GEIGER_NEEDLE = "/rads_needle.jpg";
const char *SHOW_STATUS = "/status_480x320.jpg";
const char *RADIO_JPG = "/radio480x320.jpg";
int Rad_Count = 0;
int Rad_Last = 0;
// int cps = 0;
// int cpm = 0;
bool Rad_Up = true;
bool GEIGER = true;
String geigerSerial;
unsigned char geigerData;
// float sieverts = 0;
// float svyear = 0;
boolean newGeigerVals = false;