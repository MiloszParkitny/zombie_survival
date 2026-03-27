extends Area2D

@export var exp_value = 1
var speed = 100

@onready var player = get_tree().get_first_node_in_group("player")
func _process(delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		position += direction * speed * delta
