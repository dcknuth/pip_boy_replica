// aaa blank with a handle on it to set a board into a tight box
$fn = 100;
use <aaa_battery.scad>;

module clip(l, w, clip_h, wall=1.2, down_slope=false) {
  // set down_slope to true if you want both sides of the clip to
  //  have a 45 deg angle. This could allow printing without support
  union() {
    cube([l, w, wall]);
    translate([l-clip_h, w, wall])
      rotate([90, 0, 0])
        linear_extrude(w)
          if (down_slope) {
            polygon([[-clip_h,0], [clip_h, 0], [0, clip_h], [-clip_h, 0]]);
          } else {
            polygon([[0,0], [clip_h, 0], [0, clip_h], [0, 0]]);
          }
  }
}

module clipBlank(l, w, clip_h, wall=1.2, gap=0.4) {
  FUDGE=0.001;
  translate([FUDGE, -gap, -FUDGE/2])
    cube([l, w+gap*2, wall+FUDGE]);
}

module lipoPocket(d=9.1, w=30.0, h=92.0, wall=1.2, clip_l=27.0,
                  clip_w=15.0) {
  union() {
    difference() {
      hull() {
        cylinder(h=h, d=d+2*wall);
        translate([w-(d-wall), 0, 0])
          cylinder(h=h, d=d+2*wall);
      }
      translate([0, 0, wall])
        hull() {
          cylinder(h=h, d=d);
          translate([w-(d-wall), 0, 0])
            cylinder(h=h, d=d);
        }
      translate([(w-clip_w)/2-(d/2-wall), -(d/2+wall), h-clip_l])
        rotate([90, -90, 180])
          clipBlank(clip_l, clip_w);
    }
    translate([(w-clip_w)/2-(d/2-wall), -(d/2+wall), h-clip_l])
      rotate([90, -90, 180])
        clip(clip_l, clip_w, wall*1.7, down_slope=true);
  }
}

translate([-50, 30, 0])
  clipBlank(30, 15);

translate([-40, 0, 0])
  rotate([90, -90, 180])
    clip(30, 15, 2.0, down_slope=true);

//translate([0, 35, 0])
//  lipoPocket();

module batMount(body_l, aaa_d=10.4, wall=1.2) {
  union() {
    aaaBattery(body_l=body_l, pos_button_h=0.8);
    // wing to far-side cutout
    hull() {
      translate([aaa_d/2-wall, wall-0.2, wall*3])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
      translate([body_l/2.3, wall-0.2, body_l/2])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
      translate([aaa_d/2-wall, wall-0.2, body_l-wall*3])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
    }
    // wing to near-side cutout
    hull() {
      translate([-(aaa_d/2-wall), wall-0.2, body_l/3-wall*2])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
      translate([-body_l/4, wall-0.2, body_l/2-wall*2])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
      translate([-(aaa_d/2-wall), wall-0.2, body_l-(body_l/3+wall*2)])
        rotate([90, 0, 0])
          cylinder(h=wall, d=wall, center=true);
    }
    // wing over far-side cutout
    hull() {
      translate([0, aaa_d/2, wall/2])
        rotate([90, 0, 0])
          cylinder(h=wall*2, d=wall, center=true);
      translate([body_l/2.0, aaa_d/2, body_l/2+wall*2])
        rotate([90, 0, 0])
          cylinder(h=wall*2, d=wall, center=true);
      translate([0, aaa_d/2, body_l-wall/2])
        rotate([90, 0, 0])
          cylinder(h=wall*2, d=wall, center=true);
    }
  }
}

module lipoMount() {
  height = 92.0;
  bat_h = 42.8;
  bat_d = 10.4;
  wall = 1.2;
  lipo_d = 9.1;
  union() {
    translate([0, 0, height/2-bat_h/2])
      batMount(bat_h);
    translate([0, bat_d/2+wall/2+lipo_d/2+wall, 0])
      lipoPocket();
  }
}

lipoMount();
