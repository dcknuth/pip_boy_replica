// AAA battery (designed to stay put in a normal holder)
// Some of the measurements are slightly diffent than specification
//  to print at the right size or to better hold in the holder that
//  I happen to have. You can pass in whatever you need
$fn = 100;

module batteryNoRing(d=10.4, body_l=43.1, pos_button_d=3.6,
                  pos_button_h=1.0, pos_nub_d=1.2, pos_nub=true) {
  nub_h = 1.0;
  union() {
    cylinder(h=body_l, d=d);
    // positive terminal button
    translate([0, 0, body_l])
      cylinder(h=pos_button_h, d1=pos_button_d+0.2, d2=pos_button_d);
    if (pos_nub) {
      translate([0, 0, body_l+pos_button_h])
        cylinder(h=nub_h, d1=pos_nub_d+0.2, d2=pos_nub_d-0.2);
    }
  }
}

module aaaBattery(d=10.4, body_l=43.1, pos_button_d=3.6,
                  pos_button_h=1.0, pos_nub_d=1.2, pos_nub=true,
                  neg_ring_d=1.7, neg_ring_outer=5.5, neg_ring=true) {
  if (neg_ring) {
    difference() {
      batteryNoRing(d=d, body_l=body_l, pos_button_d=pos_button_d,
                    pos_button_h=pos_button_h, pos_nub_d=pos_nub_d,
                    pos_nub=pos_nub);
      // ring for first spring coil to sit in
      rotate_extrude(convexity = 10)
        translate([neg_ring_outer/2, 0, 0])
          circle(r=neg_ring_d/2);
    }
  }
  else {
    batteryNoRing(d=d, body_l=body_l, pos_button_d=pos_button_d,
                  pos_button_h=pos_button_h, pos_nub_d=pos_nub_d,
                  pos_nub=pos_nub);
  }
}

// test set
my_offset = 20;
aaaBattery();
translate([-my_offset, 0, 0])
  aaaBattery(neg_ring=false);
translate([my_offset, 0, 0])
  aaaBattery(pos_nub=false, neg_ring=false);
// AA
translate([0, my_offset, 0])
  aaaBattery(d=14.1, body_l=48.6, pos_button_d=5.1,
              pos_button_h=1.4, pos_nub_d=1.2, pos_nub=false,
              neg_ring_d=1.3, neg_ring_outer=5.9, neg_ring=false);
