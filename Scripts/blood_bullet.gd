extends Area3D

var speed=220
var last_position: Vector3
var initial_position: Vector3

@export var state: STATE = STATE.DEFAULT
var previous_collider:Object = null

signal raycasted_with(bullet: Area3D, target: Node3D)
signal collided_with(bullet: Area3D, target: Node3D)

enum STATE
{
	DEFAULT,
	SHOT,
	FLOATING,
};

func _ready():
	last_position = global_position
	initial_position = global_position

	# on body entered
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	var new_position = global_position
	
	# == STATES ==
	if state == STATE.SHOT:
		new_position = global_position + transform.basis.z * -speed * delta

	if state == STATE.FLOATING:
		new_position = global_position
		new_position.y = initial_position.y + 1.0 + 0.5 * sin(Time.get_ticks_msec() / 2000.0 * PI)

	# == RAYCAST + COLLIDER ==
	# Calculer le déplacement total pour ce frame
	var movement_vector = transform.basis.z * -speed * delta
	var target_position = last_position + movement_vector
	var query = PhysicsRayQueryParameters3D.create(last_position, target_position)

	# == RESULT ==
	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		var current_collider = result["collider"]
		if current_collider != previous_collider:
			emit_signal("raycasted_with", self, current_collider)
		previous_collider = current_collider

	# == MOVE ==
	global_position = new_position

	# == UPDATE STATE VARIABLES ==
	last_position = new_position

# on body entered
func _on_body_entered(body: Node3D) -> void:
	print("[BldBlt] Collided with %s" % body.name)
	emit_signal("collided_with", self, body)
