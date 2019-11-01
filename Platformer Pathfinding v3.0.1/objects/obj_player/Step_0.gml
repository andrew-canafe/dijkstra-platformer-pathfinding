if (keyboard_check(ord("A"))) {
	image_xscale = -1;
	hsp = -msp;
}

else if (keyboard_check(ord("D"))) {
	image_xscale = 1;
	hsp = msp;
}

else {
	hsp = 0;
}

if (keyboard_check(vk_space) && place_meeting(x, y+1, obj_block)) {
	vsp = -jsp;
}

vsp += grv;

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