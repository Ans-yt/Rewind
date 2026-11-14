extends Area2D

@export var _target: Node2D          # Glisse "Mur" ici dans l'Inspector
@export var _sprite: AnimatedSprite2D # Glisse "AnimatedSprite2D" ici

@export var move_offset := Vector2(0, 50)
@export var move_time := 5

# Variable pour éviter que le bouton se déclenche 60 fois par seconde
var has_been_pressed := false 

func _ready() -> void:
	# On connecte le signal "body_entered" (quand un corps physique entre dans la zone)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# On vérifie que c'est bien le joueur (et pas un ennemi ou un objet)
	# Le plus simple : vérifier si le corps a une méthode is_on_floor ou si c'est ton joueur
	if has_been_pressed: 
		return # Si c'est déjà pressé, on ne fait rien
		
	if body.name == "Player" or body is CharacterBody2D:
		has_been_pressed = true
		
		# 1. Faire bouger le mur
		if _target:
			var tween := create_tween()
			tween.tween_property(_target, "position", _target.position + move_offset, move_time)
		
		# 2. Jouer l'animation (1 seule fois)
		if _sprite:
			_sprite.play() # Remplace par le nom de l'animation
