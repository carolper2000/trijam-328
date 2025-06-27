extends Node

@onready var SpawnPoint = $"../Floor/SpawnPoint"
var enemy = load("res://Scenes/Enemy.tscn")

# https://docs.godotengine.org/en/stable/getting_started/first_3d_game/05.spawning_mobs.html

func _on_mob_timer_timeout() -> void:
	var mob = enemy.instantiate()
	var mob_spawn_location = SpawnPoint
	
	add_child(mob)
	
	pass # Replace with function body.
