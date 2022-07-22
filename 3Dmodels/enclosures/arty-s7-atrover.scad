// ----------------------------------------------------------------------------------
// Print settings:
// - Infill: 15% (or less if bridges OK)
// ----------------------------------------------------------------------------------
include<../modules/printer_limits.scad>
use<../modules/enclosure_box.scad>

include<ZK-5AD(Dual-DC-motor_ctrl).scad>

// ----------------------------------------------------------------------------------
// DIMENSIONS
pcb_tickness = z_dim_adj(1.64);
pcb_top_clearance = 12;
pcb_bottom_clearance = 3.8;
pcb_lid_border_h = 6;

artys7_wall_width = ptr_wall_width;
artys7_bottom_wall_width = z_dim_adj(2);

artys7_screws_hide_offset = z_dim_adj(xy_screw_3mm_hd_h + 3);

artys7_l = 109.16+1;
artys7_w = 87+1;
artys7_h = z_dim_adj(pcb_bottom_clearance + pcb_tickness + pcb_top_clearance + artys7_screws_hide_offset) ;
artys7_board_bt_clearence = z_dim_adj(pcb_bottom_clearance + artys7_screws_hide_offset);
artys7_lid_h = z_dim_adj(pcb_lid_border_h);

// ------------------------------------------
// Screws
artys7_screws_xy = [
  [            3*artys7_wall_width, 3*artys7_wall_width],
  [artys7_l - 1*artys7_wall_width, 3*artys7_wall_width],
  [            3*artys7_wall_width, artys7_w-1*artys7_wall_width],
  [artys7_l - 1*artys7_wall_width, artys7_w-1*artys7_wall_width]
];

// ------------------------------------------
// Connectors - Bottom
artys7_bottom_connectors = [
  // [x_off, y_off], length
  //       |
  // y_off |
  //       |
  //       ---------------------
  //          x_off
  //[ [35, -1], 33 ], // switches
  [ [70, -1], 36 ],  // buttons
  [ [3.5, -2], artys7_l-3.5-artys7_wall_width-1 ],  // PMODs
  [ [-1, 16.5], 11 ],   // DC PWR
  [ [-1, 60], 10.5 ]  // micro-USB
];

// ------------------------------------------
// Connectors - Top
artys7_lid_connectors = [
  [ [37, 0.1+2*artys7_wall_width, -2*artys7_bottom_wall_width], 33+2+36, 25 ],  // switches + buttons (top)
  // [ [11.5, -2, artys7_bottom_wall_width], artys7_l-11.5 ],  // PMODs
  [ [-1, 16.5, artys7_bottom_wall_width], 11 ],  // DC PWR
  //[ [-1, 60, artys7_bottom_wall_width], 10.5 ] // micro-USB
  [ [40, 15, -2*artys7_bottom_wall_width], 70, 60 ],  // Arduino
  [ [2+2*artys7_wall_width, 3+2*artys7_wall_width, -2*artys7_bottom_wall_width], 27, 20 ],  // LEDs
  
  // RST button
  [ [artys7_l-2*artys7_wall_width-5-5, -2, artys7_bottom_wall_width], 10],
  [ [artys7_l-4*artys7_wall_width-0.5, artys7_w-4*artys7_wall_width-1-3, -2*artys7_bottom_wall_width], 10, 12 ],
  
  // PROG Button
  [ [2+2*artys7_wall_width, -2, artys7_bottom_wall_width], 10],
  [ [2+2*artys7_wall_width, artys7_w-4*artys7_wall_width-3, -2*artys7_bottom_wall_width], 10, 12 ],
];
// ------------------------------------------
module artys7_enclosure(
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  draw_as_close_box=false,
  draw_other_enclosures=false,
)
{
  echo("----------------------------------------------------------------------------------------------------------------------------------------------------");
  echo("ARTY-S7 Enclosure");
  if(draw_container || draw_as_close_box ) {
    enclosure_box(
      length=artys7_l, width=artys7_w, height=artys7_h, lid_height=artys7_lid_h,
      xy_wall_width=artys7_wall_width, z_wall_width=artys7_bottom_wall_width,
      fitted_lid=fitted_lid, draw_container=true,
      xy_screws=[xy_screw_3mm_d, artys7_screws_xy],
      xy_screws_hide=[xy_screw_3mm_hd_d, artys7_screws_hide_offset],
      bottom_clearance=artys7_board_bt_clearence+pcb_tickness,
      bottom_connectors=artys7_bottom_connectors,
      tolerance=ptr_tolerance
    );
  }
  if(draw_lid || draw_as_close_box) {
    rotate(enclosure_close_box_lid_rotate_ang(draw_as_close_box))
      translate(enclosure_close_box_lid_translate_xyz(draw_as_close_box=draw_as_close_box, length=artys7_l, width=artys7_w, height=artys7_h, xy_wall_width=artys7_wall_width, z_wall_width=artys7_bottom_wall_width))
        difference() {
          enclosure_box(
            length=artys7_l, width=artys7_w, height=artys7_h, lid_height=artys7_lid_h,
            xy_wall_width=artys7_wall_width, z_wall_width=artys7_bottom_wall_width,
            fitted_lid=fitted_lid, draw_lid=true,
            lid_connectors=artys7_lid_connectors,
            tolerance=ptr_tolerance
          );
          
          // DC motor driver
          translate([2*artys7_wall_width, zk5ad_l+2*artys7_wall_width+30, 0]) {
            rotate([0, 0, -90]) {
              if(draw_other_enclosures) {
                  %zk5ad_enclosure(draw_as_close_box=true);
              }
              translate([zk5ad_l+2*zk5ad_wall_width, 0, 0])
                rotate([0, 0, 90])
                  for(xy = zk5ad_screws_xy) {
                    translate([xy[1], xy[0], 0])
                      cylinder(h=4*artys7_bottom_wall_width, d=xy_screw_3mm_d, $fn=50, center=true);
                  }
            }
          }
        }
  }
}

board_test = false;
difference() {
  union() {
    *artys7_enclosure(draw_as_close_box=true);
    *artys7_enclosure(draw_lid=true, draw_container=true);
    *artys7_enclosure(draw_container=true);
    artys7_enclosure(draw_lid=true);
    if(board_test==true) {
      translate([artys7_wall_width, artys7_wall_width, artys7_bottom_wall_width+artys7_screws_hide_offset]) {
        color("black", 0.3)
          cube([artys7_l/4, artys7_w, pcb_bottom_clearance]);
        translate([0, 0, pcb_bottom_clearance]) {
          color("blue", 0.3)
            cube([artys7_l/4, artys7_w, pcb_tickness]);
          translate([0, 0, pcb_tickness])
            color("gray", 0.5)
              cube([artys7_l/4, artys7_w, pcb_top_clearance]);
        }
      }
    };
  }
  if(board_test) {
    translate([artys7_l/2, -10, -10])
      cube(500);
  }
}
