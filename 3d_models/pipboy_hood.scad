// Pip-boy hood
$fn = 40;

module l_side(size, length, height) {
  hull() {
    sphere(size);
    translate([0, length, 0])
      sphere(size);
    translate([size/2, length-size/2, height-size])
      sphere(size/2);
  }
}

module r_side(size, length, height) {
  hull() {
    sphere(size);
    translate([0, length, 0])
      sphere(size);
    translate([-size/2, length-size/2, height-size])
      sphere(size/2);
  }
}

module back(size, length, height) {
  hull() {
    sphere(size);
    translate([length, 0, 0])
      sphere(size);
    translate([length-size/2, -size/2, height-size])
      sphere(size/2);
    translate([size/2, -size/2, height-size])
      sphere(size/2);
  }
}

module hood(size, side_len, back_len, height) {
  union() {
    translate([0, side_len, 0])
      back(size, back_len, height);
    l_side(size, side_len, height);
    translate([back_len, 0, 0])
      r_side(size, side_len, height);
  }
}

hood(2.0, 35, 100, 10);
