extends Node2D

@export var damage = 10.0
@export var attack_speed = 1.0  # attacks per second
@export var range = 150.0
@export var projectile_speed = 300.0
@export var use_projectiles = false
@export var projectile_scene: PackedScene = null

var enemy_container = null
var current_target = null
var attack_timer = 0.0

@onready var range_circle = $RangeCircle
@onready var sprite = $Sprite2D

func _ready():
	if attack_speed <= 0:
		attack_speed = 1.0  # Default to prevent division by zero
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
	# Orient sprite towards enemy
	if sprite:
		# For AnimatedSprite2D, flip horizontally instead of rotating
		if sprite is AnimatedSprite2D:
			var direction = enemy.global_position - global_position
			sprite.flip_h = direction.x < 0
		else:
			# For other sprites (like Polygon2D), rotate as before
			sprite.rotation = position.angle_to_point(enemy.position)
	
	# Shoot projectile or do direct damage
	if use_projectiles and projectile_scene:
		shoot_projectile(enemy)
	else:
		# Simple direct damage
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

func shoot_projectile(enemy):
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.set_target(enemy, damage)
	projectile.speed = projectile_speed
