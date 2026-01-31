extends CharacterBody2D

signal reached_end(enemy)
signal died(enemy, gold_reward)

@export var speed = 50.0
@export var max_health = 100.0
@export var gold_reward = 10

var current_health = max_health
var path = []
var path_index = 0

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D

func _ready():
	current_health = max_health
	update_health_bar()

func _physics_process(delta):
	if path.size() == 0 or path_index >= path.size():
		return
	
	var target = path[path_index]
	var direction = (target - position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	# Check if reached current waypoint
	if position.distance_to(target) < 10:
		path_index += 1
		if path_index >= path.size():
			reached_end.emit(self)

func take_damage(amount: float):
	current_health -= amount
	update_health_bar()
	
	if current_health <= 0:
		die()

func die():
	died.emit(self, gold_reward)

func update_health_bar():
	if health_bar:
		health_bar.value = (current_health / max_health) * 100
