// aaa blank with a handle on it to set a board into a tight box
$fn = 100;
use <aaa_battery.scad>;
body_l = 42.8;
aaa_d = 10.4;
wall = 1.6;

union() {
  aaaBattery(body_l=body_l, pos_button_h=0.8);
  hull() {
    translate([aaa_d/2-wall, 0, wall])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
    translate([body_l/2.5, 0, body_l/2])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
    translate([aaa_d/2-wall, 0, body_l-wall])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
  }
}