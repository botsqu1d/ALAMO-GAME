extends CharacterBody3D

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var eyes = $Neck/Head/eyes
@onready var stand_collision_shape = $stand_collision_shape
@onready var crouch_collision_shape = $crouch_collision_shape
@onready var ray_cast_3d = $RayCast3D
@onready var camera = $Neck/Head/eyes/Camera3D
@onready var animation_jump = $Neck/Head/eyes/AnimationJump
@onready var viewmodelcamera = $Neck/Head/eyes/Camera3D/SubViewportContainer/SubViewport/viewmodelcamera
@onready var crouchinganimations = $stand_collision_shape/MeshInstance3D/Crouchinganimations





#use @export var for different speeds to test it out in game
#speeds

var current_speed = 3.0
const walking_speed = 3.0
const sprint_speed = 5.0
const crouch_speed = 1.0
#states
var walking = false
var sprinting = false
var crouching = false
var freelook = false
#headbobbing vars
const head_bobbing_sprinting_speed = 50.0
const head_bobbing_walking_speed = 10.0
const head_bobbing_crouching_speed = 6.0

const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0
#movement varswww

const jump_velocity = 2

const mouse_sens = 0.25
var is_ready: bool = true
var lerp_speed = 10.0

var free_lock_tilt_amount = 3

var last_velocity = Vector3.ZERO
#input vars
var direction = Vector3.ZERO

var crouching_depth = -0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Neck/Head/eyes/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
func _input(event):
	
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		if freelook:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-100),deg_to_rad(100))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-60),deg_to_rad(89))
		
		viewmodelcamera.sway(Vector2(event.relative.x,event.relative.y))
func _physics_process(delta):
	
	$Neck/Head/eyes/Camera3D/SubViewportContainer/SubViewport/viewmodelcamera.global_transform = camera.global_transform
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	#crouching
	if Input.is_action_pressed("crouch") and is_on_floor():
		current_speed = lerp(current_speed,crouch_speed,delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth,delta * lerp_speed)
		stand_collision_shape.disabled = true
		crouch_collision_shape.disabled = false
		crouching = true
		walking = false
		sprinting = false
		crouchinganimations.play("crouchanim")
		
	elif !ray_cast_3d.is_colliding():
		#standing
		stand_collision_shape.disabled = false
		crouch_collision_shape.disabled = true
		head.position.y = lerp(head.position.y,0.0,delta * lerp_speed)
		
	if Input.is_action_just_released("crouch"):
		crouchinganimations.play("upanim")
	#sprintin
		
	if Input.is_action_pressed("sprint") and is_on_floor_only() and Input.is_action_pressed("crouch") == false: 
		current_speed = lerp(current_speed,sprint_speed,delta * lerp_speed)
		sprinting = true
		walking = false
		crouching = false


	else:
			#walking
			current_speed = lerp(current_speed,walking_speed,delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false


	#Freelooking
	if Input.is_action_pressed("freelook"):
		freelook = true
		camera.rotation.z = -deg_to_rad(neck.rotation.y * free_lock_tilt_amount)
	else:
		freelook = false
		neck.rotation.y = lerp(neck.rotation.y,0.0,delta * lerp_speed)
		camera.rotation.z = lerp(camera.rotation.y,0.0,delta * lerp_speed)
		
	#handles headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		
	if is_on_floor() && input_dir != Vector2.ZERO: 
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/3) + 1
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y *(head_bobbing_current_intensity/2.0),delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x *(head_bobbing_current_intensity),delta * lerp_speed)
			

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and Input.is_action_pressed("crouch") == false:

		velocity.y = jump_velocity
		animation_jump.play("jumping")

		#landing
	if is_on_floor():
		if last_velocity.y < 0.0:
			animation_jump.play("landing")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	last_velocity = velocity
	
	
	

	
	
	
	move_and_slide()
	
	








func _on_cooldown_timer_timeout():
	is_ready = true
