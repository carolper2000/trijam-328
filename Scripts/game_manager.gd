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

	# Choose a random SpawnPoint
	var spawn_point_index = randi_range(1, 4)
	# Choose a random spawn point from the 4 available
	var mob_spawn_location = get_node("../SpawnsMob/SpawnLocation" + str(spawn_point_index))

	# We store the reference to the SpawnLocation node.
	# var mob_spawn_location = get_node("../SpawnPath/SpawnLocation")
	# And give it a random offset.
	# mob_spawn_location.progress_ratio = randf()


	var player_position = Player.position

	# Initialize the mob's position and rotation.
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
