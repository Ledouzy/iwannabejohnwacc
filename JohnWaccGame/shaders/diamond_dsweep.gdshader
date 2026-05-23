shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
//uniform vec2 numberOfTiles = vec2(10, 9);

void fragment() {
	vec2 numberOfTiles = vec2((1./SCREEN_PIXEL_SIZE).x/(16.), (1./SCREEN_PIXEL_SIZE.y)/(16.));
	vec2 positionInSquare = UV * numberOfTiles;
	vec2 frac = fract(positionInSquare);
	vec2 direction = frac - 0.5;
	
	if (abs(direction.x) + abs(direction.y) + UV.x + UV.y > progress * 4.0) {
		if (!reverse){
			discard;
		}
	}
	else if (abs(direction.x) + abs(direction.y) + UV.x + UV.y != 4.0 * progress && reverse) {
		discard;
	}
}
