#include <Arduino.h>
#include <WiFi.h>
#include <TJpg_Decoder.h>
#include <ESP32RotaryEncoder.h>
#include <SoftwareSerial.h>
#include "AudioFileSourceSD.h"
#include "AudioFileSourceID3.h"
#include "AudioGeneratorMP3.h"
#include "AudioOutputI2S.h"
#include "pip_boy_config.h"
// images
#define FS_NO_GLOBALS
#include <FS.h>
#ifdef ESP32
  #include "SPIFFS.h" // ESP32 only
#endif
#define SD_CS   5
// Include the TFT library https://github.com/Bodmer/TFT_eSPI
#include "SPI.h"
#include <TFT_eSPI.h> 
TFT_eSPI tft = TFT_eSPI();
TFT_eSprite back = TFT_eSprite(&tft); // background for geiger needle
TFT_eSprite needle = TFT_eSprite(&tft); // geiger needle

// Gieger serial port RX(our esp32 GPIO)
//  TX (33 listed, but no TX needed receive only)
SoftwareSerial SWSerial(GeigerSerial, 33);

// rotary encoder
RotaryEncoder rotaryEncoder(rotary_encoder_CLK_pin, rotary_encoder_DT_pin);
void knobCallback(long value) {
    // This gets executed every time the knob is turned
    if (PB_DEBUG) {
      Serial.printf( "Value: %i\n", value );
    }
    PipBoy_mode = value;
}

// audio
AudioFileSourceSD *play_file;
AudioGeneratorMP3 *mp3;
AudioOutputI2S *audio_out;
AudioFileSourceID3 *id3;
SPIClass SDSPI(VSPI);

// draw
bool tft_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap) {
  // Stop further decoding as image is running off bottom of screen
  if ( y >= tft.height() ) return 0;
  // This function will clip the image block rendering automatically at the TFT boundaries
  tft.pushImage(x, y, w, h, bitmap);
  return 1;
}
bool needle_output(int16_t x, int16_t y, uint16_t w, uint16_t h, uint16_t* bitmap) {
  // Stop further decoding as image is running off bottom of screen
  if ( y >= needle.height() ) return 0;
  // This function will clip the image block rendering automatically at the TFT boundaries
  needle.pushImage(x, y, w, h, bitmap);
  return 1;
}

void startPlayback() {
  if (!mp3) {
    play_file = new AudioFileSourceSD(MP3_FILENAME);
    id3 = new AudioFileSourceID3(play_file);
    audio_out = new AudioOutputI2S(0, 2, 8, -1); // Output to builtInDAC
    audio_out->SetOutputModeMono(true);
    audio_out->SetGain(1.0);
    mp3 = new AudioGeneratorMP3();
    mp3->begin(id3, audio_out);
  }
}

void stopPlayback() {
  if (mp3) {
    mp3->stop();
    delete mp3;
    mp3 = NULL;
  }
  if (id3) {
    id3->close();
    delete id3;
    id3 = NULL;
  }
  if (audio_out) {
    audio_out->stop();
    delete audio_out;
    audio_out = NULL;
  }
  if (play_file) {
    play_file->close();
    delete play_file;
    play_file = NULL;
  }
  if (PB_DEBUG) {
    Serial.println("Stopped music and cleaned up");
  }
}

void ledOff(void) {
  digitalWrite(4, 1.0);
  digitalWrite(16, 1.0);
  digitalWrite(17, 1.0);
}

void getGeiger() {
  if (SWSerial.available()) {
    geigerData = (SWSerial.read());
    geigerSerial += char(geigerData);
  }
}
void processGeiger() {
  if (geigerData == 0x0D) {  // \r CR detected
    // Parse CPS, CPM, and uS/hr from the string
    int comma1Index = geigerSerial.indexOf(',');
    int comma2Index = geigerSerial.indexOf(',', comma1Index + 1);
    int comma3Index = geigerSerial.indexOf(',', comma2Index + 1);
    int comma4Index = geigerSerial.indexOf(',', comma3Index + 1);
    int comma5Index = geigerSerial.indexOf(',', comma4Index + 1);
    int comma6Index = geigerSerial.indexOf(',', comma5Index + 1);
    String cpsString = geigerSerial.substring(comma1Index + 1, comma2Index);
    String cpmString = geigerSerial.substring(comma3Index + 1, comma4Index);
    String sievertsString = geigerSerial.substring(comma5Index + 1, comma6Index);
    if (cpsString != "") {
      Rad_Last = Rad_Count;
      Rad_Count = cpsString.toInt();
      newGeigerVals = true;
    }
    // cpm = cpmString.toInt();
    // sieverts = sievertsString.toFloat();
    // svyear = (sieverts * 8.76);
    geigerSerial = "";  // Clear the string for next time
  }
}
void updateGeigerCount(void) {
  if (GEIGER == false) {
    if (Rad_Up == true && Rad_Count < 100) {
      Rad_Count++;
    } else if (Rad_Up == false && Rad_Count > 0) {
      Rad_Count--;
    } else if (Rad_Up == true && Rad_Count > 99) {
      Rad_Count = 99;
      Rad_Up = false;
    } else {
      Rad_Count = 1;
      Rad_Up = true;
    }
  } else {
    getGeiger();       // Grab MightyOhm serial data
    processGeiger();   // Extract data and process
  }
}

