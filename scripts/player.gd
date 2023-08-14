extends CharacterBody3D

@onready var player_anim=$"../player_anim"
@onready var weapon_code = 3
@onready var bullet_count 
@onready var ammo_reserve

@onready var spread = 15

#pistol
@onready var pistol=$Head/Camera3D/pistol
@onready var pistol_barrel=$Head/Camera3D/aim
@onready var pistol_anim=$Head/Camera3D/pistol/AnimationPlayer
@onready var shot=$Head/Camera3D/pistol/shot
@onready var pistol_script = load("res://scripts/pistol.gd")
@onready var pistol_bullet=load("res://scenes/weapons/pistol_bullet.tscn")
var instance

#scorpion
@onready var scorpion= $Head/Camera3D/scorpion
@onready var scorpion_barrel=$Head/Camera3D/aim
@onready var scorpion_anim=$Head/Camera3D/scorpion/scorpion_anim
@onready var smg_bullet=load("res://scenes/weapons/smg_bullet.tscn")
var smg_instance

#shotgun
@onready var shotgun=$Head/Camera3D/shotgun
@onready var shotgun_aim=$Head/Camera3D/aim
@onready var shotgun_anim=$Head/Camera3D/shotgun/shotgun_anim
@onready var shotgun_barrel=$Head/Camera3D/shotgun/ray_group2
@onready var shotgun_pellet=load("res://scenes/weapons/shotgun_pellet.tscn")
var pellet_instance

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
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-50), deg_to_rad(60))
		
	if Input.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("go_back"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			

func _physics_process(delta):
	
	#weapons
	#switch
	if Input.is_action_pressed("back"):
		if weapon_code==3:
			player_anim.play("back_weapon_switch_from_3")
			weapon_code=1
		elif weapon_code==2:
			player_anim.play("back_weapon_switch_from_2")
			weapon_code=1
	elif Input.is_action_pressed("primary"):
		if weapon_code==1:
			player_anim.play_backwards("back_weapon_switch_from_2")
			weapon_code=2
		elif weapon_code==3:
			player_anim.play("weapon_switch_primary")
			weapon_code=2
	elif Input.is_action_just_pressed("secondary"):
		if weapon_code==2:
			player_anim.play("weapon_switch_secondary")
			weapon_code=3
		elif weapon_code==1:
			player_anim.play_backwards("back_weapon_switch_from_3")
			weapon_code=3
		
	#shotgun
	if weapon_code==1:
		if Input.is_action_just_pressed("left_click"):
			if !shotgun_anim.is_playing():
				shotgun_anim.play("cocking")
				await get_tree().create_timer(0.6).timeout
				shotgun_anim.play("shoot")
				for r in shotgun_barrel.get_children():
					pellet_instance=shotgun_pellet.instantiate()
					pellet_instance.position=r.global_position
					pellet_instance.transform.basis=r.global_transform.basis
					randomize()
					r.rotate_z(randf_range(rad_to_deg(30),rad_to_deg(45)))
					get_parent().add_child(pellet_instance)
					
		if Input.is_action_just_pressed("aiming"):
			player_anim.play("back_aim")
		if Input.is_action_just_released("aiming"):
			player_anim.play_backwards("back_aim")
			
		if Input.is_action_pressed("reload"):
			for i in range(24):
				shotgun_anim.play("reload")
				await get_tree().create_timer(0.4).timeout
			
	
	#scorpion
	if weapon_code==2:
		if Input.is_action_pressed("left_click"):
			if !scorpion_anim.is_playing():
				scorpion_anim.play("shoot")
				smg_instance=smg_bullet.instantiate()
				smg_instance.position = scorpion_barrel.global_position
				smg_instance.transform.basis = scorpion_barrel.global_transform.basis
				get_parent().add_child(smg_instance)
				
		if Input.is_action_just_pressed("reload"):
			scorpion_anim.play("reload")
			
		if Input.is_action_just_pressed("aiming"):
			player_anim.play("primary_aim")
		if Input.is_action_just_released("aiming"):
			player_anim.play_backwards("primary_aim")
			
		
			
	#pistol
	elif weapon_code==3:
		if Input.is_action_just_pressed("left_click"):
			if !pistol_anim.is_playing():
				pistol_anim.play("Shoot")
				shot.set_pitch_scale(randf_range(0.7,0.9))
				instance=pistol_bullet.instantiate()
				instance.position = pistol_barrel.global_position
				instance.transform.basis = pistol_barrel.global_transform.basis
				get_parent().add_child(instance)
				
		
		if Input.is_action_just_pressed("reload"):
			pistol_anim.play("Reload")
			
		if Input.is_action_just_pressed("aiming"):
			player_anim.play("secondary_aim")
		if Input.is_action_just_released("aiming"):
			player_anim.play_backwards("secondary_aim")
		
	
		
	
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
	
	
func _headbob(time) -> Vector3:
		var pos= Vector3.ZERO
		pos.y = sin(time*bob_frq)*bob_amp
		pos.x = cos(time * bob_frq/2) *bob_amp
		return pos

