// screw guide
$fn = 50;
FUDGE = 0.001;

body_l = 20.0;
inside_d = 6.6;
wall = 1.2;
outside_d = inside_d + wall*2;

union() {
  difference() {
    cylinder(h=body_l, d=outside_d);
    translate([0, 0, -FUDGE/2])
      cylinder(h=body_l+FUDGE, d=inside_d);
  }
  hull() {
    translate([outside_d/2-wall/2, 0, wall/2])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
    translate([body_l/2, 0, body_l/2])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
    translate([outside_d/2-wall/2, 0, body_l-wall/2])
      rotate([90, 0, 0])
        cylinder(h=wall, d=wall, center=true);
  }
}