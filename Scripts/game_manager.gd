extends Node

@export var MobScene: PackedScene

@onready var Player = $"../Player"

# https://docs.godotengine.org/en/stable/getting_started/first_3d_game/05.spawning_mobs.html

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = MobScene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("../SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
