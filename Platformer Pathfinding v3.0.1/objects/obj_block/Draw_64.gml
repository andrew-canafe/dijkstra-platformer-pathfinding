// Buggy
if (depth != -1000) {
	original_depth = depth;
}

for (var i = 0; i < grid_neighbors_size; i++) {
	switch (grid_neighbors[# 2, i]) {
		case movement.move:
			draw_set_color(c_green);
			//continue;
			break;
		case movement.fall:
			draw_set_color(c_navy);
			//continue;
			break;
		case movement.jump:
			draw_set_color(c_maroon);
			//continue;
			break;
	}
	
	if (position_meeting(mouse_x, mouse_y, id)) {
		draw_set_color(c_white);
		draw_rectangle(x, y, x+cell_size-1, y+cell_size-1, true);
		depth = -1000;
	} else {
		depth = original_depth;
	}
	
	draw_arrow(x+16, y-1, global.list_waypoints[| grid_neighbors[# 0, i]].x+16, global.list_waypoints[| grid_neighbors[# 0, i]].y-1, 10);
	
	draw_set_color(c_white);
	//draw_text((x+global.list_waypoints[| grid_neighbors[# 0, i]].x)/2+12, (y+global.list_waypoints[| grid_neighbors[# 0, i]].y)/2-11, string(grid_neighbors[# 1, i]));
}

/*if (grid_optimal_path != noone) {
	depth = -1000;
	draw_set_color(c_white);
	draw_arrow(x+16, y-1, global.list_waypoints[| grid_optimal_path[# 0, 0]].x+16, global.list_waypoints[| grid_optimal_path[# 0, 0]].y-1, 10);
	ds_grid_destroy(grid_optimal_path);
	grid_optimal_path = noone;
} else {
	depth = original_depth;
}*/

if (global.grid_platforms[# x/32, y/32] != 0) {
	draw_set_color(c_white);
	draw_text(x+6, y+6, string(global.grid_platforms[# x/32, y/32]));
}