// Attachment point for nylon/velcrow band
// Assumed 0.2 y overlap for union (half of connect)
// Assumed no support or support to bed only
// If your printer cannot bridge a gap the width of the strap
//  you are going to use, set flat_top to false
$fn = 100;
FUDGE = 0.001;

module attachOuter(w, lug_d, wall=1.2, strap_gap=2.3, connect=0.4) {
  l = w + wall*2;
  d = lug_d*2+strap_gap*4+wall*2+connect;
  difference() {
    rotate([0, 90, 0])
      cylinder(h=l, d=d);
    translate([-FUDGE, 0, -d*1.5])
      cube([l*2, d*2, d*3]);
    translate([-FUDGE, -d*2, -d*2])
      cube([l*2, d*4, d*2]);
  }
}

module cutout(w, lug_d, strap_gap, flat_top=true) {
  d = lug_d+strap_gap*2;
  union() {
    rotate([0, 90, 0])
      cylinder(h=w, d=d);
    translate([0, 0, sqrt((d/2*d/2)/2)])
      rotate([90, 0, 90])
        linear_extrude(w)
          if (flat_top) {
            polygon([[-sqrt((d/2*d/2)/2), 0],
                    [sqrt((d/2*d/2)/2), 0],
                    [lug_d/2, sqrt((d/2*d/2)/2)-lug_d/2],
                    [-lug_d/2, sqrt((d/2*d/2)/2)-lug_d/2],
                    [-sqrt((d/2*d/2)/2), 0]]);
          } else {
            polygon([[-sqrt((d/2*d/2)/2), 0],
                    [sqrt((d/2*d/2)/2), 0],
                    [0, sqrt((d/2*d/2)/2)],
                    [-sqrt((d/2*d/2)/2), 0]]);
          }
  }
}

module attach(w, lug_d, wall=1.2, strap_gap=2.3, connect=0.4,
              flat_top=true) {
  l = w + wall*2;
  d = lug_d*2+strap_gap*4+wall*2+connect;
  union() {
    difference() {
      attachOuter(w, lug_d, wall=1.2, strap_gap=2.3, connect=0.4);
      translate([wall, -(lug+strap_gap*2+connect)/2, 0])
        cutout(w, lug_d, strap_gap);
    }
    translate([0, -(lug+strap_gap*2+connect)/2, 0])
      difference() {
        rotate([0, 90, 0])
          cylinder(h=l, d=lug_d);
        translate([-FUDGE, -lug_d*2, -lug_d*2])
          cube([l*2, lug_d*4, lug_d*2]);
      }
  }
}

lug = 3.0;
width = 10.2;
strap_gap = 2.3;
wall = 1.2;
union() {
  translate([0, 0.2, 0])
  attach(width, lug);
  cube([width+2*wall, 78.2, lug+strap_gap*2+wall+0.2]);
  translate([width+2*wall, 78.2-0.2, 0])
    rotate([0, 0, 180])
      attach(width, lug);
}