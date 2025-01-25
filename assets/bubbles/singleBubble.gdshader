shader_type canvas_item;

uniform vec3 color: source_color  = vec3(1.0, 1.0, 1.0);
uniform vec3 specular_color: source_color  = vec3(1.0, 1.0, 1.0);
uniform float min_transparency: hint_range(0.0, 1.0, 0.1) = 0.1;

uniform vec3 grow_origin = vec3(0.0, 1.0, 0.0);
uniform float grow_time :hint_range(0.0, 1.0, 0.05) = 1.0;

uniform vec3 squish_origin = vec3(0.0, 1.0, 0.0);
uniform float squish_time :hint_range(0.0, 1.0, 0.05) = 0.0;

uniform float pop_time: hint_range(0.0, 1.0, 0.05) = 0.0;

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
	if (length(position) > 1.0) return vec4(0.0, 0.0, 0.0, 0.0);
	float position_change = distance(old_position, position);
	
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	float growth = distance(bubble_pos, l_grow_origin) + distance(position.xy, l_grow_origin.xy);
	position = position - denorm_growth * growth * (l_grow_origin.xy - position);
	if (length(position) > 1.0) return vec4(0.0, 0.0, 0.0, 0.0);
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
		vec3 mixed_color = mix(l_specular_color, l_color, pow(projection/0.4, 1.0));
		return vec4(mixed_color, pre_alpha);
	} else {
		float specular_one = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular_two = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular = max(specular_one, specular_two);
		if (projection < 0.81 + 0.06 * border_size_change + 0.2 * (1.0 - pow(l_grow_time, 0.5)) && projection > 0.81 - 0.06 * border_size_change + 0.2 * (1.0 - pow(l_grow_time, 0.5))  && specular > 1.0 - (0.06 * border_size_change)) {
			return vec4(l_specular_color, pre_alpha);
		} else {
			if (post_alpha == -1.0) {
				return vec4(l_color, max(post_alpha, l_min_transparency));
			} else {
				return vec4(l_color, post_alpha);
			}
		}
	}	
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 position = UV;
	vec4 bubble_color = get_bubble(
		UV, squish_time, squish_origin, grow_time, grow_origin, pop_time, color, specular_color, min_transparency, TEXTURE
	);
	if (bubble_color.a == 0.0) discard;
	COLOR = bubble_color;
}
