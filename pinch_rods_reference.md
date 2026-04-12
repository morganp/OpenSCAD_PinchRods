# Pinch Rods - Design Reference

## What Are Pinch Rods?

Pinch rods are a woodworking measuring tool used to check whether a box, cabinet, or carcase is square. They consist of two thin rods with pointed ends that overlap and slide past each other. The user nestles the pointed ends into opposite diagonal corners of an assembly, locks the rods in place, then checks that the same length fits the other diagonal. Equal diagonals = square assembly.

They are also used to transfer interior dimensions directly to a workpiece without reading a number off a tape measure.

## How They Work

```
  corner A ◄────────────────────────── rod 1 tip
                        ┌──────┐
            ════════════╪══════╪════════════
            ════════════╪══════╪════════════
                        │clamp │
            ════════════╪══════╪════════════
            ════════════╪══════╪════════════
                        └──────┘
  rod 2 tip ──────────────────────────► corner B
```

1. Extend rods to span one diagonal corner to corner
2. Lock the thumbscrew at the crossing/guide point
3. Rotate 90 degrees and check the other diagonal - it should fit snugly
4. Adjust the box if needed (clamp across the longer diagonal), recheck

## Design Variants

### Traditional / Home-Center (2013 Lost Art Press)
- Two thin wood sticks: ~5/16" x 5/8" x 30" (8mm x 16mm x 760mm)
- Cross-section slides through a steel square tube sleeve (3/4" tube, 7/8" long)
- One sleeve per rod; thumbscrew is 1/4-20 tapped into the steel tube
- Pointed ends whittled or sanded to fit into corners
- Very low cost (~$12/set in hardware)

### Crucible Tool (brass hardware, 2020)
- Wood rods supplied by user, brass hardware clamps onto them
- Two square brass blocks - one has a knurled thumbscrew on top, one is fixed
- Thumbscrew has a concentrated point tip that digs slightly into the wood to lock positively (won't slip even if dropped)
- Blocks slide along the rods; lock one block, slide other rod to fit
- Based on an antique design from Roy Underhill's shop
- Hardware sells for ~$48; wood replaced by user if ever worn out

### All-Metal Prototype (2025, Machine Time / Craig Jackson)
- Both rods are 1/4" keystock (square metal bar stock)
- Standard kit: two 12" rods; users can buy 36" keystock separately for larger work
- Beveled ends at approximately 60 degrees to seat snugly in corners
- Central clamp/slider mechanism locks the two rods relative to each other
- Moving away from brass to reduce cost; all-metal construction
- Expected release: Summer 2025

## Key Geometry Principles

- **Rods overlap** in the middle - they do not butt end-to-end
- **The guide/clamp straddles both rods** where they cross, allowing one or both to slide
- **One rod locks**, the other slides to set total length, then the sliding rod locks too
- **Pointed or beveled ends** are essential - they self-locate in square corners
- **Flat/rectangular cross-section** rods are traditional (resist twist better than round)
- Length range: typically 12"-36" working range depending on overlap amount

## Use Cases

1. Checking carcases and boxes for square during glue-up (primary use)
2. Squaring an out-of-square assembly by clamping across the longer diagonal
3. Transferring interior measurements directly (set to fit, carry to workpiece, mark)

## Notes for 3D Printed Design

- The guide blocks must allow both rods to pass through with minimal slop
- One guide locks with a thumbscrew (M5 works well); the second guide can be fixed or also lockable
- The thumbscrew should press against the rod face grain, not the edge, for best grip
- A small standoff or boss to house the threaded insert improves thread engagement
- Chamfered screw holes in the guide base allow screwing the guide to the stock if desired
- Print in orientation that puts layer lines along the length of the guide for strength
- Rod cross-section in current SCAD: 19mm x 19mm (3/4" square stock)
