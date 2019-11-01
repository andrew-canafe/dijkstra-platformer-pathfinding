var ax = x;
var ay = bbox_bottom;
var temp_hsp = msp * image_xscale;
var temp_vsp = -jsp;

while (!position_meeting(ax, ay, obj_block) && ax > 0 && ax < room_width && ay > 0 && ay < room_height) {
	draw_point(ax, ay);
	temp_vsp += grv;
	ax += temp_hsp;
	ay += temp_vsp;
}