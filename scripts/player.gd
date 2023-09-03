extends CharacterBody3D


#speed var
var speed 
var CROUCH_SPEED = 2.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 4.5

const sensitivity = 0.05

#fov
const fov_base = 90
const fov_change = 0.7

#bob var
const bob_frq = 2.0
const bob_amp = 0.08
var t_bob = 0.0

@onready var head = $Head
@onready var cam = $Head/Camera3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_x(deg_to_rad(event.relative.y * sensitivity))
		self.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
	if Input.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("go_back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	
	#weapons

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Cam bob
	t_bob= delta * velocity.length() *float(is_on_floor())
	cam.transform.origin = _headbob(t_bob)
	
	if Input.is_action_pressed("sprint"):
		speed=SPRINT_SPEED
	elif Input.is_action_pressed("slow"):
		speed=CROUCH_SPEED
	else:
		speed=WALK_SPEED 
	
	var input_dir = Input.get_vector("right", "left","backward", "forward")
	var direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#inertia
	if is_on_floor():
		if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
		else:
				velocity.x = lerp(velocity.x, direction.x*speed, delta*6.0)
				velocity.z = lerp(velocity.z, direction.z*speed, delta*6.0)
	else:
		velocity.x = lerp(velocity.x, direction.x*speed, delta*3.0)
		velocity.z = lerp(velocity.z, direction.z*speed, delta*3.0)
		
	#fov
	var vel_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED*2 )
	var target_fov = fov_base + fov_change*vel_clamped
	cam.fov = lerp(cam.fov, target_fov, delta*8.0)

	move_and_slide()
	
	
func _headbob(delta) -> Vector3:
		var pos= Vector3.ZERO
		pos.y = 4*sin(delta*bob_frq)*bob_amp
		pos.x = 4*cos(delta * bob_frq) *bob_amp
		return pos

