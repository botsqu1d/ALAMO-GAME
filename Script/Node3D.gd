extends Node3D

var is_ready: bool = true

func _process(delta):
	if Input.is_action_just_pressed("jump") and is_ready:
		is_ready = false
		print("action pressed")
