extends Panel

@onready var anim = $AnimationPlayer
@onready var time_label = $VBoxContainer/TimeLabel

func show_panel(time_survived):
	time_label.text = "Time: " + time_survived
	
	show()
	get_tree().paused = true
	
	modulate.a = 0
	scale = Vector2(0.8, 0.8)
	
	anim.play("show")

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
