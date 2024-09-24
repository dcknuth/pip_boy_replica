// Geiger counter base
use <threads_v2p1.scad>;
use <attach_pad.scad>;
use <rotary_encoder.scad>;
use <speaker_grid.scad>;
use <holder.scad>;
use <magnet_holder_tiny.scad>;
use <attach.scad>;

$fn = 100;
FUDGE = 0.01;

board_height = 1.6;
board_y = 70.0;
board_x = 121.0;
pad_size = 9.0;
pad_off_xy = 0.3;
mount_height = 4.5;
mount_dist_x = 111.3;
mount_dist_y = 60.4;
wall_thick = 1.6;
corner_r = 1.0;
bw_gap = 1.5; // gap from edge of board to a case wall
extra_y_gap = 1.0;
width = board_x + bw_gap*2 + wall_thick*2;
depth = board_y + bw_gap*2 + extra_y_gap*2 + wall_thick*2;
echo(depth=depth);
h1 = wall_thick + mount_height + board_height + 30.0;
// v top of circuit board
h2 = wall_thick + mount_height + board_height;
pad_x = pad_size*0.5+pad_off_xy+bw_gap+wall_thick;
pad_y = pad_size*0.5+pad_off_xy+bw_gap+extra_y_gap+wall_thick;
gc_of_win_len = 7.0;      // length of window
// on/off switch window start vvv
gc_on_off_win_x = 94.0 + pad_x; 
gc_of_win_h = 5.0;        // height of window
geiger_beeper_d = 17.0;
gb_x = pad_x + 19.0;
gb_z = h2 + 6.0;
speaker_d = 21.0;
speaker_d_inner = 17.6;
speaker_h = 3.2 + 1.2; //1.2 is the default size of the mount back
speaker_y = board_y*0.85 - speaker_d/2;
speaker_z = h2 + 15.0;
switch_l = 14.6;
switch_w = 9.0;
s1_y = board_y*0.15;
s1_z = switch_w/2 + 19.0;
s2_y = board_y*0.4;
s2_z = switch_w/2 + 13.3;
usbc_d = 3.8;
usbc_w = 9.3 - usbc_d;
usbc_z = h2 + 23.0;
mag_off_x = 10.0;
strap_w = 10.4;
strap_lug = 3.0;

winX = 10.0;
winH = (h1-h2) * 0.6;
n_win = 7;

ThreadOutsideDia = 3.1;
ThreadDepth = 3.5;
ThreadPitch = 0.7;

// rotary encoder info
rencD = 7.2;
rencH = h2 + 20.0;

module window(wx, wh, wall) {
  cube([wx, wall*5, wh]);
}

