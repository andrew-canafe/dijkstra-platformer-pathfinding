current_platform = -1;
for (var i = 0; i < room_height; i++) {
	if (position_meeting(x, bbox_bottom+i+1, obj_block)) {
		current_platform = ds_list_find_index(global.list_waypoints, instance_position(x, bbox_bottom+i+1, obj_block));
		break;
	} else if (place_meeting(x, y+i+1, obj_block)) {
		current_platform = ds_list_find_index(global.list_waypoints, instance_place(x, y+i+1, obj_block));
		break;
	}
}