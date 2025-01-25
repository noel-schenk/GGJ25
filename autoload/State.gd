extends Node

var SaveFile = "user://save/state.json";

@export var state = {}

func _ready() -> void:
	# read the state from the file
	if FileAccess.file_exists(SaveFile):
		var file = FileAccess.open(SaveFile, FileAccess.READ)
		state = JSON.new().parse(file.get_as_text())
		file.close()
	else:
		state = {
			"currentLevel": "res://levels/leveltutorial/leveltutorial.tscn",
			"wizardSkillLevel": 1,
			"knightSkillLevel": 0,
		}

func save():
	var file = FileAccess.open(SaveFile, FileAccess.WRITE)
	file.store_string(JSON.new().print(state))
	file.close()

func setCurrentLevel(level):
	state["currentLevel"] = level

func getCurrentLevel():
	return state["currentLevel"]

func getWizardSkillLevel():
	return state["wizardSkillLevel"]

func setWizardSkillLevel(level: int):
	state["wizardSkillLevel"] = level

func getKnightSkillLevel():
	return state["knightSkillLevel"]

func setKnightSkillLevel(level: int):
	state["knightSkillLevel"] = level