void paintNeedle(int count) {
  float angle = count * 1.8;
  // if (PB_DEBUG) {
  //       Serial.printf("We are in paint needle with count %d and angle %f\n", count, angle);
  // }
  back.fillSprite(TFT_BLACK);
  needle.pushRotated(&back, angle, TFT_BLACK);
  back.pushSprite(129, 121);
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_OFF);
  Serial.begin(115200);
  SWSerial.begin(9600);

  // led setup
  pinMode(4, OUTPUT);
  pinMode(17, OUTPUT);
  pinMode(16, OUTPUT);
  ledOff();

  // Initialise the TFT
  tft.begin();
  tft.setRotation(3);
  tft.fillScreen(TFT_BLACK);
  tft.setSwapBytes(true); // We need to swap the colour bytes (endianess)

  // SD setup (needs to be after tft for esp32)
  pinMode(5, OUTPUT);
  digitalWrite(5, HIGH);
  SDSPI.begin(18, 19, 23); // SDSPI.begin(SCLK, MISO, MOSI);
  SDSPI.setFrequency(1000000);
  if (!SD.begin(5, SDSPI)) {
    Serial.println(F("SD.begin failed!"));
    while (1) delay(0);
  }
  
  // The jpeg image can be scaled by a factor of 1, 2, 4, or 8
  TJpgDec.setJpgScale(1);
  // The decoder must be given the exact name of the rendering function above
  TJpgDec.setCallback(needle_output);
  if (needle.createSprite(211, 21) == nullptr && PB_DEBUG) {
    Serial.println("Needle sprite NOT created, insufficient RAM!");
  }
  needle.setSwapBytes(true);
  TJpgDec.drawSdJpg(0, 0, GEIGER_NEEDLE);
  // back to writing to the tft
  TJpgDec.setCallback(tft_output);
  // create the needle background sprite
  if (back.createSprite(211, 117) == nullptr && PB_DEBUG) {
    Serial.println("Background sprite NOT created, insufficient RAM!");
  }
  back.fillScreen(TFT_BLACK);
  back.setPivot(105, 105);

  // This tells the library that the rotary encoder has its own pull-up resistors
  rotaryEncoder.setEncoderType( EncoderType::HAS_PULLUP );
  // we have 5 modes, do not wrap around
  rotaryEncoder.setBoundaries(PB_MinMode, PB_MaxMode, false);
  rotaryEncoder.onTurned(&knobCallback);
  rotaryEncoder.begin();

  // LED should start off
  ledOff();
}

void loop() {
  int status = -1;
  // check for mode change
  if (PipBoy_mode != PipBoy_mode_prev) {
    if (PB_DEBUG) {
      Serial.printf("New mode is %d\n", PipBoy_mode);
    }
    // handle fallout-boy mode (default start position)
    if (PipBoy_mode == PB_FALLOUT_BOY) {
      if (PB_DEBUG) {
        Serial.printf("We are in the PB_FALLOUT_BOY section\n");
      }
      if (PB_DEBUG) {
        uint16_t w = 0, h = 0;
        TJpgDec.getSdJpgSize(&w, &h, FALLOUT_BOY);
        Serial.printf("%s width is %d and height is %d\n", FALLOUT_BOY, w, h);
      }
      // Draw the image at 0,0
      status = TJpgDec.drawSdJpg(0, 0, FALLOUT_BOY);
      if (PB_DEBUG) {
        Serial.printf("Exiting change to PB_FALLOUT_BOY\n");
      }
    }
    // handle geiger counter mode
    if (PipBoy_mode == PB_GEIGER) {
      if (PB_DEBUG) {
        Serial.printf("We are in the PB_GEIGER section\n");
      }
      status = TJpgDec.drawSdJpg(0, 0, GEIGER_BG);
      // paint the indicator/needle
      paintNeedle(Rad_Count);
    }
    // handle status mode
    if (PipBoy_mode == PB_SHOW_STATUS) {
      if (PB_DEBUG) {
        Serial.printf("We are in the PB_SHOW_STATUS section\n");
      }
      if (PB_DEBUG) {
        uint16_t w = 0, h = 0;
        TJpgDec.getSdJpgSize(&w, &h, SHOW_STATUS);
        Serial.printf("%s width is %d and height is %d\n", SHOW_STATUS, w, h);
      }
      // Draw the image at 0,0
      status = TJpgDec.drawSdJpg(0, 0, SHOW_STATUS);
      if (PB_DEBUG) {
        Serial.printf("Exiting change to PB_SHOW_STATUS with status %d\n", status);
      }
    }
    // handle flashlight mode
    if (PipBoy_mode == PB_FLASHLIGHT) {
      if (PB_DEBUG) {
        Serial.printf("We are in the PB_FLASHLIGHT section\n");
      }
      tft.fillScreen(TFT_WHITE);
      digitalWrite(4, 0.1);
      digitalWrite(16, 0.1);
      digitalWrite(17, 0.1);
      if (PB_DEBUG) {
        Serial.printf("Exiting change to PB_FLASHLIGHT with status %d\n", status);
      }
    } else if (PipBoy_mode != PB_FLASHLIGHT && PipBoy_mode_prev == PB_FLASHLIGHT) {
      ledOff();
    }
    // handle radio mode
    if (PipBoy_mode == PB_RADIO) {
      TJpgDec.drawSdJpg(0, 0, RADIO_JPG);
      startPlayback();
      mp3->loop();
    }
    else if(PipBoy_mode != PB_RADIO && PipBoy_mode_prev == PB_RADIO) {
      stopPlayback();
    }
    PipBoy_mode_prev = PipBoy_mode;
  }
  // mode has not changed, handle things that need updates
  else if (PipBoy_mode == PB_RADIO) {
      mp3->loop();
  } else if (PipBoy_mode == PB_GEIGER) {
    if (Rad_Count != Rad_Last) {
      paintNeedle(Rad_Count);
      Rad_Last = Rad_Count;
    }
  }
  // always look for new geiger values
  updateGeigerCount();
  if (newGeigerVals && PB_DEBUG) {
    Serial.print("CPS: ");
    Serial.println(Rad_Count);
    newGeigerVals = false;
  }
}
