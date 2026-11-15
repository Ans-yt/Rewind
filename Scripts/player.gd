# Called every frame. 'delta' is the elapsed time since the previous frame.
extends CharacterBody2D

#@export var respawnPoint : Vector2 = Vector2(250,250)
@export var speedX := 400.0
@export var jump_force := 600.0
@export var gravity := 1500.0
@export var friction := 0.85   # ralentissement au sol
@export var boostIntensity := 10

	
@onready var _collision_shape = $CollisionShape2D
@onready var dashCooldown : Timer = $DashCooldown
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _glitch_shader = $GlitchShader

# - - - - - -

var positionsX = []
var positionsY = []
var r = 0
var i = 0
var is_rewinding = true

const MAX_HISTORY := 120
var respawn_position: Vector2
# - - - - - -

func _ready() -> void :
	dashCooldown.one_shot = true
	dashCooldown.wait_time = 0.2
	_glitch_shader.visible = false
	respawn_position = global_position # On sauvegarde la position de départ

	# a decomenter avant de BUILD
	# respawn()



# - - - - - -
# - - - - - -
# - - - - - -


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Respawn") :
		respawn()
	
	var isRewind = Input.is_action_pressed("rewind") and positionsX.size() == MAX_HISTORY
	
	if not isRewind:
		if not is_rewinding : 
			is_rewinding = true
			r = 0
			i = 0
			_glitch_shader.visible = false
			_collision_shape.set_deferred("disabled", false)
			
		# 1) Gravité (Y+ = bas en Godot)
		if not is_on_floor():
			velocity.y += gravity * delta

		# 2) Saut (impulsionnel, seulement au sol)
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = -jump_force

		# 3) Mouvement horizontal
		var direction := Input.get_axis("move_left", "move_right")
		var dash = Input.is_action_just_pressed("dash") and dashCooldown.is_stopped()
		
		if direction != 0:
			velocity.x = direction * speedX * (boostIntensity if dash else 1)
			_animated_sprite.play()
			var facing = sign(direction)
			_animated_sprite.flip_h = facing < 0	
			
		else:
			_animated_sprite.pause()

			velocity.x *= friction   # ralentissement progressif
		if dash : 
			dashCooldown.start()

		if positionsX.size() >= MAX_HISTORY:
			positionsX.pop_front()
			positionsY.pop_front()
		positionsX.append(global_position.x)
		positionsY.append(global_position.y)

		# 4) Application
		move_and_slide()
		 
	elif positionsX.size() - 1 >= 0:
		if is_rewinding :
			r = positionsX.size() - 1
			is_rewinding = false
			i = 0
			_glitch_shader.visible = true
			_collision_shape.set_deferred("disabled", true) 
						
		if r - i >= 0:
			global_position.x = positionsX[r-i]
			global_position.y = positionsY[r-i]
			i+=1
		else : 
			positionsX = []
			positionsY = []


# - - - -

func respawn() -> void :
	#if Input.is_action_just_pressed("Respawn") : 
	velocity = Vector2.ZERO # On arrête son mouvement
	global_position = respawn_position
	positionsX = []
	positionsY = []
	get_tree().reload_current_scene()
