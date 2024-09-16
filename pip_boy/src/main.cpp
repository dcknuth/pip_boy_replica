#include <Arduino.h>
#include <WiFi.h>
#include <TJpg_Decoder.h>
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
#include <TFT_eSPI.h>              // Hardware-specific library
TFT_eSPI tft = TFT_eSPI();         // Invoke custom library

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

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_OFF);

  // led setup (black)
  pinMode(4, OUTPUT);
  pinMode(17, OUTPUT);
  pinMode(16, OUTPUT);
  ledOff();

  // Initialise the TFT
  tft.begin();
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
  TJpgDec.setCallback(tft_output);

  // Setup rotary encoder to be our mode selector
  // Set mode select encoder pins as inputs  
  pinMode(rotary_encoder_CLK_pin,INPUT);
  pinMode(rotary_encoder_DT_pin,INPUT);
  PB_prev_StateCLK = digitalRead(rotary_encoder_CLK_pin);
}

void loop() {
  int status = -1;
  // check for mode change
  PB_mode_StateCLK = digitalRead(rotary_encoder_CLK_pin);
  if (PB_mode_StateCLK != PB_prev_StateCLK) { 
    if (digitalRead(rotary_encoder_DT_pin) != PB_mode_StateCLK) { 
      PB_mode_counter++;
      PB_mode_encdir = "CW";
    } else {
      PB_mode_counter--;
      PB_mode_encdir = "CCW";
    }
    if (PB_DEBUG) {
      Serial.print("Direction: ");
      Serial.print(PB_mode_encdir);
      Serial.print(" -- Value: ");
      Serial.println(PB_mode_counter);
    }
    PB_prev_StateCLK = PB_mode_StateCLK;
    // with our encoder we get +2 to our counter with a clockwise detent move
    // and minus two for a counterclockwise detent move
    if (PB_mode_counter == PB_mode_counter_prev + 2) {
      if (PipBoy_mode < PB_MaxMode) {
        PipBoy_mode++;
        PB_mode_counter_prev = PB_mode_counter;
      }
    }
    if (PB_mode_counter == PB_mode_counter_prev - 2) {
      if (PipBoy_mode > PB_MinMode) {
        PipBoy_mode--;
        PB_mode_counter_prev = PB_mode_counter;
      }
    }
  }
  if (PipBoy_mode != PipBoy_mode_prev) {
    if (PB_DEBUG) {
      Serial.printf("New mode is %d\n", PipBoy_mode);
    }
    // handle fallout-boy mode (default start position)
    if (PipBoy_mode == PB_FALLOUT_BOY) {
      ledOff();
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
        Serial.printf("Exiting change to PB_FALLOUT_BOY with status %d\n", status);
      }
    }
    // handle status mode
    if (PipBoy_mode == PB_SHOW_STATUS) {
      ledOff();
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
    }
    // handle radio mode
    if (PipBoy_mode == PB_RADIO) {
      ledOff();
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
  if (PipBoy_mode == PB_RADIO) {
      mp3->loop();
  }
}
