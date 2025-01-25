shader_type canvas_item;

uniform vec3 color: source_color  = vec3(1.0, 1.0, 1.0);
uniform vec3 specular_color: source_color  = vec3(1.0, 1.0, 1.0);
uniform float min_transparency: hint_range(0.0, 1.0, 0.1) = 0.1;

uniform float bubble_size = 64.0;
uniform float border = 0.15;
uniform float grow_border = 0.1;
uniform float grow_time :hint_range(0.0, 1.0, 0.05) = 1.0;


const vec2[16] index_map = vec2[16](
	vec2(0.0, 0.0),
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(1.0, 1.0),
	vec2(2.0, 0.0),
	vec2(3.0, 0.0),
	vec2(2.0, 1.0),
	vec2(3.0, 1.0),
	vec2(0.0, 2.0),
	vec2(1.0, 2.0),
	vec2(0.0, 3.0),
	vec2(1.0, 3.0),
	vec2(2.0, 2.0),
	vec2(3.0, 2.0),
	vec2(2.0, 3.0),
	vec2(3.0, 3.0)
);

float ease_in(float t) {
	return t * t;
}

float get_z(float x, float y) {
	return sqrt(1.0 - x * x - y * y);
}

vec4 get_bubble(
	vec2 uv, 
	float l_squish_time,
	vec3 l_squish_origin,
	float l_grow_time,
	vec3 l_grow_origin,
	float l_pop_time,
	vec3 l_color,
	vec3 l_specular_color,
	float l_min_transparency,
	sampler2D noise_texture
) {
	if (l_grow_time == 0.0) return vec4(0.0, 0.0, 0.0, -1.0);
	vec2 position = uv;
	position -= vec2(0.5, 0.5);
	position *= 3.0 - 0.5 * l_squish_time;
	position *= 1.0 - 0.3 * l_pop_time;
	position += normalize(l_squish_origin.xy) * l_squish_time * 0.5;
	
	float denorm_growth = pow((1.0 - l_grow_time), 2.0) * 10.0;
	vec3 bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	float squish_distance = distance(position, l_squish_origin.xy);
	
	vec2 old_position = position;
	
	position = position + l_squish_time * l_squish_origin.xy * (1.0 - squish_distance);
	if (length(position) > 1.0) return vec4(0.0, 0.0, 0.0, -1.0);
	float position_change = distance(old_position, position);
	
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	float growth = distance(bubble_pos, l_grow_origin) + distance(position.xy, l_grow_origin.xy);
	position = position - denorm_growth * growth * (l_grow_origin.xy - position);
	if (length(position) > 1.0) return vec4(0.0, 0.0, 0.0, -1.0);
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	
	vec2 tex_coords = vec2(dot(vec3(1.0, 0.0, 0.0), bubble_pos), dot(vec3(0.0, 1.0, 0.0), bubble_pos));
	float orig_tex_scale = length(tex_coords);
	float tex_scale = pow(orig_tex_scale, 1.0);
	tex_coords = vec2(tex_coords.x * tex_scale * pow(l_grow_time, 2.0), tex_coords.y * tex_scale * pow(l_grow_time, 2.0));
	vec4 new_color = texture(noise_texture, tex_coords/2.0 + vec2(0.5, 0.5));
	
	float center_distance = length(position);
	
	vec3 view_dir = vec3(0.0, 0.0, -1.0);
	float border_size_change = (1.0 + pow(position_change, 2.0)) / pow(l_grow_time,0.5);
	float projection = -dot(bubble_pos, view_dir);
	
	float pop_width = 0.3 * orig_tex_scale / pow(l_grow_time,0.5);
	float pop_norm = l_pop_time * (1.0 + pop_width) - pop_width;
	float pre_alpha = 1.0;
	float post_alpha = 1.0;
	if (new_color.r <= pop_norm) {
		pre_alpha = 0.0;
		post_alpha = 0.0;
	} 
	if(new_color.r >= pop_norm + pop_width) {
		post_alpha = -1.0;
	}

	if (projection < (0.4 * border_size_change)) { //grow_time
		vec3 mixed_color = mix(l_specular_color, l_color, pow(projection/0.4, 4.0));
		return vec4(mixed_color, pre_alpha);
	} else {
		float specular_one = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular_two = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular = max(specular_one, specular_two);
		if (projection < 0.81 + 0.06 * border_size_change + 0.2 * (1.0 - pow(l_grow_time, 0.5)) && projection > 0.81 - 0.06 * border_size_change + 0.2 * (1.0 - pow(l_grow_time, 0.5))  && specular > 1.0 - (0.06 * border_size_change)) {
			return vec4(l_color, pre_alpha);
		} else {
			if (post_alpha == -1.0) {
				return vec4(l_color, max(0.0, l_min_transparency));
			} else {
				return vec4(l_color, post_alpha);
			}
		}
	}	
}

float my_mod(float x, float y) {
    return x - floor(x / y) * y;
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 foam_color = vec4(0.0, 0.0, 0.0, 0.0);
	bool non_discard = false;
	float max_growth = 0.0;
	float create_grow = clamp((grow_time * (1.0 + grow_border) - UV.x) / grow_border, 0.0, 1.0);
	float border_growth = border;
	border_growth = min(border_growth, UV.x);
	border_growth = min(border_growth, UV.y);
	border_growth = min(border_growth, 1.0 - UV.x);
	border_growth = min(border_growth, 1.0 - UV.y);
	border_growth = border_growth / (border * 0.9); //border 16 and multiply for bug

	for (int i = 0; i < 16; i++) {
		vec2 position = SCREEN_UV / SCREEN_PIXEL_SIZE;
		position += index_map[i] * bubble_size / 4.0;
		float random_index_number = random(vec2(floor(position.x / bubble_size) + index_map[i].x, floor(position.y / bubble_size) + index_map[i].y));
		float current_growth = 0.2 + 0.4 * random_index_number;
		position += (vec2(random(vec2(random_index_number, 0.1)), random(vec2(random_index_number, 0.2))) - 0.5) * (bubble_size / 4.0) * (1.0 - current_growth);
		position = vec2(my_mod(position.x, bubble_size), my_mod(position.y, bubble_size));
		float scaled_growth = current_growth * create_grow * border_growth;
		if (scaled_growth < 0.2) scaled_growth = log(scaled_growth);
		if (scaled_growth < 0.01) scaled_growth = 0.0;
		vec4 bubble_color = get_bubble(
			(position * 0.5 + bubble_size / 4.0) / bubble_size, 0.0, vec3(0.0, 0.0, 0.0), scaled_growth, vec3(0.0, 0.0, 0.0), 0.0, color, specular_color, min_transparency, TEXTURE
		);
		if (bubble_color.a != -1.0) {
			if (max_growth < current_growth) {
				max_growth = current_growth;
				foam_color = bubble_color;
				non_discard = true;
			}
		}
	}
	if (!non_discard) discard;
	COLOR = foam_color;
}
