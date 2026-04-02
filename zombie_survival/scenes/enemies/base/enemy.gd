extends CharacterBody2D

@export var movement_speed = 35.0
@export var hp = 5
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var hp_bar = $ProgressBar
var exp_orb_scene = preload("res://systems/exp/exp_orb.tscn")

@onready var hurtbox = $Hurtbox


func _ready():
	anim.play("walk")
	var f = GameSettings.difficulty_factor
	hp = hp * f
	movement_speed = movement_speed * f
	hp_bar.max_value = hp
	hp_bar.value = hp


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)
	
	if distance > 20:
		velocity = direction * movement_speed
	else:
		var perpendicular = Vector2(-direction.y, direction.x)
		velocity = perpendicular * movement_speed * 0.5
	
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = false
	elif direction.x < -0.1:
		sprite.flip_h = true

func drop_exp():
	var orb = exp_orb_scene.instantiate()
	orb.global_position = global_position
	get_parent().add_child(orb)

func _on_hurtbox_hurt(damage):
	hp -= damage
	hp_bar.value = hp
	hp_bar.visible = hp < hp_bar.max_value
	
	sprite.modulate = Color(1, 0.3, 0.3) # czerwony flash
	
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if hp <= 0:
		drop_exp()
		queue_free()
