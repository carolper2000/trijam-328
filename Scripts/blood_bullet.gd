extends Area3D

var speed=50

signal raycasted_with(bullet: Area3D, target: Node3D)
var last_position: Vector3
var state: STATE = STATE.DEFAULT
var initial_position = Vector3.ZERO
var previous_collider:Object = null

enum STATE
{
	DEFAULT,
	SHOT,
	FLOATING,
};

func _ready():
	last_position = global_position
	initial_position = global_position

func _process(delta):
	var new_position = Vector3.ZERO
	
	# == STATES ==
	if state == STATE.SHOT:
		new_position = global_position + transform.basis.z * -speed * delta

	if state == STATE.FLOATING: #(cycle between y=20 et y=200 en 2 secondes)
		new_position = global_position
		new_position.y = initial_position.y + 1.3 + sin(Time.get_ticks_msec() / 2000.0 * PI)

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
