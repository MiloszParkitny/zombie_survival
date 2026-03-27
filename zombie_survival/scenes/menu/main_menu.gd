extends Control

@onready var menu = $VBoxContainer
@onready var settings = $SettingsPanel
var difficulty = "Normal"

func _ready():
	$MenuMusic.play()
	get_tree().paused = false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	menu.hide()
	settings.show()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world/world.tscn")


func _on_difficulty_item_selected(index: int) -> void:
	match index:
		0:
			GameSettings.difficulty = "Easy"
			GameSettings.difficulty_factor = 0.8
		1:
			GameSettings.difficulty = "Normal"
			GameSettings.difficulty_factor = 1.0
		2:
			GameSettings.difficulty = "Hard"
			GameSettings.difficulty_factor = 1.4

func _on_back_pressed() -> void:
	settings.hide()
	menu.show()



func _on_volume_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	if value <= 0:
		AudioServer.set_bus_volume_db(bus, -80) 
	else:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
