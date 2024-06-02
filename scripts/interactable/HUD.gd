extends CanvasLayer

@onready var currentweaponlabel= $VBoxContainer/HBoxContainer/CurrentWeapon
@onready var currentammolabel = $VBoxContainer/HBoxContainer2/CurrentAmmo
@onready var currentweaponstacklabel = $VBoxContainer/HBoxContainer3/WeaponStack



func _on_weaponsmanager_update_ammo(ammo):
	currentammolabel.set_text(str(ammo[0]) + " / " + str(ammo[1]))



func _on_weaponsmanager_update_weapon_stack(weapon_stack):
	currentweaponstacklabel.set_text("")
	for i in weapon_stack:
		currentweaponstacklabel.text += i + '  ,  '



func _on_weaponsmanager_weapon_changed(weapon_name):
	currentweaponlabel.set_text(weapon_name)
