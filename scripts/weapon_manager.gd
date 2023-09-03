extends Node3D

signal weapon_changed
signal update_ammo
signal update_weapon_stack

@onready var anim_player=$FPS_Rig/player_anim
@onready var bullet_point=$FPS_Rig/bullet_point

var current_weapon = null

var weapon_stack = [] #array of weapons available currently
var weapon_indicator = 0

var next_weapon : String

var weapon_list = {}

@export var _weapon_resources : Array[weapon_resource]

@export var start_weapons : Array[String]

func _ready():
	Initialize(start_weapons) #enter the state machine
	
func _input(_event):
	if Input.is_action_just_pressed("next_weapon"):
		weapon_indicator = min(weapon_indicator+1, weapon_stack.size()-1)
		exit(weapon_stack[weapon_indicator])
		
	if Input.is_action_just_pressed("previous_weapon"):
		weapon_indicator = min(weapon_indicator-1,0)
		exit(weapon_stack[weapon_indicator])
		
	if Input.is_action_just_pressed("left_click"):
		shoot()
		
	if Input.is_action_just_pressed("reload"):
		reload()

func Initialize(_start_weapons: Array):
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
		
	for i in _start_weapons:
		weapon_stack.push_back(i) #add start weaps
		
	current_weapon = weapon_list[weapon_stack[0]]
	emit_signal("update_weapon_stack", weapon_stack)
	enter()
	
func enter(): #call when first "entering" a weapon
	anim_player.queue(current_weapon.activate_anim)
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	
	
func exit(_next_weapon : String): #to change weaps, first call exit
	if _next_weapon!=current_weapon.weapon_name:
		if anim_player.get_current_animation() != current_weapon.deactivate_anim:
			anim_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon
	
func change_weapon(weapon_name : String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()


func _on_player_anim_animation_finished(anim_name):
	if anim_name==current_weapon.deactivate_anim:
		change_weapon(next_weapon)
		
	if anim_name==current_weapon.shoot_anim && current_weapon.auto_fire == true:
		if Input.is_action_pressed("left_click"):
			shoot()
		

func shoot():
	if current_weapon.current_ammo!=0:
		if !anim_player.is_playing(): #enforces fire rate
			anim_player.play(current_weapon.shoot_anim)
			current_weapon.current_ammo -= 1
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	else:
		reload()
	
func reload():
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	elif !anim_player.is_playing():
		if current_weapon.reserve_ammo !=0:
			anim_player.play(current_weapon.reload_anim)
			var reload_amount = min(current_weapon.magazine-current_weapon.current_ammo,current_weapon.magazine,current_weapon.reserve_ammo)
			
			current_weapon.current_ammo += reload_amount
			current_weapon.reserve_ammo -= reload_amount
			
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
		
		
		else:
			anim_player.play(current_weapon.ooa_anim)
