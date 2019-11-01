// https://forum.yoyogames.com/index.php?threads/stop-objects-from-stacking-inside-of-each-other-solved.20773/
// Set up
var a, xoff, om, mm, mag;

a = point_direction(x, y, other.x, other.y);    // Get the direction from the colliding object
xoff = lengthdir_x(1, a);                       // Get the offset vector
om = other.mass/mass;                           // Start the fake "physics mass" calculations
mm = mass/other.mass;
mag = sqrt((om*om)+(mm*mm));
om /= mag;
mm /= mag;

// Move the instance out of collision
if (!place_meeting(x-xoff*om, y, obj_block)) {
	x -= xoff*om;
}

// Move the other instance out of the collision
with (other) {
	if (!place_meeting(x+xoff*mm, y, obj_block)) {
		x += xoff*mm;
	}
}