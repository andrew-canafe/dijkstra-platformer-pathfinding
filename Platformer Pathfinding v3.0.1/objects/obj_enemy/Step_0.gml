// Tricky to use
list_unvisited = ds_list_create();
for (var i = 0; i < ds_list_size(global.list_waypoints); i++) {
	ds_list_add(list_unvisited, 1);
}
list_unvisited_size = ds_list_size(list_unvisited);

grid_dijkstras = ds_grid_create(2, list_unvisited_size);
ds_grid_set_region(grid_dijkstras, 0, 0, 0, list_unvisited_size-1, -1);
ds_grid_set_region(grid_dijkstras, 1, 0, 1, list_unvisited_size-1, 10000);

source = current_platform;
target = obj_player.current_platform;
grid_dijkstras[# 1, source] = 0;
vertex = source;

// Still under testing (sometimes misses target)
if (source != target) {
	while (list_unvisited[| target] == 1) {
		var grid_neighbors = global.list_waypoints[| vertex].grid_neighbors;
	
		// Index i is relative to grid_neighbors
		for (var i = 0; i < ds_grid_height(grid_neighbors); i++) {
		
			// Tentative distance
			var length = grid_dijkstras[# 1, vertex] + grid_neighbors[# 1, i];
		
			// Index n is relative to grid_dijkstras
			// Buggy when not last in instance creation order
			var n = grid_neighbors[# 0, i];
			if (/*n >= 0 &&*/ length < grid_dijkstras[# 1, n]) {
				grid_dijkstras[# 0, n] = vertex;
				grid_dijkstras[# 1, n] = length;
			}
		}
	
		list_unvisited[| vertex] = 0;
		list_unvisited_size--;
	
		// Still under testing
		if (list_unvisited_size > 0) {
			var low_index = -1;
			var low_value = 10000;
			for (var j = 0; j < ds_list_size(list_unvisited); j++) {
				if (list_unvisited[| j] == 1 && grid_dijkstras[# 1, j] < low_value) {
					low_index = j;
					low_value = grid_dijkstras[# 1, j];
				}
			}
		
			vertex = low_index;
		}
	}

	vertex = target;
	while (vertex != source) {
		var parent = grid_dijkstras[# 0, vertex];
		
		// Not needed, used only for debugging purposes
		with (global.list_waypoints[| parent]) {
			if (grid_optimal_path == noone) {
				grid_optimal_path = ds_grid_create(3, 1);
			}
		
			grid_optimal_path[# 0, 0] = other.vertex;
			grid_optimal_path[# 1, 0] = other.grid_dijkstras[# 1, other.vertex];
			grid_optimal_path[# 2, 0] = 3;
		}
		
		direct = vertex;
		//global.list_waypoints[| parent]
	
		vertex = parent;
	}
	
	//show_debug_message(string(source)+" "+string(direct));
	var source_id, direct_id, grid_neighbors, grid_neighbors_size, neighbor_y, frame_count, movement_type;
	
	source_id = global.list_waypoints[| source];
	direct_id = global.list_waypoints[| direct];
	grid_neighbors = source_id.grid_neighbors;
	grid_neighbors_size = source_id.grid_neighbors_size;

	neighbor_y = ds_grid_value_y(grid_neighbors, 0, 0, 0, grid_neighbors_size-1, direct);
	//show_debug_message(string(neighbor_y));
	
	frame_count = grid_neighbors[# 1, neighbor_y];
	movement_type = grid_neighbors[# 2, neighbor_y];

	switch (movement_type) {
		case movement.move:
			hsp = msp * sign(direct_id.x-source_id.x);
			/*if (direct_id.x-source_id.x < 0) {
				hsp = -msp;
			} else {
				hsp = msp;
			}*/
			break;
		case movement.fall:
			if (place_meeting(x, y+1, obj_block)) {
				hsp = msp * sign(direct_id.x-source_id.x);
			} else {
				hsp = clamp((direct_id.x-x)/frame_count, -msp, msp);
			}
			break;
		case movement.jump:
			// Still testing
			hsp = clamp((direct_id.x-source_id.x)/frame_count, -msp, msp);
			if (place_meeting(x, y+1, obj_block)) {
				vsp = -jsp;
			} 
			break;
	}
}

vsp += grv;

//show_debug_message(string(hsp));
if (place_meeting(x + hsp, y, obj_block)) {
	while (!place_meeting(x + sign(hsp), y, obj_block)) {
		x += sign(hsp);
	}
	
	hsp = 0;
}

x += hsp;

if (place_meeting(x, y + vsp, obj_block)) {
	while (!place_meeting(x, y + sign(vsp), obj_block)) {
		y += sign(vsp);
	}
	
	vsp = 0;
}

y += vsp

if (position_meeting(x, bbox_bottom+1, obj_block)) {
	current_platform = ds_list_find_index(global.list_waypoints, instance_position(x, bbox_bottom+1, obj_block));
} else if (place_meeting(x, y+1, obj_block)) {
	current_platform = ds_list_find_index(global.list_waypoints, instance_place(x, y+1, obj_block));
}

ds_list_destroy(list_unvisited);
ds_grid_destroy(grid_dijkstras);