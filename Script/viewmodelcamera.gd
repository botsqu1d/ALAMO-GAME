extends Camera3D

@onready var fps_rig = $fps_rig
@onready var rifle = $fps_rig/Rifle
@onready var aiming_animation = $fps_rig/AimingAnimation
@onready var shooting_animation = $fps_rig/ShootingAnimation




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x,0.0, delta * 5)
	fps_rig.position.y = lerp(fps_rig.position.y,0.0, delta * 5)

			
			

func sway (sway_amount):
	fps_rig.position.x -= sway_amount.x * 0.0002
	fps_rig.position.y += sway_amount.y * 0.0002

