shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;

void fragment() {
	if (UV.y > progress) {
		if (!reverse){
			discard;
		}
	}
	else if (UV.y != progress && reverse) {
		discard;
	}
}
