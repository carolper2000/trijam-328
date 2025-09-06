extends CharacterBody3D

@onready var Head = $Head

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MOUSE_SENS = 0.4

var bullet_scene = load("res://Scenes/BloodBullet.tscn")
@onready var end_scene = "res://Scenes/EndScene.tscn"

@onready var Pos = $Head/BulletSpawn

@onready var BloodMeterBar = $PlayerGUI/BloodMeter/ProgressBar
@onready var BloodMeterAmount = $PlayerGUI/BloodMeter/BloodAmount
@onready var KillAmount = $PlayerGUI/KillAmount
@onready var AnimationRect = $PlayerGUI/AnimationRect

@onready var BloodBulletShot = $BloodBulletShot

# == SIGNALS ==

signal bullet_spawned(bullet)

# == GODOT FUNCTIONS ==

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	updateBloodMeterGUI()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * MOUSE_SENS))
		Head.rotate_x(-deg_to_rad(event.relative.y * MOUSE_SENS))
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("mouse_capture_toogle"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			print("MOUSE : CAPTURED")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			print("MOUSE : RELEASE")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		# print(get_gravity())
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Shoot bullet_scene
	if Input.is_action_just_pressed("click"):
		if Global.blood == 0:
			return
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.state = bullet_instance.STATE.SHOT
		bullet_instance.position = Pos.global_position
		bullet_instance.transform.basis = Pos.global_transform.basis

		var parent = get_parent()
		parent.add_child(bullet_instance)
		emit_signal("bullet_spawned", bullet_instance)
		BloodBulletShot.play()
		Global.blood -= 1
		if Global.blood <= 0:
			gameOver()
		updateBloodMeterGUI()
	
	# Update the kill count GUI
	if KillAmount.text != str(Global.kills):
		KillAmount.text = str(Global.kills)

# == METHODS ==

func updateBloodMeterGUI():
	var bloodPercent = float(Global.blood) / float(Global.MAX_BLOOD)
	BloodMeterBar.value = bloodPercent
	BloodMeterAmount.text = str(Global.blood)

func gameOver():
	print_debug("gameover")
	get_tree().change_scene_to_file(end_scene)

func blink_animation(
	color: Color = Color(1,1,1),
	time: float = 0.1,
	count: int = 1):

	print("[Player] Blink player animation")
	AnimationRect.modulate = color

	# set visible
	for i in range(count):
		AnimationRect.visible = true
		await get_tree().create_timer(time).timeout
		AnimationRect.visible = false
		await get_tree().create_timer(time).timeout
	
	AnimationRect.visible = false

func blink_blood_meter(
	color: Color = Color(1,1,1),
	time: float = 0.1,
	count: int = 1):

	# Récupérer le style background correctement
	var style_box = BloodMeterBar.get_theme_stylebox("fill")
	if not style_box:
		print("[Player] Erreur: Pas de style background trouvé")
		return
		
	var initial_color = style_box.bg_color

	print("[Player] Blink blood meter")
	for i in range(count):
		style_box.bg_color = color
		await get_tree().create_timer(time).timeout
		style_box.bg_color = initial_color
		await get_tree().create_timer(time).timeout
