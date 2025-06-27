extends CharacterBody3D

var speed=25

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
