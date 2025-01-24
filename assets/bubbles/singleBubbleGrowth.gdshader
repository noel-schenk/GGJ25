shader_type canvas_item;

uniform vec3 color = vec3(1.0, 1.0, 1.0);
uniform vec3 grow_origin = vec3(0.0, 1.0, 0.0);
uniform float grow_time :hint_range(0.0, 1.0, 0.01) = 1.0;


float get_z(float x, float y) {
	return sqrt(1.0 - x * x - y * y);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 position = UV;
	position -= vec2(0.5, 0.5);
	position *= 2.0;
	
	float denorm_growth = pow(((1.0 - grow_time) * 10.0), 2.0);
	vec3 bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	float growth = distance(bubble_pos, grow_origin) + distance(position.xy, grow_origin.xy);
	position = position - denorm_growth * growth * (grow_origin.xy - position);
	
	bubble_pos = vec3(position.x, position.y, get_z(position.x, position.y));
	//if (dent < impact_time) discard;
	
	float center_distance = length(position);
	if (center_distance > 1.0)  discard;
	
	vec3 view_dir = vec3(0.0, 0.0, -1.0);
	
	float projection = abs(dot(bubble_pos, view_dir));
	if (projection < 0.1) {
		COLOR = vec4(color * 0.0, 0.0);
	} else {
		if (projection < 0.4 / grow_time) {
			COLOR = vec4(color, 1.0);
		} else {
			float specular_one = abs(dot(bubble_pos, normalize(vec3(0.5, -0.7, 1.0))));
			float specular_two = abs(dot(bubble_pos, normalize(vec3(0.7, -0.5, 1.0))));
			float specular = max(specular_one, specular_two);
			if (projection < 0.81 && projection > 0.69 && specular > 0.98) {
				COLOR = vec4(color, 1.0);
			} else {
				COLOR = vec4(color, 0.0);
			}
		}
	}		
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
