// Pip-boy case top
use <pipboy_hood.scad>
use <magnet_holder_tiny.scad>
$fn = 100;
FUDGE = 0.01;

wall_thick = 1.6;
lower_wall = 1.2;
mag_off_x = 10.0;
corner_r = 4.0;
xsize = 110.0;
extra_top = corner_r/2;
hood_display_x = xsize + wall_thick*2 + (corner_r-1);
xcase = 126.0;
ysize = 72.0;
ycase = ysize + wall_thick*2 + (corner_r-1) + extra_top;
echo(ycase=ycase);
zsize = 4.0;
hood_size = 19.0;

screenx = 87.9;
screeny = 56.0;
screenz = 4.5;
board_corner_r = 1.0;
led_gap = 6.5;
led_top = 8.1;
screw_holeD = 3.5;
hole_off_screen = 3.5;
hole_off_edge = 2.0;
lightS_x = 1.8; // x from screen
lightS_y = 9.2;  // y from bottom of board/screen
lightS_dx = 4.4;
lightS_dy = 6.0;
lightS_dz = 2.0;

union() {
  difference() {
    union() {
      translate([corner_r, corner_r, zsize+corner_r/2])
        hood(corner_r/2, ycase-2*corner_r, hood_display_x-2*corner_r, hood_size);
      // lettering
      translate([xsize/2+corner_r/1.3, ycase-corner_r*0.8,
                zsize+corner_r/2+hood_size/2])
        rotate([-96, 180, 0])
          scale([1.4, 1.4, 1])
            include <pb_letters.scad>;
      hull() {
        // bottom
        translate([corner_r, corner_r, 0.0])
          cylinder(h = wall_thick, r = corner_r);
        translate([xcase-corner_r, corner_r, 0.0])
          cylinder(h = wall_thick, r = corner_r);
        translate([xcase-corner_r, ycase-corner_r, 0])
          cylinder(h = wall_thick, r = corner_r);
        translate([corner_r, ycase-corner_r, 0])
          cylinder(h = wall_thick, r = corner_r);
        // top
        translate([corner_r, corner_r, zsize])
          sphere(corner_r);
        translate([xcase-corner_r, corner_r, zsize])
          sphere(corner_r);
        translate([xcase-corner_r, ycase-corner_r, zsize])
          sphere(corner_r);
        translate([corner_r, ycase-corner_r, zsize])
          sphere(corner_r);
      }
      // Mode text lines
      translate([hood_display_x+2, 20, (zsize+corner_r)-0.4])
        scale([0.4, 0.4, 1])
          linear_extrude(1)
            text("\u263A");
      translate([hood_display_x-2.0, 28, (zsize+corner_r)-0.4])
        scale([0.25, 0.25, 1])
          linear_extrude(1)
            text("RADS");
      translate([hood_display_x-1.0, 36, (zsize+corner_r)-0.4])
        scale([0.25, 0.25, 1])
          linear_extrude(1)
            text("STAT");
      translate([hood_display_x-2.0, 44, (zsize+corner_r)-0.4])
        scale([0.033, 0.033, 1])
          rotate([0, 0, -45])
            linear_extrude(1)
              import("flashlight.svg", convexity=10);
      translate([hood_display_x-0.2, 50, (zsize+corner_r)-0.4])
        scale([0.031, 0.031, 1])
          linear_extrude(1)
            import("speaker.svg", convexity=10);
    }
    union() {
      translate([hood_display_x/2, ycase/2-extra_top, zsize/2+corner_r/2])
        cube([screenx, screeny, zsize+corner_r+FUDGE], center=true);
      translate([(hood_display_x-xsize)/2, (ycase-ysize)/2-extra_top, -screenz])
        hull() {
          translate([board_corner_r, board_corner_r, 0.0])
            cylinder(h = (zsize+corner_r), r = board_corner_r);
          translate([xcase-(board_corner_r+corner_r+wall_thick),
                    board_corner_r, 0.0])
            cylinder(h = (zsize+corner_r), r = board_corner_r);
          translate([xcase-(board_corner_r+corner_r+wall_thick),
                    ysize + extra_top, 0])
            cylinder(h = (zsize+corner_r), r = board_corner_r);
          translate([board_corner_r, ysize + extra_top, 0])
            cylinder(h = (zsize+corner_r), r = board_corner_r);
        }
      // window for the LED
      translate([(hood_display_x+screenx)/2+(led_gap/2-FUDGE),
                (ycase+screeny)/2-(extra_top+led_gap/2+led_top),
                (zsize+corner_r)-screenz/2])
        cube([led_gap, led_gap, screenz*10], center=true);
      // cutout for light sensor
      translate([(hood_display_x-screenx)/2+screenx+lightS_x,
                (ycase-screeny)/2+lightS_y,
                (zsize+corner_r)-(screenz+FUDGE)])
        cube([lightS_dx, lightS_dy, lightS_dz]);
      // holes for screws
      translate([(hood_display_x/2-screenx/2) - hole_off_screen,
                  ((ycase-screeny)/2-(extra_top-hole_off_edge))+screw_holeD/2,
                  zsize/2+corner_r/2])
        cylinder(h=screenz*10, d=screw_holeD, center=true);
      translate([(hood_display_x/2+screenx/2) + hole_off_screen,
                  ((ycase-screeny)/2-(extra_top-hole_off_edge))+screw_holeD/2,
                  zsize/2+corner_r/2])
        cylinder(h=screenz*10, d=screw_holeD, center=true);
      translate([(hood_display_x/2-screenx/2) - hole_off_screen,
                  ((ycase+screeny)/2-(extra_top+hole_off_edge))-screw_holeD/2,
                  zsize/2+corner_r/2])
        cylinder(h=screenz*10, d=screw_holeD, center=true);
      translate([(hood_display_x/2+screenx/2) + hole_off_screen,
                  ((ycase+screeny)/2-(extra_top+hole_off_edge))-screw_holeD/2,
                  zsize/2+corner_r/2])
        cylinder(h=screenz*10, d=screw_holeD, center=true);
      // holes for mag mounts
      translate([mag_off_x, wall_thick+lower_wall, -FUDGE])
        magBlank();
      translate([xcase-mag_off_x, wall_thick+lower_wall, -FUDGE])
        magBlank();
      translate([xcase-mag_off_x, ycase-(wall_thick+lower_wall), -FUDGE])
        magBlank();
      translate([mag_off_x, ycase-(wall_thick+lower_wall), -FUDGE])
        magBlank();  
    }
  }
  // mag mounts
  translate([mag_off_x, wall_thick+lower_wall, 4.2])
    rotate([180, 0, 0])
      magnetHolder();
  translate([xcase-mag_off_x, wall_thick+lower_wall, 4.2])
    rotate([180, 0, 0])
      magnetHolder();
  translate([xcase-mag_off_x, ycase-(wall_thick+lower_wall), 4.2])
    rotate([180, 0, 0])
      magnetHolder();
  translate([mag_off_x, ycase-(wall_thick+lower_wall), 4.2])
    rotate([180, 0, 0])
      magnetHolder();
}