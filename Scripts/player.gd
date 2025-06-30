extends CharacterBody3D

@onready var Head = $Head

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MOUSE_SENS = 0.4

var bullet = load("res://Scenes/BloodBullet.tscn")
@onready var Pos = $Head/BulletSpawn

@onready var BloodMeterBar = $PlayerGUI/BloodMeter/ProgressBar
@onready var BloodMeterAmount = $PlayerGUI/BloodMeter/BloodAmount
@onready var KillAmount = $PlayerGUI/KillAmount

@onready var BloodBulletShot = $BloodBulletShot

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
			print("set CAPTURED")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			print("set VISIBLE")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		print(get_gravity())
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

	# Shoot bullet
	if Input.is_action_just_pressed("click"):
		if Global.blood == 0:
			return
		var instance = bullet.instantiate()
		instance.position = Pos.global_position
		instance.transform.basis = Pos.global_transform.basis
		get_parent().add_child(instance)
		BloodBulletShot.play()
		Global.blood -= 1
		if Global.blood == 0:
			gameOver()
		updateBloodMeterGUI()
	
	# Update the kill count GUI
	if KillAmount.text != str(Global.kills):
		KillAmount.text = str(Global.kills)
	

func updateBloodMeterGUI():
	var bloodPercent = float(Global.blood) / float(Global.MAX_BLOOD)
	BloodMeterBar.value = bloodPercent
	BloodMeterAmount.text = str(Global.blood)

func gameOver():
	print_debug("gameover")
	# TODO
