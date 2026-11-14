extends CharacterBody2D

@export var speed := 80.0           # Vitesse lente (un zombie est lent)
@export var gravity := 1500.0       # Même gravité que le joueur
@export var detection_radius := 400.0 # Distance à laquelle il repère le joueur

@onready var sprite = $Sprite2D

var player: Node2D = null

func _ready() -> void:
	# On cherche le joueur au démarrage grâce au groupe
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	# 1. Gravité
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Logique de suivi
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Si le joueur est assez proche, le zombie le suit
		if distance_to_player < detection_radius:
			# On calcule la direction (1 = droite, -1 = gauche)
			var direction = sign(player.global_position.x - global_position.x)
			
			# On applique la vitesse
			velocity.x = direction * speed
			
			# On tourne le sprite dans la bonne direction
			if direction > 0:
				sprite.flip_h = false
			elif direction < 0:
				sprite.flip_h = true
				
			## On joue l'animation de marche
			#if sprite.animation != "walk":
				#sprite.play("walk")
		else:
			# Le joueur est trop loin : le zombie s'arrête
			velocity.x = move_toward(velocity.x, 0, speed)
			#if sprite.animation != "idle":
				#sprite.play("idle")

	# 3. Application du mouvement (avec collisions)
	move_and_slide()
