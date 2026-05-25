extends DirectionalLight3D

var player: CharacterBody3D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position + Vector3(0, 10, 0)
