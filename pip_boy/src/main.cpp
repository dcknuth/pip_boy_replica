#include <Arduino.h>
#include <WiFi.h>
#include "AudioFileSourceSD.h"
#include "AudioFileSourceID3.h"
#include "AudioGeneratorMP3.h"
#include "AudioOutputI2S.h"
#include "pip_boy_config.h"

AudioFileSourceSD *play_file;
AudioGeneratorMP3 *mp3;
AudioOutputI2S *audio_out;
AudioFileSourceID3 *id3;
SPIClass SDSPI(VSPI);

void startPlayback() {
  if (!mp3) {
    play_file = new AudioFileSourceSD(mp3_filename);
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

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_OFF);
  // SD setup
  pinMode(5, OUTPUT);
  digitalWrite(5, HIGH);
  SDSPI.begin(18, 19, 23); // SDSPI.begin(SCLK, MISO, MOSI);
  SDSPI.setFrequency(1000000);
  SD.begin(5, SDSPI);

  // Setup rotary encoder to be our mode selector
  // Set mode select encoder pins as inputs  
  pinMode(rotary_encoder_CLK_pin,INPUT);
  pinMode(rotary_encoder_DT_pin,INPUT);
  PB_prev_StateCLK = digitalRead(rotary_encoder_CLK_pin);
}

void loop() {
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
    // handle radio mode
    if (PipBoy_mode == PB_RADIO) {
      startPlayback();
      mp3->loop();
    }
    else if(PipBoy_mode != PB_RADIO && PipBoy_mode_prev == PB_RADIO) {
      stopPlayback();
    }
    PipBoy_mode_prev = PipBoy_mode;
  }
  if (PipBoy_mode == PB_RADIO) {
      mp3->loop();
  }
}
