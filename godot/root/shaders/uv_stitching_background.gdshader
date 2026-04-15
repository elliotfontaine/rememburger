shader_type canvas_item;

uniform float angle;
uniform sampler2D texture_1;
uniform sampler2D texture_2;
uniform float line_distance;
uniform float texture_distance;
uniform float texture_width;
uniform float scroll_speed;
uniform vec4 solid_color : source_color;

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	float max_dim = max(1.0 / pixel_size.x, 1.0 / pixel_size.y);
	vec2 uv = UV * vec2(1.0 / pixel_size.x, 1.0 / pixel_size.y) / max_dim;

	float c = cos(angle);
	float s = sin(angle);
	vec2 real_uv = vec2(uv.x * c + uv.y * s, -uv.x * s + uv.y * c);

	float band = texture_width + line_distance;
	float line_index = floor(real_uv.y / band);
	float line_local_y = fract(real_uv.y / band);

	float selector = step(0.5, fract(line_index * 0.5));
	float scroll_dir = mix(1.0, -1.0, selector);
	float local_x = fract(real_uv.x / (texture_width + texture_distance) + TIME * scroll_speed * scroll_dir);

	vec2 texture_uv = vec2(
		local_x * (texture_distance + texture_width) / texture_width,
		line_local_y * band / texture_width
	);

	float gap_mask = step(texture_uv.x, 1.0) * step(texture_uv.y, 1.0);
	vec4 tex1 = texture(texture_1, texture_uv);
	vec4 tex2 = texture(texture_2, texture_uv);
	vec4 tex_color = mix(tex1, tex2, selector);
	vec4 color = mix(solid_color, tex_color, gap_mask);
	COLOR = mix(solid_color, color, step(0.5, color.a));
}