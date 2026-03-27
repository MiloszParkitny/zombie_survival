extends Panel

@onready var player = get_tree().get_first_node_in_group("player")

func show_panel():
	show()
	get_tree().paused = true

func close_panel():
	hide()
	get_tree().paused = false

func _on_upgrade_1_pressed() -> void:
	player.movement_speed += 20
	close_panel()

func _on_upgrade_2_pressed() -> void:
	player.fire_rate = max(player.min_fire_rate, player.fire_rate * 0.9)
	close_panel()

func _on_upgrade_3_pressed() -> void:
	player.damage += 0.7
	close_panel()
