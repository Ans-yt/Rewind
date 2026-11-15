extends Area2D 

@export var is_active := false : set = set_active
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visuals()

func set_active(value: bool) -> void:
	is_active = value
	if is_instance_valid(self):
		_update_visuals()

func _update_visuals() -> void:
	
	if is_active:
		sprite.visible = true
		collision.set_deferred("disabled", false) # Utilise set_deferred ici
	else:
		sprite.visible = false
		collision.set_deferred("disabled", true)  # Et ici

func _on_body_entered(body: Node2D) -> void:
	if is_active and (body.is_in_group("player") or body is CharacterBody2D):
		#body.resp			_collision_shape.set_deferred("disabled", false)awn()
		#sprite.visible = false
		#collision.set_deferred("disabled", true)  # Et ici
		get_tree().reload_current_scene()
		#leave_screen("res://Scenes/level_2.tscn")
