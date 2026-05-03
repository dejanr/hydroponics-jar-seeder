$fn = 128;

epsilon = 0.02;

jar_opening_diameter = 74;       // [50:0.5:120] Jar opening diameter in mm
insert_clearance = 0.8;         // [0.2:0.1:2] Total diameter clearance for the seeder body fit
wall_thickness = 3;             // [2:0.5:6] Seeder wall thickness in mm
flange_overlap = 4;             // [2:0.5:12] Seeder flange radial overlap in mm
lid_top_thickness = 2.4;        // [1:0.2:5] Light-blocking top thickness in mm
lid_cover_overlap = 1;          // [0:0.2:6] Radial lid overhang beyond the seeder flange in mm
lid_inset_depth = 5;            // [1:0.5:20] Depth of the locating inset under the lid in mm
lid_inset_clearance = 0.6;      // [0.2:0.1:2] Total diameter clearance for the locating inset
lid_inset_wall_thickness = 2;   // [1:0.2:5] Wall thickness of the hollow locating inset
support_rib_count = 4;          // [0:1:8] Number of rib rotations inside the hollow inset
support_rib_width = 2;          // [0.8:0.2:6] Width of each strengthening rib in mm

outer_top_diameter = jar_opening_diameter - insert_clearance;
inner_top_diameter = outer_top_diameter - 2 * wall_thickness;
flange_outer_diameter = jar_opening_diameter + 2 * flange_overlap;
lid_outer_diameter = flange_outer_diameter + 2 * lid_cover_overlap;
lid_inset_outer_diameter = inner_top_diameter - lid_inset_clearance;
lid_inset_inner_diameter = lid_inset_outer_diameter - 2 * lid_inset_wall_thickness;

assert(inner_top_diameter > 0, "Seeder inner diameter must stay positive.");
assert(lid_outer_diameter >= flange_outer_diameter, "Lid must cover the seeder flange.");
assert(lid_inset_outer_diameter > 0, "Inset outer diameter must stay positive.");
assert(lid_inset_inner_diameter > 0, "Inset wall thickness is too large.");
assert(lid_inset_depth > 0, "Inset depth must be positive.");
assert(support_rib_count >= 0, "Support rib count must be non-negative.");
assert(support_rib_width > 0 && support_rib_width < lid_inset_inner_diameter, "Support rib width is out of range.");

module support_ribs() {
    if (support_rib_count > 0) {
        for (index = [0 : support_rib_count - 1]) {
            rotate([0, 0, index * 180 / support_rib_count])
                translate([0, 0, -lid_inset_depth / 2])
                    cube([
                        lid_inset_inner_diameter - support_rib_width,
                        support_rib_width,
                        lid_inset_depth
                    ], center = true);
        }
    }
}

module locating_inset() {
    translate([0, 0, -lid_inset_depth])
        difference() {
            cylinder(h = lid_inset_depth + epsilon, d = lid_inset_outer_diameter);
            translate([0, 0, -epsilon])
                cylinder(h = lid_inset_depth + 3 * epsilon, d = lid_inset_inner_diameter);
        }
}

module germination_lid() {
    union() {
        cylinder(h = lid_top_thickness, d = lid_outer_diameter);
        locating_inset();
        support_ribs();
    }
}

germination_lid();
