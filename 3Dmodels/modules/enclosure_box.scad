// ----------------------------------------------------------------------------------
include<printer_limits.scad>
// ----------------------------------------------------------------------------------
function enclosure_close_box_lid_rotate_ang(draw_as_close_box=false) =
  (draw_as_close_box) ?
    ([0, 0, 0])
  : ([180, 0, 0]);

function enclosure_close_box_lid_translate_xyz(draw_as_close_box=false, length=50, width=40, height=15, xy_wall_width=ptr_wall_width, z_wall_width=z_dim_adj(1), tolerance=ptr_tolerance) =
  (draw_as_close_box) ?
    ([0, 0, 2*z_wall_width+height+tolerance])
  : ([0, 1, 0]);

// ----------------------------------------------------------------------------------
module enclosure_box(
  length=50,
  width=40,
  height=15,
  lid_height=5,
  xy_wall_width=ptr_wall_width,
  z_wall_width=z_dim_adj(1),
  fitted_lid=true,
  draw_lid=false,
  draw_container=false,
  xy_screws=false,
  xy_screws_hide=false,
  bottom_clearance=1,
  bottom_connectors=false,
  lid_connectors=false,
  tolerance=0.0
)
{
  echo("+Enclosure box");
  
  // Bottom
  if(draw_container) {
    difference() {
      cube([length+2*xy_wall_width, width+2*xy_wall_width, height+z_wall_width]);
      union() {
        difference() {
          translate([xy_wall_width, xy_wall_width, z_wall_width])
            cube([length, width, height+z_wall_width]);
            if(xy_screws_hide && xy_screws_hide[1]>0)
              for(xy = xy_screws[1]) {
                translate([xy[0], xy[1], xy_screws_hide[1]/2+z_wall_width])
                  cube([xy_screws_hide[0]+2*xy_wall_width, xy_screws_hide[0]+2*xy_wall_width, xy_screws_hide[1]], center=true);
              }
        }
        if(xy_screws) {
          for(xy = xy_screws[1]) {
            translate([xy[0], xy[1], 0])
              cylinder(h=3*z_wall_width, d=xy_screws[0], $fn=50, center=true);
          }
        }
        if(xy_screws_hide) {
          h = abs(xy_screws_hide[1])+2*z_wall_width;
          offset = (xy_screws_hide[1] < 0) ? (h/2 + z_wall_width + xy_screws_hide[1]) : (xy_screws_hide[1]/2+2*z_wall_width);
          for(xy = xy_screws[1]) {
            translate([xy[0], xy[1], offset])
              cylinder(h=h, d=xy_screws_hide[0], $fn=50, center=true);
          }
        }
        if(bottom_connectors) {
          for(conn = bottom_connectors) {
            x_off = conn[0][0];
            y_off = conn[0][1];
            
            x_trans = (x_off > 0 ) ? (x_off+xy_wall_width) : ( (x_off==-1)?(-xy_wall_width):(length) );
            x_len = (y_off < 0) ? (conn[1]) : (3*xy_wall_width);
            
            y_trans = (y_off > 0 ) ? (y_off+xy_wall_width) : ( (y_off==-1)?(-xy_wall_width):(width) );
            y_len = (x_off < 0) ? (conn[1]) : (3*xy_wall_width);
            
            translate([x_trans, y_trans, z_wall_width+bottom_clearance])
              cube([x_len, y_len, height+z_wall_width]);
          }
        }
      }
    }
  }
  
  // Lid
  if(draw_lid) {
    mirror([0, 0, 1])
    difference() {
      if(fitted_lid) {
        cube([length+2*xy_wall_width, width+2*xy_wall_width, lid_height+z_wall_width]);
      }
      else {
        translate([-xy_wall_width, -xy_wall_width, 0])
          cube([length+4*xy_wall_width, width+4*xy_wall_width, lid_height+z_wall_width]);
      }
      
      if(fitted_lid) {
        difference() {
          translate([-xy_wall_width, -xy_wall_width, z_wall_width])
            cube([length+4*xy_wall_width, width+4*xy_wall_width, lid_height+2*z_wall_width]);
          translate([xy_wall_width, xy_wall_width, z_wall_width])
            cube([length, width, height+z_wall_width]);
      }
      translate([2*xy_wall_width, 2*xy_wall_width, z_wall_width])
        cube([length-2*xy_wall_width, width-2*xy_wall_width, height+z_wall_width]);
      }
      else {
        translate([0, 0, z_wall_width])
          cube([length+2*xy_wall_width, width+2*xy_wall_width, lid_height+2*z_wall_width]);
      }
      
      if(lid_connectors) {
        for(conn = lid_connectors) {
          x_off = conn[0][0];
          y_off = conn[0][1];
          z_off = conn[0][2];
          
          x_trans = (x_off > 0 ) ? ( (y_off<0)?(x_off+xy_wall_width):(x_off-0.01) ) : ( (x_off==-1)?(-xy_wall_width):(length-xy_wall_width) );
          x_len = (y_off < 0) ? (conn[1]) : ( (x_off>0)?(conn[1]+0.01):(4*xy_wall_width) );
          
          y_trans = (y_off > 0 ) ? ( (x_off<0)?(y_off+xy_wall_width):(y_off-0.01) ) : ( (y_off==-1)?(-xy_wall_width):(width-xy_wall_width) );
          y_len = (x_off < 0) ? (conn[1]) : ( (y_off>0)?(conn[2]+0.01):(4*xy_wall_width) );
          
          translate([x_trans, y_trans, z_off])
            cube([x_len, y_len, height+z_wall_width]);
        }
      }
    }
  }
}
// ----------------------------------------------------------------------------------
if(false) {
  enclosure_box(draw_container=true);
  rotate(enclosure_close_box_lid_rotate_ang(false))
    translate(enclosure_close_box_lid_translate_xyz(false))
      enclosure_box(draw_lid=true, fitted_lid=true);
}
// ----------------------------------------------------------------------------------
