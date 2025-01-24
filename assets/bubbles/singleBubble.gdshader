shader_type canvas_item;

uniform vec3 color = vec3(1.0, 1.0, 1.0);

uniform vec3 grow_origin = vec3(0.0, 1.0, 0.0);
uniform float grow_time :hint_range(0.0, 1.0, 0.05) = 1.0;

uniform vec3 squish_origin = vec3(0.0, 1.0, 0.0);
uniform float squish_time :hint_range(0.0, 1.0, 0.05) = 0.0;

uniform float plop: hint_range(0.0, 1.0, 0.05) = 0.5;

float ease_in(float t) {
	return t * t;
}

float get_z(float x, float y) {
	return sqrt(1.0 - x * x - y * y);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 position = UV;
	position -= vec2(0.5, 0.5);
	position *= 3.0 - 0.5 * squish_time;
	position += normalize(squish_origin.xy) * squish_time * 0.5;
	
	float denorm_growth = pow(((1.0 - grow_time) * 10.0), 2.0);
	vec3 bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	//float growth = distance(bubble_pos, grow_origin) + distance(position.xy, grow_origin.xy);
	//if (growth < denorm_growth) discard;
	float squish_distance = distance(position, squish_origin.xy);
	
	vec2 old_position = position;
	
	position = position + squish_time * squish_origin.xy * (1.0 - squish_distance);
	if (length(position) > 1.0) discard;
	float position_change = distance(old_position, position);
	
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	float growth = distance(bubble_pos, grow_origin) + distance(position.xy, grow_origin.xy);
	position = position - denorm_growth * growth * (grow_origin.xy - position);
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	
	vec4 new_color = texture(TEXTURE, vec2(dot(vec2(1.0, 0.0), position.xy), dot(vec2(0.0, 1.0), vec2(position.xy))));
	
	//if (dent < impact_time) discard;
	
	float center_distance = length(position);
	//if (center_distance > 1.0)  discard;
	
	vec3 view_dir = vec3(0.0, 0.0, -1.0);
	float border_size_change = (1.0 + pow(position_change, 2.0)) / pow(grow_time,2.0);
	float projection = -dot(bubble_pos, view_dir);
	
	float plop_width = 0.2;
	float plop_norm = plop * (1.0 + plop_width) - plop_width;
	float pre_alpha = 1.0;
	float post_alpha = 1.0;
	if (new_color.r <= plop_norm) {
		pre_alpha = 0.0;
		post_alpha = 0.0;
	} 
	if(new_color.r >= plop_norm + plop_width) {
		post_alpha = 0.0;
	}
	
	//if (center_distance > 0.9) discard;
	if (projection < (0.4 * border_size_change)) { //grow_time
		COLOR = vec4(color, pre_alpha);
	} else {
		float specular_one = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular_two = abs(dot(bubble_pos, normalize(vec3(0.5, -0.5, 1.0))));
		float specular = max(specular_one, specular_two);
		if (projection < 0.81 + 0.06 * border_size_change + 0.2 * (1.0 - grow_time) && projection > 0.81 - 0.06 * border_size_change + 0.2 * (1.0 - grow_time)  && specular > 1.0 - (0.06 * border_size_change)) {
			COLOR = vec4(color, pre_alpha);
		} else {
			COLOR = vec4(color, post_alpha);//vec4(color, 0.0);
		}
	}	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
