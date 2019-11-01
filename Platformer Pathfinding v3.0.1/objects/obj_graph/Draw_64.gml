/*for (var i = 0; i < hcells ; i++) {
    for (var j = 0; j < vcells; j++) {
		draw_text(i*cell_size+8, j*cell_size+8, string(global.grid_platforms[# i, j]));
    }
}*/

for (var i = 0; i < waypoint_id; i++) {
	var a = global.grid_waypoints[# i, 0];
	var b = global.grid_waypoints[# i, 1];
	var c = global.grid_waypoints[# i, 2];
	var d = global.grid_waypoints[# i, 3];
	var e = global.grid_waypoints[# i, 4];
	var f = global.grid_waypoints[# i, 5];

	draw_line(a*cell_size+16, b*cell_size-1, c*cell_size+16, d*cell_size-1);
	draw_text((a+c)/2*cell_size+8, (b+d)/2*cell_size-8, string(e));
}