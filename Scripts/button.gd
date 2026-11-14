#extends Button
#
#@export var move_offset := Vector2(100, 0)
#@export var move_time := 0.5
#@onready var _target = $Mur
#@onready var _sprite = $AnimatedSprite2D
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pressed.connect(_on_pressed)	
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _on_pressed() -> void:
	#var tween := create_tween()
	#tween.tween_property(_target, "position", _target.position + move_offset, move_time)
	#_sprite.play()


extends Button

@export var _target: Node2D          # Glisse "Mur" ici dans l'Inspector
@export var _sprite: AnimatedSprite2D # Glisse "AnimatedSprite2D" ici

@export var move_offset := Vector2(0, -200)
@export var move_time := 2

func _ready() -> void:
	pressed.connect(_on_pressed)	

func _on_pressed() -> void:
	# On vérifie que les nœuds sont bien assignés pour éviter un crash
	if not _target or not _sprite:
		return
		
	var tween := create_tween()
	tween.tween_property(_target, "position", _target.position + move_offset, move_time)
	
	# --- MODIFICATION POUR 1 SEULE FRAME ---
	_sprite.play() # Remplace par le nom de ton animation
	_sprite.frame = 0               # Force la première frame
	_sprite.pause()                 # Met l'animation en pause
