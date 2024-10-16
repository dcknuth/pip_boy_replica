# Pip-Boy Replica
Making a Pip-Boy replica. Will not exactly match any given model from the game or episodes, but is inspired by them

## Function List
These are the functions that we will try to add to our Pip-Boy with a bit of discussion on how and why
* Fallout Boy - Just a picture of the "thumbs up" fallout boy image. Recognizable from a distance and was a big plot item for the Amazon Fallout series in addition to being common in the games
* Geiger Counter - A real, working one based on data passed from a [MightyOhm Geiger Counter DIY kit](https://mightyohm.com/blog/products/geiger-counter/). I think I bought mine through [AdaFruit](https://www.adafruit.com/product/483) because they are a solid vendor
* Status Indicator - Just a static screen borrowed from the Fallout 3 video game
* Flashlight - Will just turn on the screen to white and the front-facing LED of this particular board to ~90%. Might even be useful Halloween night?
* Radio - Will play "I Don't Want to Set the World on Fire", which was the intro song to the Fallout 3 video game and was in the Amazon series. The screen will show a static radio mode image from the game

## The Case
The case is 3D printed and will be in four parts:
* A bottom that the Geiger counter can be screwed into. It will additionally house:
  - Cutouts to the Geiger-Muller tube. For better reading, but mostly so you can just see it's there
  - Power switch for the Geiger counter and one for the screen/system
  - Hole and key for the rotary encoder board
  - Speaker grills for the beeper on the Geiger counter and for the speaker from the main board
  - Hole for a USB-C connector. This will charge the battery, not program the ESP32
  - Holes to hold small magnets to secure the top to the bottom
* A case top with the following:
  - Hole for the screen and LED. Also a recess for the unused ambient light sensor
  - A hood, mostly for aesthetic reasons. It's there in the game and other replicas and will give us a place to put some lettering that is visible
  - Indicator markings for what mode we are in
  - Holes for the small magnets to hold the top and bottom together
* A knob, to select the mode we are in. It will pressure fit to the rotary encoder shaft
* A pocket for the lithium polymer battery. It will be combined with a AAA blank so it can go where a AAA would be placed in the Geiger counter. This should keep it from moving around inside the case and damaging the Geiger tube.

All the OpenSCAD models are in the [3d_models](https://github.com/dcknuth/pip_boy_replica/3d_models) directory. There are a few extras that are needed modules or might be helpful

## Parts List
Will fill this in as the project progresses
* [Display with ESP32 - ESP32-3248S035](https://www.amazon.com/gp/product/B0C4KSKW96)
* [MightyOhm Geiger Counter](https://www.adafruit.com/product/483)
* Small speaker - I salvaged mine from some old device that I no longer remember
* [Rotary encoder](https://www.amazon.com/gp/product/B07B68H6R8) - to switch between modes. A custom knob will go on top of this
* 3D printer, I will not link, but I have an Ender3 that is a couple years old
* I used [this filament](https://www.amazon.com/gp/product/B00MEZEEJ2/), but most PLA should be fine. This is a color that would be forgiving if it shows through
* [Step up and charge controller board](https://www.amazon.com/gp/product/B09YD5C9QC/?th=1) This will get you the 5 volts you need to power the ESP32 board above from the lithium polymer battery below
* [Lipo battery](https://www.amazon.com/gp/product/B098DSP8YC/) Can power both the ESP32 board and the Geiger counter for some time and will still fit inside the case (smaller than the Geiger counter length)
* [Buck down](https://www.amazon.com/gp/product/B07T7L51ZW/) Converter to go from 5v to the 3v the Geiger counter wants
* [Jumper kit](https://www.amazon.com/gp/product/B08RMQP6YP/) To make jumper cables for the power switches and to hook things up in a way that can be disassembled easily
* [4-40 screws](https://www.amazon.com/gp/product/B0BNN7YRX8/) These are a good size to keep the Geiger attached to the bottom of the case with threads that are just big enough to 3D print a female side to the mount pads. I used the shortest 3/16 length
* [USB-C right angle](https://www.amazon.com/gp/product/B0B2NJ3P3L/) This allowed a friction fit to hold the step-up/charger board to the side of the case and to plug/unplug a charging cable without having to stress the PipBoy too much
* Small SD card. Any <= 4G should work. After some trouble that was not the fault of my first card, I bought [these](https://www.amazon.com/gp/product/B0D2SW1BLR/?th=1) They work
* Some [black nylon screws](https://www.amazon.com/gp/product/B0BNB1K5P2/) and nuts to hold the screen to the top part of the box
* Some [super glue](https://www.amazon.com/gp/product/B0041GVBBG/) To glue in the magnets
* I used the smallest of [these magnets](https://www.amazon.com/gp/product/B0CW65QR14/) You can look at the size of the holes that they go in to double check sizing
* I already had some hook and loop cable manager on hand, [like this](https://www.amazon.com/Xnakko-Double-Fastening-Reusable-Manager/dp/B095PNTVJ4/) to go through the lugs at the corners of the lower case and hold it to your forearm
* [This](https://www.amazon.com/gp/product/B07N6HFBRX/) smoothed out the 3D prints with some acetone to dilute it to make it easier to work with
* Then [this](https://www.amazon.com/Rust-Oleum-Automotive-260510-12-Ounce-Sandable/dp/B006ZLQ4HQ/) to prime and finish filling in the parts
* To paint the raised lettering I used [acrylic pens](https://www.amazon.com/gp/product/B0BKP1M6QK/?th=1)
* I borrowed my daughter's acrylic paints and brushes to do non-spray parts (I got her some additional to even things up)
* Most parts were finished with [this pounded pewter spray paint](https://www.homedepot.com/p/BEHR-PREMIUM-12-oz-SP-303-Antique-Pewter-Gloss-Interior-Exterior-Hammered-Spray-Paint-Aerosol-B061344/319367935) I don't know if I super-love this, but it worked
* You will need a variety of sandpaper

