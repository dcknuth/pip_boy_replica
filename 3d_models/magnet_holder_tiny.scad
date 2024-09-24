// holder for small cylinder magnets
// using a hole relief for shinkage of 0.4
// designed to allow a little room for glue with a slight lip
//  on the top for just a bit of extra hold
$fn = 100;
FUDGE = 0.001;

module magnetHolder(d=3.3, h=2.8, wall=1.2, layer_h=0.2, layer_w=0.4,
                    bottom_taper=false) {
  difference() {
    if (bottom_taper) {
      union() {
        cylinder(h=h+wall+layer_h, d=d+wall*2);
        translate([0, 0, -(d+wall*2)])
          cylinder(h=d+wall*2, d1=0.001, d2=d+wall*2);
      }
    } else {
    cylinder(h=h+wall+layer_h, d=d+wall*2);
    }
    translate([0, 0, wall+FUDGE/2])
      union() {
        cylinder(h=h, d=d);
        translate([0, 0, h])
          cylinder(h=layer_h, d=d-layer_w*0.4);
      }
        
  }
}

module magBlank(d=3.3, h=2.8, wall=1.2, layer_h=0.2) {
  cylinder(h=h+wall+layer_h, d=(d+wall*2)-FUDGE);
}

// two test blocks
h=2.8;
wall=1.2;
layer_h=0.2;
translate([-20, -20, 0])
  union() {
    difference() {
      cube([40, 10, 5]);
      translate([7, 5, 5-(h+wall+layer_h-FUDGE)])
        magBlank();
      translate([32, 5, 5-(h+wall+layer_h-FUDGE)])
        magBlank();
    }
  translate([7, 5, 5-(h+wall+layer_h)])
    magnetHolder();
  translate([32, 5, 5-(h+wall+layer_h)])
    magnetHolder();
  }
translate([-20, 0, 0])
  union() {
    difference() {
      cube([40, 10, 5]);
      translate([7, 5, 5-(h+wall+layer_h-FUDGE)])
        magBlank();
      translate([32, 5, 5-(h+wall+layer_h-FUDGE)])
        magBlank();
    }
  translate([7, 5, 5-(h+wall+layer_h)])
    magnetHolder();
  translate([32, 5, 5-(h+wall+layer_h)])
    magnetHolder();
  }

