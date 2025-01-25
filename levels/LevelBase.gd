extends Node2D
class_name LevelBase

@export var WizardStartSkill = 0
@export var KnightStartSkill = 0

@export var NextLevel: Resource = null

func _ready() -> void:
	State.setWizardSkillLevel(WizardStartSkill)
	State.setKnightSkillLevel(KnightStartSkill)

func getNextLevelPath():
	return NextLevel.resource_path
