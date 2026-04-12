// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
// /Users/morgan/Documents/OpenSCAD/libraries
include <parametric-knob-maker/parametric_knob.scad> 
include <BOSL2/std.scad> 
include <BOSL2/threading.scad> 
include <BOSL2/screws.scad>

 
// threaded_rod(d=8, l=30, pitch=1.25);
// threaded_rod(d=8, l=20, pitch=1.25, bevel1=1, blunt_start1=false);
  //threaded_rod(d=8, l=20, pitch=1.25, lead_in=3,blunt_start1=false);


 //knob_size = 25;
 
 //translate([-knob_size/2, -knob_size/2,0]){
 //  cube([35,35,35]);
 //}

//TODO Add thread to knob
//TODO Add bolt thread to guide 2 for adjuster
//TODO add chamfered screw hole to Guides 1 & 2 for guide secure to stock.


 
 
 //Pinch Rod Body
 STOCK_THICKNESS = 19/2; // mm
 STOCK_WIDTH     = 19; // mm

 WALL_THICKNESS  = 5; // mm
 
 GUIDE_LENGTH    =40; //mm

 //Calculate outside dimensions
 guide_width  =  STOCK_WIDTH     + 2*WALL_THICKNESS ;
 guide_height =  STOCK_THICKNESS*2 + 2*WALL_THICKNESS ;
 
 guide_opening_width = STOCK_WIDTH;
 guide_opening_height = STOCK_THICKNESS*2;
 
 stand_off_height=5;
 
 KNOB_THREAD_LEN = 12;

 //Can only create 3mf 1 mesh at a time
 //fastner();
 //guide1();
 guide2();
 

 //Slider knob
module fastner(){
 union(){
 screw(spec="M5",length=KNOB_THREAD_LEN+1, thread=true, anchor=BOTTOM); 
 translate([0,0,KNOB_THREAD_LEN]){
   knob(10, offset_height=1);
 }
 }
}
 //Place Guide 1
 module guide1(){
 translate([0,-(GUIDE_LENGTH*2),0]){
   difference(){
     guide( guide_width,        GUIDE_LENGTH,  guide_height,          //Outside Dimensions
            guide_opening_width,GUIDE_LENGTH+2,guide_opening_height); //Inside Dimensions
            
      //screw hole
      cylinder(h=WALL_THICKNESS, d=5, center=false, $fn=64);
      
      // The tapered cylinder
      // d1 is the diameter at the bottom (z=0)
      // d2 is the diameter at the top (z=h)
      cylinder(h=2, d1=8, d2=5, center=false, $fn=64);
   }
 }
 }
 
 //Place Guide 2
 //Guide 2 has bolt fitting to secure sliding pinch rods
 //Guide 2 is 2 mm higher with 1mm gap and 1mm membrane for bolt to push against
 
module guide2(){
guide_height_p2 = guide_height+2;
guide_opening_height_p2 = guide_opening_height+2;
 translate([0,GUIDE_LENGTH*2,0]){
 difference(){
   union(){
     guide( guide_width,        GUIDE_LENGTH,  guide_height_p2,          //Outside Dimensions
          guide_opening_width,GUIDE_LENGTH+2,guide_opening_height_p2); //Inside Dimensions
          
      //Bump for extra threads on adjuster   
      //attach(TOP) screw_hole("M5", thread=true, l=12,   anchor=TOP);   
      translate([0,0, guide_height_p2]){
        cylinder(h=stand_off_height, d=10, center=false, $fn=64  ); 
      }
  
  //Clamping membrane 
  // Move to top of cube then down by wall height.
  //Down by 1 mm gap. part is 1mm thick and centred so grows 0.5mm ino the 1mm gap, move down another 0.5mm
      translate([0,0,guide_height_p2-WALL_THICKNESS-1 -0.5]){
       cube([guide_width, GUIDE_LENGTH, 1], center=true);
      }  
          
    }// Union
    translate([0,0, guide_height_p2+stand_off_height]){
      //Screw l goes down    
      screw_hole("M5", thread=true, l=stand_off_height+WALL_THICKNESS, anchor=TOP);      
    }
    //screw hole
    cylinder(h=WALL_THICKNESS, d=5, center=false, $fn=64);
    
    // The tapered cylinder
    // d1 is the diameter at the bottom (z=0)
    // d2 is the diameter at the top (z=h)
    cylinder(h=2, d1=8, d2=5, center=false, $fn=64);
    
    //Thread on top.
    
 }
 
 }
 }
 
 
 module guide(out_width,out_length, out_height, in_width, in_length, in_height){
   translate([0,0,out_height/2]){
     difference(){
       //Create outside of Guide
       cube([out_width,out_length, out_height],center=true); 
   
       //Remove inside of guide
       cube([in_width, in_length, in_height],center=true);
     }
   }
 }
 

//Optional paramters

// hex_knob(
//   knob_height,  15
//   knob_diam,  30
//   screwhead_facetoface, 8 
//   screwhead_depth, 12
//   thru_hole_diam,  4
//   num_grip_cutouts, 20
//   grip_cutout_diam, 4
//   cutout_radius_adj 1
// );
