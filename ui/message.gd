extends Control

@onready var Headline = $CanvasLayer/MarginContainer/MarginContainer/MarginContainer/Label
@onready var Body = $CanvasLayer/MarginContainer/MarginContainer/MarginContainer2/Label2

@export_multiline var HeadlineText: String = ''
@export_multiline var BodyText: String = ''

func _ready():
	Headline.text = HeadlineText
	Body.text = BodyText
