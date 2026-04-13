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
//   "fastener"  "guide1"  "guide2"  "rod"
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
ROD_PREVIEW_LENGTH = 200;

// Length of the printable rod (adjust to suit your workpiece range)
ROD_PRINT_LENGTH = 300;


// ── Top-level dispatcher ──────────────────────────────────────────────────────
if (MODE == "assembled") {
    assembled();
} else {
    if      (PRINT_PART == "fastener") fastener();
    else if (PRINT_PART == "guide1")  guide1();
    else if (PRINT_PART == "guide2")  guide2();
    else if (PRINT_PART == "rod")     rod();
}


// ── Assembled preview ─────────────────────────────────────────────────────────
// Both guides are centred on the Y axis of the guide() primitive, so we shift
// each by +GUIDE_LENGTH/2 so guide1 sits at Y 0..GUIDE_LENGTH and guide2 sits
// at the far end of the rod span.
//
// Rod tips are on opposite ends of the assembled tool, both bevelled toward the
// shared centreline (Z = guide_height/2 = 14.5 mm):
//   bottom rod - taper at NEAR end, tip points UP   to centreline
//   top    rod - taper at FAR  end, tip points DOWN to centreline

module assembled() {
    // Z extents of the two stacked rods inside the guide opening
    rod_lo_z = guide_height/2 - STOCK_THICKNESS;  // 5 mm   - floor of bottom rod
    rod_hi_z = guide_height/2;                     // 14.5 mm - centreline

    guide_span = ROD_PREVIEW_LENGTH - GUIDE_LENGTH;

    // Guide 1 near end - inverted so its screw hole is at the TOP and secures the TOP rod.
    // Rotate 180 around X (flips Z and Y), then translate back up by guide_height so the
    // opening stays at Z 5..24 (symmetric around guide_height/2) and the rods still pass through.
    translate([0, GUIDE_LENGTH/2, guide_height])
        rotate([180, 0, 0])
            guide1_body();

    // Guide 2 far end
    g2_y = GUIDE_LENGTH/2 + guide_span;
    translate([0, g2_y, 0])
        guide2_body();

    // Fastener seated in guide2 standoff, thread pointing down into the hole.
    // anchor=BOTTOM so Z=0 is the screw tip; knob sits KNOB_THREAD_LEN above.
    // Standoff top = guide_height+2+stand_off_height = 36 mm.
    // Tip at Z=28 gives 8 mm of thread engagement; knob clears standoff by 4 mm.
    translate([0, g2_y, (guide_height + 2 + stand_off_height) - KNOB_THREAD_LEN + 4])
        fastener();

    // Bottom rod: tip at near end, taper points up to centreline
    // Starts 25 mm before guide1's near face (Y=0) so it is visible on both sides.
    color("SaddleBrown", 0.85)
    translate([0, -25, rod_lo_z])
        rod_stick(ROD_PREVIEW_LENGTH + 50, taper_at_start=true);

    // Top rod: tip at far end, taper points down to centreline
    // Starts 20 mm before guide1's near face so it is also visible on both sides.
    color("BurlyWood", 0.85)
    translate([0, -20, rod_hi_z])
        rod_stick(ROD_PREVIEW_LENGTH + 50, taper_at_start=false);
}

// Single pinch rod stick with a 45-degree chisel taper at one end.
// Rod runs Y=0 to Y=length, centred on X=0, Z=0 to Z=STOCK_THICKNESS.
//   taper_at_start=true  : tip at Y=0,      knife-edge at Z=STOCK_THICKNESS (up)
//   taper_at_start=false : tip at Y=length,  knife-edge at Z=0              (down)
// 45 degrees => taper run = STOCK_THICKNESS.
module rod_stick(length, taper_at_start=true) {
    taper_len = STOCK_THICKNESS; // run = rise for 45 deg

    // Straight section
    translate([-STOCK_WIDTH/2, taper_at_start ? taper_len : 0, 0])
        cube([STOCK_WIDTH, length - taper_len, STOCK_THICKNESS]);

    // Tapered section - convex hull of tip line and full cross-section slab
    if (taper_at_start) {
        // Tip at Y=0, knife-edge at top face - points up toward centreline
        hull() {
            translate([-STOCK_WIDTH/2, 0,          STOCK_THICKNESS - 0.01])
                cube([STOCK_WIDTH, 0.01, 0.01]);
            translate([-STOCK_WIDTH/2, taper_len,  0])
                cube([STOCK_WIDTH, 0.01, STOCK_THICKNESS]);
        }
    } else {
        // Tip at Y=length, knife-edge at bottom face - points down toward centreline
        hull() {
            translate([-STOCK_WIDTH/2, length - 0.01,      0])
                cube([STOCK_WIDTH, 0.01, 0.01]);
            translate([-STOCK_WIDTH/2, length - taper_len, 0])
                cube([STOCK_WIDTH, 0.01, STOCK_THICKNESS]);
        }
    }
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
module fastener() {
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

// Printable rod - flat on the build plate (Z=0 to Z=STOCK_THICKNESS).
// Both rods are the same shape; print two and flip one when assembling.
// The 45-degree taper is at Y=0 with the knife-edge at the top face,
// which is the most printable orientation (no overhangs on the taper).
// Adjust ROD_PRINT_LENGTH to suit your workpiece range.
module rod() {
    rod_stick(ROD_PRINT_LENGTH, taper_at_start=true);
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
// TODO Add thread to knob so it mates with the M5 screw in guide2
