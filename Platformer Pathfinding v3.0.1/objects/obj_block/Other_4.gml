enum movement { move, fall, jump };

hcells = ceil(room_width/cell_size);
vcells = ceil(room_height/cell_size);
grid_neighbors = ds_grid_create(3, 1);
grid_neighbors_size = 0;

if (!variable_global_exists("grid_platforms")) {
	global.grid_platforms = ds_grid_create(hcells, vcells);
	var platform_id = 0;
	
	// Traverse rows
	for (var r0 = 0; r0 < vcells; r0++) {
		
		// Traverse columns
		for (var c0 = 0; c0 < hcells ; c0++) {
	        if (place_meeting(c0*cell_size, r0*cell_size, obj_block)
			&& !place_meeting(c0*cell_size, (r0-1)*cell_size, obj_block)
			&& global.grid_platforms[# c0, r0] == 0) {
				// New platform found
				platform_id++;
				ds_grid_set(global.grid_platforms, c0, r0, platform_id);
				
				// Check left move
				var c1 = c0;
				var r1 = r0;
				for (c1 = c0-1; place_meeting(c1*cell_size, r1*cell_size, par_collidable); c1--) {
					if (place_meeting(c1*cell_size, (r1-1)*cell_size, obj_block)) {
						break;	
					}
					
					if (place_meeting(c1*cell_size, r1*cell_size, obj_slope)
					&& instance_place(c1*cell_size, r1*cell_size, obj_slope).image_xscale == -1) {
						r1++;
					}
					
					ds_grid_set(global.grid_platforms, c1, r1, platform_id);
					
					if (place_meeting(c1*cell_size, (r1-1)*cell_size, obj_slope)
					&& instance_place(c1*cell_size, (r1-1)*cell_size, obj_slope).image_xscale == 1) {
						r1--;
					}
				}
				
				// Check right move
				c1 = c0;
				r1 = r0;
				for (c1 = c0+1; place_meeting(c1*cell_size, r1*cell_size, par_collidable); c1++) {
					if (place_meeting(c1*cell_size, (r1-1)*cell_size, obj_block)) {
						break;
					}
					
					if (place_meeting(c1*cell_size, r1*cell_size, obj_slope)
					&& instance_place(c1*cell_size, r1*cell_size, obj_slope).image_xscale == 1) {
						r1++;
					}
					
					ds_grid_set(global.grid_platforms, c1, r1, platform_id);
					
					if (place_meeting(c1*cell_size, (r1-1)*cell_size, obj_slope)
					&& instance_place(c1*cell_size, (r1-1)*cell_size, obj_slope).image_xscale == -1) {
						r1--;
					}
				}
	        }
	    }
	}
}

if (!place_meeting(x, y-cell_size, obj_block)) {	
	// Check left move
	if (place_meeting(x-cell_size, y, obj_block) && !place_meeting(x-cell_size, y-cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x-cell_size, y, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	} else if (place_meeting(x-cell_size, y, obj_slope) && place_meeting(x-cell_size, y+cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x-cell_size, y+cell_size, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	} else if (place_meeting(x, y-cell_size, obj_slope) && place_meeting(x-cell_size, y-cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x-cell_size, y-cell_size, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	}
	
	// Check left fall
	else if (!place_meeting(x-cell_size, y, obj_block) && !place_meeting(x-cell_size, y-cell_size, obj_block)) {
		var c0 = x/cell_size-1;
		var r0 = y/cell_size;
		for (var r1 = r0; r1 < vcells; r1++) {
			for (var c1 = c0; c1 >= 0; c1--) {
				if (global.grid_platforms[# c0, r0] != global.grid_platforms[# c1, r1]
				&& global.grid_platforms[# c1, r1] != 0) {
					var x0 = c0*cell_size;
					var y0 = r0*cell_size;
					var x1 = c1*cell_size;
					var y1 = r1*cell_size;
				
					var vsp = 0;
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
					for (var at = 0; collision_rectangle(ax, ay, ax+cell_size-1, ay+cell_size-1, obj_block, false, false) == noone
					&& ax > 0 && ax < room_width && ay > 0 && ay < room_height; at++) {
						vsp += grv;
						ax += hsp;
						ay += vsp;
					}
					
					// One-frame tolerance
					if (abs(hsp) <= 8 && vsp >= 0 && abs(t-at) <= 1) {
						var inst = ds_list_find_index(global.list_waypoints, instance_place(c1*cell_size, r1*cell_size, obj_block));
						show_debug_message(string(hsp)+" "+string((x1-x0)/at));
						grid_neighbors_size++;
						ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
						ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
						ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, t);
						ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.fall);
					}
				}
			}
		}
	}
	
	// Check right move
	if (place_meeting(x+cell_size, y, obj_block) && !place_meeting(x+cell_size, y-cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x+cell_size, y, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	} else if (place_meeting(x+cell_size, y, obj_slope) && place_meeting(x+cell_size, y+cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x+cell_size, y+cell_size, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	} else if (place_meeting(x, y-cell_size, obj_slope) && place_meeting(x+cell_size, y-cell_size, obj_block)) {
		var inst = ds_list_find_index(global.list_waypoints, instance_place(x+cell_size, y-cell_size, obj_block));
		
		grid_neighbors_size++;
		ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
		ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
		ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, 4);
		ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.move);
	}
	
	// Check right fall
	else if (!place_meeting(x+cell_size, y, obj_block) && !place_meeting(x+cell_size, y-cell_size, obj_block)) {
		var c0 = x/cell_size+1;
		var r0 = y/cell_size;
		for (var r1 = r0; r1 < vcells; r1++) {
			for (var c1 = c0; c1 < hcells; c1++) {
				if (global.grid_platforms[# c0, r0] != global.grid_platforms[# c1, r1]
				&& global.grid_platforms[# c1, r1] != 0) {
					var x0 = c0*cell_size;
					var y0 = r0*cell_size;
					var x1 = c1*cell_size;
					var y1 = r1*cell_size;
				
					var vsp = 0;
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
					for (var at = 0; collision_rectangle(ax, ay, ax+cell_size-1, ay+cell_size-1, obj_block, false, false) == noone
					&& ax > 0 && ax < room_width && ay > 0 && ay < room_height; at++) {
						vsp += grv;
						ax += hsp;
						ay += vsp;
					}
				
					// One-frame tolerance
					if (abs(hsp) <= 8 && vsp >= 0 && abs(t-at) <= 1) {
						var inst = ds_list_find_index(global.list_waypoints, instance_place(c1*cell_size, r1*cell_size, obj_block));
					
						grid_neighbors_size++;
						ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
						ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
						ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, t);
						ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.fall);
					}
				}
			}
		}
	}
	
	// Check jump
	var c0 = x/cell_size;
	var r0 = y/cell_size;
	for (var r1 = 0; r1 < vcells; r1++) {
		for (var c1 = 0; c1 < hcells; c1++) {
			if (global.grid_platforms[# c0, r0] != global.grid_platforms[# c1, r1]
			/*&& global.grid_platforms[# c0, r0] != 0*/ && global.grid_platforms[# c1, r1] != 0) {
				var x0 = c0*cell_size;
				var y0 = r0*cell_size;
				var x1 = c1*cell_size;
				var y1 = r1*cell_size;
				
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
				for (var at = 0; collision_rectangle(ax, ay, ax+cell_size-1, ay+cell_size-1, obj_block, false, false) == noone
				&& ax > 0 && ax < room_width && ay < room_height; at++) {
					vsp += grv;
					ax += hsp;
					ay += vsp;
				}
				
				// One-frame tolerance
				if (abs(hsp) <= 8 && vsp >= 0 && abs(t-at) <= 1) {
					var inst = ds_list_find_index(global.list_waypoints, instance_place(c1*cell_size, r1*cell_size, obj_block));
					
					grid_neighbors_size++;
					ds_grid_resize(grid_neighbors, 3, grid_neighbors_size);
					ds_grid_set(grid_neighbors, 0, grid_neighbors_size-1, inst);
					ds_grid_set(grid_neighbors, 1, grid_neighbors_size-1, t);
					ds_grid_set(grid_neighbors, 2, grid_neighbors_size-1, movement.jump);
				}
			}
		}
	}
}