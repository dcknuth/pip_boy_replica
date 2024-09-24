// Pip-Boy lettering

union() {
  translate([0, 0,-0.5])
    cube([75.0,9,1.0], center=true);
  translate([0,0,-0.1])
        scale([.14, .14, 0.01])
          surface(file = "pip-boy_letters.png", center=true, invert=false);
}