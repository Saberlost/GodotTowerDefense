extends Area2D

@export var max_distance = 1000.0

var target: Node2D = null
var damage: float = 10.0
var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D

func _ready():
	# Connect to area entered signal to detect hits
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if target and is_instance_valid(target):
		# Track the target
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
	
	# Move in the direction
	position += direction * speed * delta
	
	# Remove if target is gone or too far from origin
	if not target or not is_instance_valid(target):
		queue_free()
	elif global_position.distance_to(target.global_position) > max_distance:
		queue_free()

func _on_body_entered(body):
	# Hit the target
	if body == target and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func set_target(new_target: Node2D, new_damage: float):
	target = new_target
	damage = new_damage
	if target:
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
