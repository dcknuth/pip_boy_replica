// pip boy knob with a hole to seat closer to case
$fn=100;
FUDGE = 0.001;
collar_w = 0.6;
shaft_d = 6.2;
shaft_w = 2.3;
thread_d = 7.5;
thread_w = 2.6;

difference() {
  import("pip_boy_knob.stl");
  translate([0, 0, -FUDGE]) {
    cylinder(h=thread_w, d=thread_d);
    translate([0, 0, thread_w])
      cylinder(h=collar_w, d1=thread_d, d2=shaft_d);
    translate([0, 0, thread_w+collar_w])
      cylinder(h=shaft_w, d=shaft_d);
  }
}
