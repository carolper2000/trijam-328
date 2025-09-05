extends Node

@onready var Player = $"../../Player"
@onready var Pos = Player.get_node("Head/BulletSpawn") 

var bullet_scene = load("res://Scenes/BloodBullet.tscn")

func _ready():
	print("Player name is %s" % Player.name)
	Player.connect("bullet_spawned", Callable(self, "_on_player_bullet_spawned"))

func _on_player_bullet_spawned(bullet):
	bullet.connect("raycasted_with", Callable(self, "_on_bullet_raycasted"))

func _on_bullet_raycasted(bullet: Area3D, target: Node3D):
	# if in group enemy
	print("Bullet raycasted with %s" % target.name)
	if target.is_in_group("enemies"):
		print("Hit an enemy!")
		Global.blood += 20
		# create instance of bullet
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.state = bullet.STATE.FLOATING
		bullet_instance.position = target.global_position
		bullet_instance.transform.basis = target.global_transform.basis

		# Scale to 5
		bullet_instance.scale = Vector3(5, 5, 5)

		var root = Player.get_parent()
		root.add_child(bullet_instance)
		
		# QUEUE FREE
		target.queue_free()

	# ignore player
	if target.name == "Player":
		print("player")
		bullet.queue_free()
