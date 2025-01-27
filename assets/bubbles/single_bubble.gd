@tool
class_name SingleBubble
extends Sprite2D


@export var squish_curve: Curve
@export var squish_anim_time: float = 4.0
@export var squish_origin: Vector3 = Vector3(0.0, -1.0, 0.0):
	set(value):
		squish_origin = value
		update_material("squish_origin", value)
@export var squish = false:
	set(value):
		squish = value
		if value:
			_elapsed_squished_time = 0.0
@export_range(0.0, 1.0, 0.01) var squish_status: float = 0.0

@export var grow_curve: Curve
@export var grow_anim_time: float = 4.0
@export var grow_origin: Vector3 = Vector3(0.0, -1.0, 0.0):
	set(value):
		grow_origin = value
		update_material("grow_origin", value)
@export var grow = false:
	set(value):
		if value:
			pop_status = 0.0
		grow = value
		if value:
			_elapsed_grow_time = 0.0
@export_range(0.0, 1.0, 0.01) var grow_status: float = 1.0:
	set(value):
		grow_status = value
		update_material("grow_time", value)

@export var pop_curve: Curve
@export var pop_anim_time: float = 4.0
@export var pop = false:
	set(value):
		pop = value
		if value:
			_elapsed_pop_time = 0.0
@export_range(0.0, 1.0, 0.01) var pop_status: float = 0.0

@export_color_no_alpha var color: Color = Color(1.0, 1.0, 1.0):
	set(value):
		color = value
		update_material("color", value)
@export_color_no_alpha var specular_color: Color = Color(1.0, 1.0, 1.0):
	set(value):
		specular_color = value
		update_material("specular_color", value)
@export_range(0.0, 1.0, 0.005) var min_transparency: float = 0.1:
	set(value):
		min_transparency = value
		update_material("min_transparency", value)

@export var foam_bubble_size: float = 64.0:
	set(value):
		foam_bubble_size = value
		update_material("bubble_size", value)

var _elapsed_squished_time: float = 0.0
var _elapsed_grow_time: float = 0.0
var _elapsed_pop_time: float = 0.0

func update_material(param_name: String, value: Variant) -> void:
	if material:
		material.set_shader_parameter(param_name, value)

func _ready() -> void:
	update_material("squish_origin", squish_origin)
	update_material("grow_origin", grow_origin)
	update_material("squish_time", 0.0)
	update_material("grow_time", 0.0)


func _process(delta: float) -> void:
	if squish:
		_elapsed_squished_time += delta
		var squished_normalized_time = clamp(_elapsed_squished_time / squish_anim_time, 0.0, 1.0)
		update_material("squish_time", squish_curve.sample(squished_normalized_time))
	else:
		update_material("squish_time", squish_status)

	if grow:
		_elapsed_grow_time += delta
		var grow_normalized_time = clamp(_elapsed_grow_time / grow_anim_time, 0.0, 1.0)
		update_material("grow_time", grow_curve.sample(grow_normalized_time))
	else:
		update_material("grow_time", grow_status)

	if pop:
		_elapsed_pop_time += delta
		var pop_normalized_time = clamp(_elapsed_pop_time / pop_anim_time, 0.0, 1.0)
		update_material("pop_time", pop_curve.sample(pop_normalized_time))
	else:
		update_material("pop_time", pop_status)
