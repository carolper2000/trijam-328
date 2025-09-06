extends Node2D

@onready var KillAmount = $"GUI/KillAmount"
@onready var main_scene = "res://Scenes/MainScene.tscn"

func _ready():
	KillAmount.text = str(Global.kills) + " kills"

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().change_scene_to_file(main_scene)
