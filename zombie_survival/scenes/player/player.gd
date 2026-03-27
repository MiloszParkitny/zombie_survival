extends CharacterBody2D

var movement_speed = 25
@export var hp = 5

@onready var legs = $Legs
@onready var body = $Body

@onready var legs_sprite = $LegsSprite
@onready var body_sprite = $BodySprite

@onready var gun = $Gun2
@onready var gun_anim = $Gun3

@onready var shootTimer = $ShootTimer
@onready var muzzle = $Gun2/Muzzle
@onready var hp_bar = get_tree().get_first_node_in_group("ui_hp")
@onready var level_up_panel = get_tree().get_first_node_in_group("level_up")
@onready var exp_bar = get_tree().get_first_node_in_group("ui_exp")
var gun_offset = Vector2(-14, 15) 
var bullet_scene = preload("res://systems/combat/bullet.tscn")
var min_fire_rate = 0.2
var fire_rate = 0.4
var damage = 1.2

var exp = 0
var level = 1
var exp_to_next = 5

# ========================
# READY
# ========================

func _ready():
	hp_bar.max_value = hp
	hp_bar.value = hp
	
	exp_bar.max_value = exp_to_next
	exp_bar.value = exp

# ========================
# MAIN LOOP
# ========================

func _physics_process(delta):
	movement()
	aim()
	shoot()

# ========================
# MOVEMENT + LEGS
# ========================

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)

	velocity = mov.normalized() * movement_speed
	move_and_slide()

	# 👣 LEGS ANIMATION
	if mov.length() > 0.1:
		if legs.current_animation != "walk":
			legs.play("walk")
	else:
		legs.stop()

	# 🔁 FLIP względem myszki
	var mouse_pos = get_global_mouse_position()

	if mouse_pos.x > global_position.x:
		legs_sprite.flip_h = false
		body_sprite.flip_h = false
		gun.scale.y = 1
	else:
		legs_sprite.flip_h = true
		body_sprite.flip_h = true
		gun.scale.y = -1

# ========================
# AIM (obrót broni)
# ========================

func aim():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	var facing_right = mouse_pos.x > global_position.x

	# 🔁 USTAW POZYCJĘ (lustrzane odbicie)
	if facing_right:
		gun.position = gun_offset
	else:
		gun.position = Vector2(-gun_offset.x, gun_offset.y)

	# 🎯 ROTACJA
	gun.rotation = dir.angle()

	# 🔁 FLIP POSTACI
	legs_sprite.flip_h = not facing_right
	body_sprite.flip_h = not facing_right

# ========================
# SHOOT + GUN ANIMATION
# ========================

func shoot():
	var is_shooting = Input.is_action_pressed("shoot")

	# 🔫 ANIMACJA BRONI
	if is_shooting:
		if gun_anim.current_animation != "shoot":
			gun_anim.play("shoot")
	else:
		if gun_anim.current_animation != "idle":
			gun_anim.play("idle")

	# 🔥 STRZAŁ
	if is_shooting and shootTimer.is_stopped():

		play_shot_sound()

		var bullet = bullet_scene.instantiate()
		bullet.position = muzzle.global_position

		var mouse_pos = get_global_mouse_position()
		bullet.direction = (mouse_pos - gun.global_position).normalized()

		bullet.damage = damage 

		get_parent().add_child(bullet)

		shootTimer.start(fire_rate)

# ========================
# DAMAGE
# ========================

func _on_hurtbox_hurt(damage: Variant) -> void:
	hp -= damage
	hp_bar.value = hp
	
	if hp <= 0:
		var panel = get_tree().get_first_node_in_group("game_over")
		var time_text = get_tree().get_first_node_in_group("time_label").text
		panel.show_panel(time_text)

# ========================
# SOUND
# ========================

func play_shot_sound():
	var sound = $ShootSound.duplicate()
	add_child(sound)
	sound.play(3.05)

	var timer = get_tree().create_timer(0.55)
	timer.timeout.connect(func():
		sound.stop()
		sound.queue_free()
	)

# ========================
# EXP / LEVEL
# ========================

func add_exp(amount):
	exp += amount
	if exp >= exp_to_next:
		level_up()
	else:
		exp_bar.value = exp

func level_up():
	level += 1
	
	exp -= exp_to_next
	exp_to_next += 5
	
	exp_bar.max_value = exp_to_next
	exp_bar.value = exp
	
	level_up_panel.show_panel()
