extends Area2D

@export_group("Mécanisme du Mur")
@export var _target: Node2D          # Glisse "Mur" ici dans l'Inspector
@export var _sprite: AnimatedSprite2D # Glisse "AnimatedSprite2D" ici
@export var move_offset := Vector2(0, 50)
@export var move_time := 5.0

@export_group("Mécanisme du Laser")
@export var target_laser: Area2D     # Glisse ton nœud "laser" ici dans l'Inspector

var has_been_pressed := false 

func _ready() -> void:
	# On connecte le signal uniquement pour l'entrée
	body_entered.connect(_on_body_entered)



func _on_body_entered(body: Node2D) -> void:
	if has_been_pressed: 
		return # Si c'est déjà pressé, on ne fait rien
		
	# Vérification que c'est bien le joueur (via son groupe ou son type)
	if body.is_in_group("player") or body is CharacterBody2D:
		has_been_pressed = true
		
		# 1. Faire bouger le mur
		if _target:
			var tween := create_tween()
			tween.tween_property(_target, "position", _target.position + move_offset, move_time)
		
		# 2. Jouer l'animation du bouton (1 seule fois)
		if _sprite:
			_sprite.play() 
			
		# 3. Activer le laser
		if target_laser:
			target_laser.is_active = true
