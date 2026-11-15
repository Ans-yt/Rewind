extends Node2D

@onready var level_container: Node2D = $LevelContainer

# On garde une trace du niveau actuel
var current_level_instance: Node = null

func _ready() -> void:
	# On lance le niveau 1 au démarrage
	load_level(1)

func load_level(level_number: int) -> void:
	# 1. Supprimer l'ancien niveau s'il existe
	if current_level_instance:
		current_level_instance.queue_free()
		current_level_instance = null
		
	# 2. Charger le nouveau niveau
	var path = "res://Scenes/level_" + str(level_number) + ".tscn" # Adapte le chemin
	if not ResourceLoader.exists(path):
		print("Niveau introuvable : ", path)
		return
		
	var level_scene = load(path)
	current_level_instance = level_scene.instantiate()
	
	# 3. L'ajouter à la scène
	level_container.add_child(current_level_instance)
