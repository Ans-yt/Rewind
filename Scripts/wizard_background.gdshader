shader_type canvas_item;

void fragment() {
	if (distance(COLOR.rgb, vec3(58.0, 64.0, 65.0) / 255.0) < 0.001) {
		COLOR.a = 0.0;
	}
}
