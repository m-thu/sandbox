// Cap for fence post

$fa = 1;
$fs = 0.4;

// Inner diameter: 39.5 mm
diameter = 39.5;
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
    union() {
        translate([0,0,height/2]) resize([diameter+thickness,diameter+thickness,2*top]) sphere(d=diameter+thickness);
        cylinder(h=height, d=diameter+thickness, center=true);
    }
    cylinder(h=height+2*eps, d=diameter, center=true);
}
