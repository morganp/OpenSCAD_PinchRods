// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
// /Users/morgan/Documents/OpenSCAD/libraries
include <parametric-knob-maker/parametric_knob.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/screws.scad>


// ── Display mode ──────────────────────────────────────────────────────────────
//   "assembled" : both guides + two rod sticks shown in working position
//   "print"     : single part laid flat for 3mf export (select with PRINT_PART)
MODE = "assembled";

// Which part to show when MODE = "print"
//   "fastner"  "guide1"  "guide2"
PRINT_PART = "guide2";


// ── Stock / wall dimensions ───────────────────────────────────────────────────
STOCK_THICKNESS = 19/2;  // height of ONE rod - two stack to fill the opening
STOCK_WIDTH     = 19;    // width of each rod

WALL_THICKNESS  = 5;

GUIDE_LENGTH    = 40;

// Calculated outside dimensions
guide_width  = STOCK_WIDTH      + 2*WALL_THICKNESS;
guide_height = STOCK_THICKNESS*2 + 2*WALL_THICKNESS;

guide_opening_width  = STOCK_WIDTH;
guide_opening_height = STOCK_THICKNESS * 2;

stand_off_height = 5;
KNOB_THREAD_LEN  = 12;

// Length of each rod stick shown in assembled preview
ROD_PREVIEW_LENGTH = 250;


// ── Top-level dispatcher ──────────────────────────────────────────────────────
if (MODE == "assembled") {
    assembled();
} else {
    if      (PRINT_PART == "fastner") fastner();
    else if (PRINT_PART == "guide1")  guide1();
    else if (PRINT_PART == "guide2")  guide2();
}


// ── Assembled preview ─────────────────────────────────────────────────────────
// Both guides are centred on the Y axis of the guide() primitive, so we shift
// each by +GUIDE_LENGTH/2 so guide1 sits at Y 0..GUIDE_LENGTH and guide2 sits
// at the far end of the rod span.

module assembled() {
    // Z floor of the rod stack inside guide1 (opening centre = guide_height/2)
    rod_lo_z = guide_height/2 - STOCK_THICKNESS;  // 14.5 - 9.5 = 5 mm
    rod_hi_z = guide_height/2;                     // 14.5 mm - top of bottom rod

    guide_span = ROD_PREVIEW_LENGTH - GUIDE_LENGTH;

    // Guide 1 near end
    translate([0, GUIDE_LENGTH/2, 0])
        guide1_body();

    // Guide 2 far end
    translate([0, GUIDE_LENGTH/2 + guide_span, 0])
        guide2_body();

    // Bottom rod - slightly longer, sticks out past each guide
    color("SaddleBrown", 0.85)
    translate([-STOCK_WIDTH/2, -25, rod_lo_z])
        cube([STOCK_WIDTH, ROD_PREVIEW_LENGTH + 50, STOCK_THICKNESS]);

    // Top rod - offset so the sliding overlap is visible
    color("BurlyWood", 0.85)
    translate([-STOCK_WIDTH/2, 15, rod_hi_z])
        cube([STOCK_WIDTH, ROD_PREVIEW_LENGTH + 15, STOCK_THICKNESS]);
}


// ── Bare guide bodies (no placement translate, used by both modes) ─────────────

module guide1_body() {
    difference() {
        guide(guide_width,        GUIDE_LENGTH,   guide_height,
              guide_opening_width, GUIDE_LENGTH+2, guide_opening_height);
        // countersunk screw hole through bottom wall
        cylinder(h=WALL_THICKNESS, d=5, center=false, $fn=64);
        cylinder(h=2, d1=8, d2=5, center=false, $fn=64);
    }
}

module guide2_body() {
    guide_height_p2         = guide_height + 2;
    guide_opening_height_p2 = guide_opening_height + 2;
    difference() {
        union() {
            guide(guide_width,        GUIDE_LENGTH,   guide_height_p2,
                  guide_opening_width, GUIDE_LENGTH+2, guide_opening_height_p2);

            // Standoff boss for thumbscrew threads
            translate([0, 0, guide_height_p2])
                cylinder(h=stand_off_height, d=10, center=false, $fn=64);

            // Clamping membrane - 1 mm slab just inside the top opening gap
            translate([0, 0, guide_height_p2 - WALL_THICKNESS - 1 - 0.5])
                cube([guide_width, GUIDE_LENGTH, 1], center=true);
        }
        // Threaded M5 hole down through the standoff
        translate([0, 0, guide_height_p2 + stand_off_height])
            screw_hole("M5", thread=true, l=stand_off_height+WALL_THICKNESS, anchor=TOP);
        // Countersunk screw hole through bottom wall
        cylinder(h=WALL_THICKNESS, d=5, center=false, $fn=64);
        cylinder(h=2, d1=8, d2=5, center=false, $fn=64);
    }
}


// ── Individual part modules (print mode) ──────────────────────────────────────

// Slider knob / fastener
module fastner() {
    union() {
        screw(spec="M5", length=KNOB_THREAD_LEN+1, thread=true, anchor=BOTTOM);
        translate([0, 0, KNOB_THREAD_LEN])
            knob(10, offset_height=1);
    }
}

// Guide 1 - offset for print layout
module guide1() {
    translate([0, -(GUIDE_LENGTH*2), 0])
        guide1_body();
}

// Guide 2 - offset for print layout
module guide2() {
    translate([0, GUIDE_LENGTH*2, 0])
        guide2_body();
}


// ── Base guide primitive ──────────────────────────────────────────────────────
module guide(out_width, out_length, out_height, in_width, in_length, in_height) {
    translate([0, 0, out_height/2]) {
        difference() {
            cube([out_width,  out_length,  out_height], center=true);
            cube([in_width,   in_length,   in_height],  center=true);
        }
    }
}


// ── TODO ──────────────────────────────────────────────────────────────────────
// TODO Add thread to knob
// TODO Add bolt thread to guide2 for adjuster
// TODO Add chamfered screw hole to guide1 & guide2 for securing to stock
// TODO Pointed / bevelled rod ends (~60 deg bevel per Crucible / 2025 design)
