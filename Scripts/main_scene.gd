extends Node3D

@onready var Player = $"Player"
@onready var main_scene = "res://Scenes/MainScene.tscn"
@onready var end_scene = "res://Scenes/EndScene.tscn"

func _ready() -> void:
	Global.kills = 0
	Global.blood = Global.INITIAL_BLOOD
	
	# FORCER la mise à jour de l'UI du player après réinitialisation
	if Player and Player.has_method("updateBloodMeterGUI"):
		Player.updateBloodMeterGUI()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().change_scene_to_file(main_scene)

	if Input.is_action_just_pressed("mouse_capture_toogle"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			print("MOUSE : CAPTURED")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			print("MOUSE : RELEASE")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
