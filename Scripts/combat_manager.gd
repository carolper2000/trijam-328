extends Node

@onready var Player = $"../../Player"
@onready var Pos = Player.get_node("Head/BulletSpawn") 

var bullet_scene = load("res://Scenes/BloodBullet.tscn")

func _ready():
	print("Player name is %s" % Player.name)
	Player.connect("bullet_spawned", Callable(self, "_on_player_bullet_spawned"))

func _on_player_bullet_spawned(bullet):
	print("[CmbMgr] bullet spawned %s" % bullet.name)
	bullet.connect("collided_with", Callable(self, "_on_bullet_collided"))
	bullet.connect("raycasted_with", Callable(self, "_on_bullet_raycasted"))

func _on_bullet_collided(bullet: Area3D, target: Node3D):
	if target.name == "Player" and bullet.state == bullet.STATE.FLOATING:
		print("[CmbMgr] Player hit: %s" % target.name)
		# get blood
		Global.blood += 1
		Player.updateBloodMeterGUI()
		
		# Player UI blink green
		Player.blink_blood_meter(Color(0,1,0, 0.8), 0.05, 5)
		bullet.queue_free()

func _on_bullet_raycasted(bullet: Area3D, target: Node3D):
	# return if not shot
	if bullet.state != bullet.STATE.SHOT: 
		return

	# if in group enemy
	if target.is_in_group("enemies"):
		print("[CmbMgr] Hit enemy: %s" % target.name)
		# create instance of bullet
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.state = bullet.STATE.FLOATING
		bullet_instance.position = target.global_position
		bullet_instance.transform.basis = target.global_transform.basis

		# Scale to 5
		bullet_instance.scale = Vector3(5, 5, 5)

		var root = Player.get_parent()
		root.add_child(bullet_instance)

		# CONNECTER LES SIGNAUX
		bullet_instance.connect("collided_with", Callable(self, "_on_bullet_collided"))
		bullet_instance.connect("raycasted_with", Callable(self, "_on_bullet_raycasted"))
		print("[CmbMgr] Signaux connectés pour nouvelle bullet: %s" % bullet_instance.name)
		
		Global.kills += 1
		# Nettoyer l'enemy
		target.queue_free()
		
	else:
		print("[CmbMgr] Hit something else: %s" % target.name)
		bullet.queue_free()

func _destroy_target_safely(target: Node3D, timer: Timer):
	"""Détruit l'ennemi de façon sécurisée"""
	if is_instance_valid(target):
		target.queue_free()
