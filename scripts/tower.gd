extends Node2D

@export var damage = 10.0
@export var attack_speed = 1.0  # attacks per second
@export var range = 150.0
@export var projectile_speed = 300.0

var enemy_container = null
var current_target = null
var attack_timer = 0.0

@onready var range_circle = $RangeCircle
@onready var sprite = $Sprite2D

func _ready():
	attack_timer = 1.0 / attack_speed
	if range_circle:
		range_circle.scale = Vector2(range / 50.0, range / 50.0)

func _physics_process(delta):
	attack_timer -= delta
	
	if attack_timer <= 0:
		attack_timer = 1.0 / attack_speed
		find_and_attack_enemy()

func set_enemy_container(container):
	enemy_container = container

func find_and_attack_enemy():
	if not enemy_container:
		return
	
	var closest_enemy = null
	var closest_distance = range + 1
	
	for enemy in enemy_container.get_children():
		var distance = position.distance_to(enemy.position)
		if distance < range and distance < closest_distance:
			closest_enemy = enemy
			closest_distance = distance
	
	if closest_enemy:
		attack_enemy(closest_enemy)

func attack_enemy(enemy):
	# Simple direct damage (can be extended with projectiles)
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	
	# Rotate towards enemy
	if sprite:
		sprite.rotation = position.angle_to_point(enemy.position)
