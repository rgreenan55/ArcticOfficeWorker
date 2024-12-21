shader_type canvas_item;

void vertex() {
	UV.y += TIME * 0.5;
	UV.x += TIME * 0.25;
}
