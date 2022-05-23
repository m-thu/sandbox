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
standoff_x_dist = length - 4*standoff_diameter;
standoff_y_dist = width - 4*standoff_diameter;
standoff_counterbore = 2.0;
standoff_counterbore_r = 3.0;

// Parallela board mounting holes
parallela_hole_diameter = 3.0;
parallela_hole_x_dist = 83.0 - 2*parallela_hole_diameter;
parallela_hole_y_dist = 51.4 - 2*parallela_hole_diameter;
parallela_counterbore = 2.0;
parallela_counterbore_r = 6.0 / 2;

// Fan mounting holes (rectangular)
fan_hole_diameter = 3.0;
fan_hole_dist = 76.0 - 2*fan_hole_diameter;
fan_counterbore_r = 6.0 / 2;
fan_counterbore = 2.0;

difference() {
    cube([length,width,height], center=true);
    
    union() {
        // Standoff holes
        union() {
            // Screw holes
            translate([standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([-standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            translate([-standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(h=height+2*eps, r=standoff_diameter/2, center=true);
            
            // Counterbore
            translate([standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(r=standoff_counterbore_r, h=standoff_counterbore+eps, $fn=6);
            translate([-standoff_x_dist/2,standoff_y_dist/2,0]) cylinder(r=standoff_counterbore_r, h=standoff_counterbore+eps, $fn=6);
            translate([standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(r=standoff_counterbore_r, h=standoff_counterbore+eps, $fn=6);
            translate([-standoff_x_dist/2,-standoff_y_dist/2,0]) cylinder(r=standoff_counterbore_r, h=standoff_counterbore+eps, $fn=6);
        }
        
        // Parallela board mounting holes
        union() {
            // Screw holes
            translate([parallela_hole_x_dist/2,parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([-parallela_hole_x_dist/2,parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([parallela_hole_x_dist/2,-parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            translate([-parallela_hole_x_dist/2,-parallela_hole_y_dist/2,0]) cylinder(h=height+2*eps, r=parallela_hole_diameter/2, center=true);
            
            // Counterbore
            translate([parallela_hole_x_dist/2,parallela_hole_y_dist/2,-height/2-eps]) cylinder(r=parallela_counterbore_r, h=parallela_counterbore);
            translate([-parallela_hole_x_dist/2,parallela_hole_y_dist/2,-height/2-eps]) cylinder(r=parallela_counterbore_r, h=parallela_counterbore);
            translate([parallela_hole_x_dist/2,-parallela_hole_y_dist/2,-height/2-eps]) cylinder(r=parallela_counterbore_r, h=parallela_counterbore);
            translate([-parallela_hole_x_dist/2,-parallela_hole_y_dist/2,-height/2-eps]) cylinder(r=parallela_counterbore_r, h=parallela_counterbore);
        }
        
        // Fan mounting holes
        union() {
            // Screw holes
            translate([fan_hole_dist/2,fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([-fan_hole_dist/2,fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([fan_hole_dist/2,-fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            translate([-fan_hole_dist/2,-fan_hole_dist/2,0]) cylinder(h=height+2*eps, r=fan_hole_diameter/2, center=true);
            
            // Counterbore
            translate([fan_hole_dist/2,fan_hole_dist/2,-height/2-eps]) cylinder(r=fan_counterbore_r, h=fan_counterbore);
            translate([-fan_hole_dist/2,fan_hole_dist/2,-height/2-eps]) cylinder(r=fan_counterbore_r, h=fan_counterbore);
            translate([fan_hole_dist/2,-fan_hole_dist/2,-height/2-eps]) cylinder(r=fan_counterbore_r, h=fan_counterbore);
            translate([-fan_hole_dist/2,-fan_hole_dist/2,-height/2-eps]) cylinder(r=fan_counterbore_r, h=fan_counterbore);
        }
    }
}