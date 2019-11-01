cell_size = 32;
grid_optimal_path = noone;

if (!variable_global_exists("list_waypoints")) {
	global.list_waypoints = ds_list_create();
}

if (!place_meeting(x, y-cell_size, obj_block)) {
	ds_list_add(global.list_waypoints, id);
}