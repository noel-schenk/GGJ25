extends Node

var SaveFile = "user://save/state.json";

@export var state = {
}
var singleplayer = false

func _ready() -> void:
	# read the state from the file
	if FileAccess.file_exists(SaveFile):
		var file = FileAccess.open(SaveFile, FileAccess.READ)
		state = JSON.new().parse(file.get_as_text())
		file.close()
	else:
		state = {
			"currentLevel": "res://levels/level0/level0.tscn",
			"wizardSkillLevel": 1,
			"knightSkillLevel": 1,
			"musicMuted": false
		}

func save():
	var file = FileAccess.open(SaveFile, FileAccess.WRITE)
	file.store_string(JSON.new().print(state))
	file.close()

func setCurrentLevel(level):
	state["currentLevel"] = level

func getCurrentLevelId():
	return state["currentLevel"].split("level")[2].replace(".tscn", "").to_int();

func setCurrentLevelId(levelId):
	state["currentLevel"] = "res://levels/level" + str(levelId) + "/level" + str(levelId) + ".tscn"

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
