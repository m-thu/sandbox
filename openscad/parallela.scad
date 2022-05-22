// Baseplate for Parallela board with fan

$fa = 1;
$fs = 0.4;

eps = 0.01;

// Dimensions rectangular plate
// with standoff holes
length = 110.0;
width  = 95.0;
height =  4.0;
standoff_diameter = 3.0;
standoff_x_dist = length - 2*standoff_diameter;
standoff_y_dist = width - 2*standoff_diameter;

// Parallela board mounting holes
parallela_hole_diameter = 3.0;
parallela_hole_x_dist = 83.0 - 2*parallela_hole_diameter;
parallela_hole_y_dist = 51.4 - 2*parallela_hole_diameter;

// Fan mounting holes (rectangular)
fan_hole_diameter = 4.0;
fan_hole_dist = 76.0 - 2*fan_hole_diameter;

difference() {
    cube([length,width,height], center=true);
    
    union() {
        // Standoff holes
        union() {
            translate([standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([-standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([-standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
        }
        
        // Parallela board mounting holes
        union() {
            translate([parallela_hole_x_dist/2,parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([-parallela_hole_x_dist/2,parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([parallela_hole_x_dist/2,-parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([-parallela_hole_x_dist/2,-parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
        }
        
        // Fan mounting holes
        union() {
            translate([fan_hole_dist/2,fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([-fan_hole_dist/2,fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([fan_hole_dist/2,-fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([-fan_hole_dist/2,-fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
        }
    }
}