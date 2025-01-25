extends Node2D

@export var NextLevel: Resource = null

func getNextLevelPath():
	return NextLevel.resource_path
