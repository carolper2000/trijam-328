extends Node

@export var MobScene: PackedScene

@onready var Player = $"../../Player"
@onready var MobTimer = $"MobTimer"

@export var initial_spawn_interval = 2.5
@export var spawn_interval_decrease = 0.8

var previous_kills_checkpoint = 0

# https://docs.godotengine.org/en/stable/getting_started/first_3d_game/05.spawning_mobs.html

func _ready():
	MobTimer.wait_time = initial_spawn_interval

func pause_and_speed_up():
	# Arrêter le timer
	MobTimer.stop()
	# Attendre 5 secondes puis accélérer
	await get_tree().create_timer(5.0).timeout
	# Réduire le temps entre les spawns
	MobTimer.wait_time = max(0.5, initial_spawn_interval - (spawn_interval_decrease * previous_kills_checkpoint))
	MobTimer.start()

func _process(_delta):
	var kills_checkpoint = floor(Global.kills / 10)
	if kills_checkpoint > previous_kills_checkpoint:
		previous_kills_checkpoint = kills_checkpoint
		pause_and_speed_up()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = MobScene.instantiate()

	mob.connect("hit_player", Callable(self, "_on_hit_player"))

	# Choose a random SpawnPoint
	var spawnlocation_count = get_node("../../SpawnsMob").get_child_count()
	var spawn_point_index = randi_range(1, spawnlocation_count)
	# Choose a random spawn point from the available ones
	var mob_spawn_location = get_node("../../SpawnsMob/SpawnLocation" + str(spawn_point_index))

	# We store the reference to the SpawnLocation node.
	# var mob_spawn_location = get_node("../SpawnPath/SpawnLocation")
	# And give it a random offset.
	# mob_spawn_location.progress_ratio = randf()

	# Initialize the mob's position and rotation.
	mob.initialize(mob_spawn_location.position, Player)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_hit_player(enemy: Node3D):
	# Player hit, game over
	print("[GameMgr] Player hit by enemy: %s" % enemy.name)
	enemy.queue_free()
	Global.blood -= 1
	if Global.blood <= 0:
		Player.gameOver()
	Player.updateBloodMeterGUI()
	Player.blink_animation(Color(1,0,0, 0.8), 0.07, 1)
