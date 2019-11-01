//enum movement { move, fall, jump }
//image_alpha = 0;
cell_size = 32;
hcells = ceil(room_width/cell_size);
vcells = ceil(room_height/cell_size);
global.grid_platforms = ds_grid_create(hcells, vcells);
global.grid_waypoints = ds_grid_create(1, 6);
platform_id = 0;
waypoint_id = 0;

// Traverse rows
for (var r0 = 0; r0 < vcells; r0++) {
	
	// Traverse columns
	for (var c0 = 0; c0 < hcells ; c0++) {
        if (place_meeting(c0*cell_size, r0*cell_size, obj_block)
		&& !place_meeting(c0*cell_size, (r0-1)*cell_size, obj_block)
		&& global.grid_platforms[# c0, r0] == 0) {
			// New platform found
			platform_id--;
			ds_grid_set(global.grid_platforms, c0, r0, platform_id);
			
			// Check left move
			var c0_forw = c0;
			var r0_forw = r0;
			var c0_prev = c0;
			var r0_prev = r0;
			for (c0_forw = c0-1; place_meeting(c0_forw*cell_size, r0_forw*cell_size, par_collidable); c0_forw--) {
				if (place_meeting(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_block)) {
					break;	
				}
				
				if (place_meeting(c0_forw*cell_size, r0_forw*cell_size, obj_slope)
				&& instance_place(c0_forw*cell_size, r0_forw*cell_size, obj_slope).image_xscale == -1) {
					r0_forw++;
				}
				
				ds_grid_set(global.grid_platforms, c0_forw, r0_forw, platform_id);
				
				c0_prev = c0_forw;
				r0_prev = r0_forw;
				
				if (place_meeting(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_slope)
				&& instance_place(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_slope).image_xscale == 1) {
					r0_forw--;
				}
			}
			
			// Check right move
			c0_forw = c0;
			r0_forw = r0;
			c0_prev = c0;
			r0_prev = r0;
			for (c0_forw = c0+1; place_meeting(c0_forw*cell_size, r0_forw*cell_size, par_collidable); c0_forw++) {
				if (place_meeting(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_block)) {
					break;
				}
				
				if (place_meeting(c0_forw*cell_size, r0_forw*cell_size, obj_slope)
				&& instance_place(c0_forw*cell_size, r0_forw*cell_size, obj_slope).image_xscale == 1) {
					r0_forw++;
				}
				
				ds_grid_set(global.grid_platforms, c0_forw, r0_forw, platform_id);
				
				c0_prev = c0_forw;
				r0_prev = r0_forw;
				
				if (place_meeting(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_slope)
				&& instance_place(c0_forw*cell_size, (r0_forw-1)*cell_size, obj_slope).image_xscale == -1) {
					r0_forw--;
				}
			}
        }
    }
}

// Source block
for (var r0 = 0; r0 < vcells; r0++) {
	for (var c0 = 0; c0 < hcells; c0++) {
		
		// Destination block
		for (var r1 = 0; r1 < vcells; r1++) {
			for (var c1 = 0; c1 < hcells; c1++) {
				if (global.grid_platforms[# c0, r0] != global.grid_platforms[# c1, r1]
				&& place_meeting(c0*cell_size, r0*cell_size, obj_block) && place_meeting(c1*cell_size, r1*cell_size, obj_block)) {
					var x0 = c0*cell_size+16;
					var y0 = r0*cell_size-1;
					var x1 = c1*cell_size+16;
					var y1 = r1*cell_size-1;
					
					var vsp = -18;
					var grv = 1;
					
					var a = 1/2*grv;
					var b = vsp;
					var c = -(y1-y0);
					
					var imaginary = (b*b-4*a*c) < 0;
					if (imaginary) {
						continue;	
					}
					
					var t = floor(max((-b+sqrt(b*b-4*a*c))/(2*a), (-b-sqrt(b*b-4*a*c))/(2*a)));
					var hsp = (x1-x0)/t;
					
					var ax = c0*cell_size;
					var ay = (r0-1)*cell_size;
					// Huh?
					for (var at = 0; !place_meeting(ax, ay, obj_block) && ax > 0 && ax < room_width && ay > 0 && ay < room_height; at++) {
						vsp += grv;
						ax += hsp;
						ay += vsp;
						
						// Off by one error fix attempt
						/*if (vsp > 0 && place_meeting(ax, ay+1, obj_block)) {
							at++;
							break;
						}*/
					}
					
					if (abs(hsp) <= 8 && vsp >= 0 && at == t) {
						//show_debug_message(string(at)+" "+string(t));
						waypoint_id++;
						ds_grid_resize(global.grid_waypoints, waypoint_id, 6);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 0, c0);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 1, r0);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 2, c1);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 3, r1);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 4, t);
						ds_grid_set(global.grid_waypoints, waypoint_id-1, 5, movement.jump);
					}
				}
			}
		}
	}
}

//var grid_waypoints_copy = ds_grid_create(ds_grid_width(global.grid_waypoints), ds_grid_height(global.grid_waypoints));
//ds_grid_copy(grid_waypoints_copy, global.grid_waypoints);