module base(r, h1, h2, dx, dy, wall, w_of_dx, w_of_x, w_of_h,
            strap_w, strap_lug) {
  difference() {
    union() {
      hull() {
        translate([r, r, 0.0])
          cylinder(h = h1, r = r);
        translate([dx-r, r, 0.0])
          cylinder(h = h1, r = r);
        translate([dx-r, dy-r, 0.0])
          cylinder(h = h1, r = r);
        translate([r, depth-r, 0.0])
          cylinder(h = h1, r = r);
      }
      // strap attachments
      translate([r, 0.2, 0])
        attach(strap_w, strap_lug);
      translate([width-(r+strap_w+1.2*2), 0.2, 0])
        attach(strap_w, strap_lug);
      translate([width-r, depth-0.2, 0])
        rotate([0, 0, 180])
          attach(strap_w, strap_lug);
      translate([r+strap_w+1.2*2, depth-0.2, 0])
        rotate([0, 0, 180])
          attach(strap_w, strap_lug);
    }
    hull() {
      translate([r+wall, r+wall, wall])
        cylinder(h = h1, r = r);
      translate([dx-(r+wall), r+wall, wall])
        cylinder(h = h1, r = r);
      translate([dx-(r+wall), dy-(r+wall), wall])
        cylinder(h = h1, r = r);
      translate([r+wall, depth-(r+wall), wall])
        cylinder(h = h1, r = r);
    }
    // USB C port
    translate([gb_x, 0, usbc_z])
      rotate([90, 0, 0])
        hull() {
          cylinder(h=wall*3, d=usbc_d, center=true);
          translate([usbc_w, 0, 0])
            cylinder(h=wall*3, d=usbc_d, center=true);
        }
    // window for the Geiger counter on/off switch
    translate([w_of_dx+w_of_x/2, 0, h2+w_of_h/2])
      cube([w_of_x, wall*3, w_of_h], center=true);
    // hole for device on/off switch
    translate([0, s1_y, h2+s1_z])
      cube([wall*3, switch_l, switch_w], center=true);
    // hole for GC on/off switch
    translate([0, s2_y, h2+s2_z])
      cube([wall*3, switch_w, switch_l], center=true);
    // windows for the Geiger Muller tube
    for (i = [0:1:n_win]) {
      translate([pad_x+pad_size/2 + (2 * i * wall_thick + i * winX),
                dy-(2*r+wall_thick), h2])
        window(winX, winH, wall_thick);
    }
    // rotary encoder hole and tab
    translate([width-(wall+FUDGE), depth*0.58, rencH])
      rotate([0, 90, 0])
        rotaryEncoder();
    // geiger beeper holes
    translate([gb_x, 0, gb_z])
      rotate([90, 0, 0])
        speakerGrid(geiger_beeper_d);
    // speaker holes
    translate([0, speaker_y, speaker_z])
      rotate([0, 90, 0])
        speakerGrid(speaker_d);
    // holes for mag mounts
    translate([mag_off_x, wall-0.1, h1-(4.2-FUDGE)])
      magBlank();
    translate([width-mag_off_x, wall-0.1, h1-(4.2-FUDGE)])
      magBlank();
    translate([width-mag_off_x, depth-(wall-0.1), h1-(4.2-FUDGE)])
      magBlank();
    translate([mag_off_x, depth-(wall-0.1), h1-(4.2-FUDGE)])
      magBlank();
  }
}

union() {
  // base
  base(corner_r, h1, h2, width, depth, wall_thick, gc_on_off_win_x,
        gc_of_win_len, gc_of_win_h, strap_w, strap_lug);
  // hold board in place
  translate([pad_x, pad_y, wall_thick - FUDGE])
    attachPad(mount_height, corner_r, pad_size,
              ThreadOutsideDia, ThreadDepth, ThreadPitch);
  translate([pad_x+mount_dist_x, pad_y, wall_thick - FUDGE])
    attachPad(mount_height, corner_r, pad_size,
              ThreadOutsideDia, ThreadDepth, ThreadPitch);
  translate([pad_x+mount_dist_x, pad_y+mount_dist_y, wall_thick - FUDGE])
    attachPad(mount_height, corner_r, pad_size,
              ThreadOutsideDia, ThreadDepth, ThreadPitch);
  translate([pad_x, pad_y+mount_dist_y, wall_thick - FUDGE])
    attachPad(mount_height, corner_r, pad_size,
              ThreadOutsideDia, ThreadDepth, ThreadPitch);
  // hold speaker in place
  translate([speaker_h + wall_thick + 0.3, speaker_y, speaker_z])
    rotate([90, 0, -90])
      holder(d=speaker_d, h_outer=speaker_h, d_inner=speaker_d_inner);
  // mag mounts
  translate([mag_off_x, wall_thick-0.1, h1-4.2])
    magnetHolder(bottom_taper=true);
  translate([width-mag_off_x, wall_thick-0.1, h1-4.2])
    magnetHolder(bottom_taper=true);
  translate([width-mag_off_x, depth-(wall_thick-0.1), h1-4.2])
    magnetHolder(bottom_taper=true);
  translate([mag_off_x, depth-(wall_thick-0.1), h1-4.2])
    magnetHolder(bottom_taper=true);
}
