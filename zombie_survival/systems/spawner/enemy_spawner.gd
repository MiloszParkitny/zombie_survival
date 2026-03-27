extends Node2D

@export var spawns: Array[Spawn_Info]= []
var difficulty_multiplier = 1.0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var time_label = get_tree().get_first_node_in_group("time_label")

var time = 0
var max_enemies = 200
var difficulty_factor = 1.0

@export var boss_scene: PackedScene
var last_boss_time = 0
var boss_interval = 80

func _on_timer_timeout():
	time += 1
	time_label.text = format_time(time)
	difficulty_multiplier = 1.0 + (time / 60.0)

	for i in spawns:
		if get_child_count() > max_enemies:
			return
		if time >= i.time_start and time <= i.time_end:
			
			var delay = max(5, int(i.enemy_spawn_delay / (sqrt(difficulty_multiplier) * difficulty_factor)))
			
			if i.spawn_delay_counter < delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				
				var enemy_scene = i.enemy
				
				var amount = int((i.enemy_num + difficulty_multiplier * 0.5) * difficulty_factor)
				
				if randi() % 10 == 0:
					amount *= 2
				
				for j in range(amount):
					var enemy_spawn = enemy_scene.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					
	if time >= boss_interval and time - last_boss_time >= boss_interval:
		spawn_boss()
		last_boss_time = time

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)

	var top_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)

	var pos_side = ["up", "down", "right", "left"].pick_random()

	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO

	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right

		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right

		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right

		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left

	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)

	return Vector2(x_spawn, y_spawn)


func format_time(t):
	var minutes = int(t / 60)
	var seconds = int(t % 60)
	return "%02d:%02d" % [minutes, seconds]

@onready var difficulty_button = $SettingsPanel/VBoxContainer/difficulty
func _ready():
	match GameSettings.difficulty:
		"Easy":
			difficulty_factor = 0.7
		"Normal":
			difficulty_factor = 1.0
		"Hard":
			difficulty_factor = 1.5

func spawn_boss():
	if boss_scene == null:
		return
	
	var boss = boss_scene.instantiate()

	boss.global_position = get_boss_spawn_position()
	
	add_child(boss)
	
func get_boss_spawn_position():
	var distance = 400 
	
	var angle = randf() * TAU
	
	var pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	
	return pos
