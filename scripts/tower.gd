extends Node2D

@export var damage = 10.0
@export var attack_speed = 1.0  # attacks per second
@export var range = 150.0
@export var projectile_speed = 300.0
@export var use_projectiles = false
@export var projectile_scene: PackedScene = null
@export var rotate_sprite_to_target = true
@export var max_level = 5
@export var upgrade_cost_base = 35
@export var damage_multiplier_per_level = 1.35
@export var attack_speed_multiplier_per_level = 1.12
@export var range_increase_per_level = 15.0
const DEBUG_ZERO_DAMAGE = false

var enemy_container = null
var projectile_container = null
var current_target = null
var attack_timer = 0.0
var level = 1
var level_label: Label

@onready var range_circle = $RangeCircle
@onready var sprite = $Sprite2D

func _ready():
	if attack_speed <= 0:
		attack_speed = 1.0  # Default to prevent division by zero
	if DEBUG_ZERO_DAMAGE:
		damage = 0.0
	attack_timer = 1.0 / attack_speed
	if range_circle:
		range_circle.scale = Vector2(range / 50.0, range / 50.0)
	setup_level_label()

func _physics_process(delta):
	attack_timer -= delta
	
	if attack_timer <= 0:
		attack_timer = 1.0 / attack_speed
		find_and_attack_enemy()

func set_enemy_container(container):
	enemy_container = container

func set_projectile_container(container):
	projectile_container = container

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
			# For other sprites (like Polygon2D), rotate if enabled
			if rotate_sprite_to_target:
				sprite.rotation = global_position.angle_to_point(enemy.global_position)
	
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
	if projectile_container:
		projectile_container.add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.set_target(enemy, damage)
	projectile.speed = projectile_speed

func can_upgrade() -> bool:
	return level < max_level

func get_upgrade_cost() -> int:
	return upgrade_cost_base * level

func upgrade_tower() -> bool:
	if not can_upgrade():
		return false
	
	level += 1
	damage *= damage_multiplier_per_level
	attack_speed *= attack_speed_multiplier_per_level
	range += range_increase_per_level
	attack_timer = 1.0 / max(attack_speed, 0.1)
	
	if range_circle:
		range_circle.scale = Vector2(range / 50.0, range / 50.0)
	
	if level_label:
		update_level_label_visual()
	
	return true

func setup_level_label():
	level_label = Label.new()
	level_label.position = Vector2(-18, -46)
	add_child(level_label)
	update_level_label_visual()

func update_level_label_visual():
	if not level_label:
		return
	
	if level >= 5:
		level_label.text = "★"
		level_label.modulate = Color(1.0, 0.25, 0.25, 1.0)
		level_label.scale = Vector2(1.35, 1.35)
		level_label.position = Vector2(-10, -50)
		return
	
	level_label.text = "★".repeat(level)
	level_label.modulate = Color(1.0, 0.9, 0.2, 1.0)
	level_label.scale = Vector2(1.0, 1.0)
	level_label.position = Vector2(-18, -46)
