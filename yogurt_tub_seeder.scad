$fn = 128;

epsilon = 0.02;

jar_opening_diameter = 120;      // [50:0.5:120] Yogurt tub opening diameter in mm
insert_clearance = 0.8;         // [0.2:0.1:2] Total diameter clearance for the insert fit
cup_depth = 15;                 // [15:1:80] Depth of the seeder cup in mm
wall_thickness = 3;             // [2:0.5:6] Wall thickness in mm
bottom_thickness = 3;           // [2:0.5:6] Bottom thickness in mm
flange_overlap = 4;             // [2:0.5:12] Radial overlap above the jar opening in mm
flange_thickness = 5.5;         // [2:0.5:8] Minimum flange thickness in mm
taper_per_side = 1;             // [0:0.25:3] Radial taper from top to bottom for easier insertion
bottom_hole_diameter = 3;       // [1.5:0.25:8] Bottom hole diameter in mm
bottom_hole_spacing = 3.5;      // [2.5:0.1:16] Target center spacing between bottom holes in mm
bottom_hole_edge_margin = 1.2;  // [0.5:0.1:8] Solid material kept between holes and the inner wall

outer_top_diameter = jar_opening_diameter - insert_clearance;
outer_bottom_diameter = outer_top_diameter - 2 * taper_per_side;
inner_top_diameter = outer_top_diameter - 2 * wall_thickness;
inner_bottom_diameter = outer_bottom_diameter - 2 * wall_thickness;
flange_outer_diameter = jar_opening_diameter + 2 * flange_overlap;
flange_radial_overhang = (flange_outer_diameter - outer_top_diameter) / 2;
flange_top_flat_thickness = 1;
flange_slope_height = flange_radial_overhang;
effective_flange_thickness = max(flange_thickness, flange_slope_height + flange_top_flat_thickness);
flange_collar_height = effective_flange_thickness - flange_slope_height;
flange_inner_diameter = flange_outer_diameter - 2 * wall_thickness;

assert(outer_bottom_diameter > 0, "Bottom diameter must stay positive.");
assert(inner_top_diameter > 0 && inner_bottom_diameter > 0, "Wall thickness is too large for this diameter.");
assert(cup_depth > bottom_thickness, "Cup depth must be greater than bottom thickness.");
assert(flange_outer_diameter > outer_top_diameter, "Flange must extend beyond the cup body.");
assert(flange_collar_height > 0, "Flange needs a positive top collar height.");
assert(flange_inner_diameter > inner_top_diameter, "Flange inner diameter must flare outward.");
assert(bottom_hole_spacing > bottom_hole_diameter, "Bottom hole spacing must be greater than hole diameter.");

module shell() {
    difference() {
        union() {
            cylinder(h = cup_depth, d1 = outer_bottom_diameter, d2 = outer_top_diameter);
            translate([0, 0, cup_depth])
                cylinder(h = flange_slope_height, d1 = outer_top_diameter, d2 = flange_outer_diameter);
            translate([0, 0, cup_depth + flange_slope_height])
                cylinder(h = flange_collar_height, d = flange_outer_diameter);
        }

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_depth - bottom_thickness + epsilon,
                d1 = inner_bottom_diameter,
                d2 = inner_top_diameter
            );
        translate([0, 0, cup_depth - epsilon])
            cylinder(
                h = flange_slope_height + 2 * epsilon,
                d1 = inner_top_diameter,
                d2 = flange_inner_diameter
            );
        translate([0, 0, cup_depth + flange_slope_height - epsilon])
            cylinder(
                h = flange_collar_height + 2 * epsilon,
                d = flange_inner_diameter
            );
    }
}

module bottom_holes() {
    hole_radius = bottom_hole_diameter / 2;
    max_center_radius = inner_bottom_diameter / 2 - bottom_hole_edge_margin - hole_radius;
    ring_spacing = bottom_hole_spacing;
    ring_count = floor(max_center_radius / ring_spacing);

    if (max_center_radius >= 0) {
        translate([0, 0, -epsilon])
            cylinder(h = bottom_thickness + 2 * epsilon, d = bottom_hole_diameter);

        for (ring = [1 : ring_count]) {
            ring_radius = ring * ring_spacing;
            circumference = 2 * PI * ring_radius;
            hole_count = max(6, floor(circumference / bottom_hole_spacing));
            angle_step = 360 / hole_count;
            angle_offset = (ring % 2) * angle_step / 2;

            for (index = [0 : hole_count - 1]) {
                angle = angle_offset + index * angle_step;
                x = ring_radius * cos(angle);
                y = ring_radius * sin(angle);

                translate([x, y, -epsilon])
                    cylinder(h = bottom_thickness + 2 * epsilon, d = bottom_hole_diameter);
            }
        }
    }
}

module yogurt_tub_seeder() {
    difference() {
        shell();
        bottom_holes();
    }
}

yogurt_tub_seeder();
