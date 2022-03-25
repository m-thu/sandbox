// Cap for fence post
// V2: reduced inner diameter by 1 mm

$fa = 1;
$fs = 0.4;

// Inner diameter: 38.5 mm
diameter = 38.5;
// Thickness cap: 2 mm
thickness = 2;
// Height of cylinder part: 22 mm
height = 22;
// Height of top part: 3.4 mm
top = 3.4;

eps = 0.01;

// Rotate for printing
rotate([180,0,0])
difference() {
    cylinder(h=height+top, d=diameter+thickness);
    translate([0,0,-eps]) cylinder(h=height+2*eps, d=diameter);
}
