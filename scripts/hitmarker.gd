extends Sprite3D

@onready var hit=$hit



func _on_timer_timeout():
	hit.playing=true
	queue_free()
