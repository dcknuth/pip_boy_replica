# Platformio Project for Pip-Boy Replica
This is the code part for the ESP32-3248S035 that is the screen of the replica and drives most of the functionality

## Warnings
* TJpg_Decoder cannot handle progressively encoded jpegs. It will find the file, but report 0 width and height and not display
* Some of the options to libraries used seem to have to be passed in as compiler flags to make it to the compiling of the parts of the libraries. This is why there are a bunch of "-D" flags in the platformio.ini file. This can cause confusion with descriptions/instructions using the Arduino IDE which don't seem to need this
* Also a difference, PlatformIO wants proper function declarations or definitions prior to using them, which Arduino often does not need, so I move those up front or declare them as needed

## Overview
There are five modes to the device that are each pretty simple on their own and I use a rotary encoder library to help switch between the modes. Each of the modes might have three pieces:
1. Definitions or declarations in the pip_boy_config.h file or at the top of the main.cpp file. I have tried to keep them all there and this includes functions needed
2. Setup is mostly in the main setup function as it is supposed to be
3. The loop in main is setup to first change between the modes in response to a move of the rotary encoder and then to keep any current background tasks running for the mode in use

The modes are:
### Fallout Boy
This just displays an image of Fallout Boy in Portrait so that if you are holding the PipBoy on the left hand up, he shows in the proper way. All the images come off of the SD card as the modes switches via the TJpg_Decoder library. This image is the only one that needs to be rotated 90 degrees clockwise before being stored to the card
### Geiger Counter
This will display a speedometer-like gauge where the needle should point at the current count from the geiger counter. The geiger counter sends this out over its serial connection every second and we try to pull characters from this one-by-one every time through the event loop. This is done via this EspSoftwareSerial library. When we get to the end of a line, the count for that second is updated and the needle for the gauge is moved when a change in that value is detected. There is a pound define to just keep bouncing the value from 0 to 100 as background radiation seems to average a bit under 1. You have to hold a source very close to the tube to get more than three counts in a second. A log (or adaptive) scale might be better, but is left as an exercise for the reader. The count goes to zero if the geiger counter is starting or something weird happens to the serial line (as a natural part of trying to parse and read the input). This should be fine and things will fix themselves when the updates start or the next line comes in. The updating of the needle is done with the TFT_eSPI library and two sprites.
### Status
Just displays a static, status image from the in-game PipBoy in proper landscape orientation
### Flashlight
Sets the screen to white and turns on the front facing LED at a high brightness. Interesting and the particular board I used had the LED on the front, but probably not great as an actual flashlight. Matches a function of the PipBoy in the games though
### Radio
Displays a static radio image from the games and plays a version of the intro song to Fallout 3 via the ESP8266Audio library
