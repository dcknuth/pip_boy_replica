// speaker venting holes
// Use with a difference to put holes in a case wall for sound
// Increase the optional density arg for more, smaller holes
//$fn = 20;

// If the distance is less than the radius of the circle, then
//  the point lies inside the circle
function dist(x, y) = sqrt(x*x + y*y);

module speakerGrid(d, density=20, size_mult=1.2, center=true) {
  hole_size = d/density;
  for (y = [-d/2:hole_size*2:d/2]) {
    for (x = [-d/2:hole_size*2:d/2]) {
      if (dist(x, y) < d/2) {
        translate([x, y, 0])
          cylinder(h=d, d=hole_size*size_mult, center=center);
      }
    }
  }
}

speakerGrid(20);
