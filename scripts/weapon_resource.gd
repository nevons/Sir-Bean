extends Resource

class_name weapon_resource

@export var weapon_name: String
@export var activate_anim: String
@export var deactivate_anim: String
@export var reload_anim: String
@export var shoot_anim: String
@export var ooa_anim: String

@export var current_ammo: int
@export var reserve_ammo: int
@export var max_ammo: int
@export var magazine: int

@export var auto_fire: bool

@export_flags("HitScan","Projectile") var Type
@export var weapon_range : int
@export var weapon_damage : int
