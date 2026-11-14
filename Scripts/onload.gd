#extends Node2D
#func _ready() -> void:
	## Connecte le signal de redimensionnement de la fenêtre
	#get_window().size_changed.connect(_on_window_resized)
#
#func _on_window_resized() -> void:
	## Force le viewport principal à prendre la taille de la fenêtre
	#var new_size = get_window().size
	#get_viewport().size = new_size
	## Optionnel : recentre la caméra si besoin
	## $Camera2D.make_current()
