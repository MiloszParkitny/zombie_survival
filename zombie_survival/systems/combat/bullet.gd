extends Area2D

var speed = 400
var direction = Vector2.ZERO
@export var damage = 1

func _ready():
	rotation = direction.angle() + deg_to_rad(45)

func _process(delta):
	position += direction * speed * delta

func _on_area_entered(area):
		queue_free()
