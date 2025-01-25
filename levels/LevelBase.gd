extends Node2D

@export var WizardStartSkill = 0
@export var KnightStartSkill = 0

@export var NextLevel: int = -1

func _ready() -> void:
	State.setWizardSkillLevel(WizardStartSkill)
	State.setKnightSkillLevel(KnightStartSkill)

func getNextLevelNumber():
	return NextLevel
