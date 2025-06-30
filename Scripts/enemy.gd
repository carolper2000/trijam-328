extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 4
# Maximum speed of the mob in meters per second.
@export var max_speed = 8

@export var move_time = 3.0  # Temps de déplacement en secondes
@export var pause_time = 2.0  # Temps de pause en secondes

var timer : float = 0.0
var is_moving : bool = true

func _physics_process(_delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * _delta
	
	# move_and_slide()
	timer += _delta

	if is_moving:
		if timer >= move_time:
			# Arrêt après move_time secondes
			timer = 0.0
			is_moving = false
			velocity = Vector3.ZERO
		move_and_slide()
	else:
		if timer >= pause_time:
			# Reprend le mouvement après pause_time secondes
			timer = 0.0
			is_moving = true
			# Nouvelle direction vers le joueur
			look_at(player_position, Vector3.UP)
			rotate_y(randf_range(-PI / 4, PI / 4))
			var random_speed = randi_range(min_speed, max_speed)
			velocity = Vector3.FORWARD * random_speed
			velocity = velocity.rotated(Vector3.UP, rotation.y)

var player_position

# This function will be called from the Main scene.
func initialize(start_position, player_position_param):
	player_position = player_position_param

	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -30 to 30 degrees
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-deg_to_rad(30), deg_to_rad(30)))
	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func _on_visibility_notifier_screen_exited() -> void:
	queue_free
