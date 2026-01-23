extends Node2D

# Main game controller
const TILE_SIZE = 64
const MAP_SECTION_WIDTH = 15
const MAP_SECTION_HEIGHT = 10
const BASE_ENEMY_COUNT = 5
const ENEMY_SCALING_FACTOR = 2
const DRAGON_UNLOCK_WAVE = 5
const DEBUG_MODE = false  # Set to true to enable debug output

var current_wave = 0
var gold = 200
var lives = 20
var map_sections = []
var current_section = 0

# Spawner and paths
var spawn_point = Vector2.ZERO
var paths = []

# References
@onready var enemy_container = $Enemies
@onready var tower_container = $Towers
@onready var ui = $UI
@onready var camera = $Camera2D

# Enemy scene
var enemy_scenes = {
	"goblin": preload("res://scenes/enemies/goblin.tscn"),
	"orc": preload("res://scenes/enemies/orc.tscn"),
	"dragon": preload("res://scenes/enemies/dragon.tscn")
}

# Tower placement
var selected_tower_type = ""
var placing_blocker = false

func _ready():
	setup_initial_map()
	update_ui()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_tower_type != "":
			var mouse_pos = get_global_mouse_position()
			place_tower(selected_tower_type, mouse_pos)
			selected_tower_type = ""
		elif placing_blocker:
			var mouse_pos = get_global_mouse_position()
			place_path_blocker(mouse_pos)
			placing_blocker = false

func _on_tower_selected(tower_type: String):
	selected_tower_type = tower_type
	placing_blocker = false

func _on_blocker_selected():
	placing_blocker = true
	selected_tower_type = ""

func setup_initial_map():
	# Create first map section
	add_map_section()
	
func add_map_section():
	current_section += 1
	var section_data = generate_section_layout(current_section)
	map_sections.append(section_data)
	
	# Update spawn and end points
	spawn_point = section_data.spawn
	paths = section_data.paths
	
	# Draw the section
	draw_map_section(section_data)
	queue_redraw()
	
	# Update camera to show the current map area
	update_camera_position()

func generate_section_layout(section_num):
	var section = {
		"id": section_num,
		"spawn": Vector2(0, MAP_SECTION_HEIGHT / 2) * TILE_SIZE,
		"end": Vector2(MAP_SECTION_WIDTH * section_num, MAP_SECTION_HEIGHT / 2) * TILE_SIZE,
		"paths": []
	}
	
	# Generate multiple paths (upper and lower)
	var base_x = MAP_SECTION_WIDTH * (section_num - 1)
	
	# Main path (middle)
	var main_path = []
	for i in range(MAP_SECTION_WIDTH + 1):
		main_path.append(Vector2(base_x + i, MAP_SECTION_HEIGHT / 2) * TILE_SIZE)
	section.paths.append(main_path)
	
	# Upper path
	var upper_path = []
	for i in range(MAP_SECTION_WIDTH + 1):
		var y = MAP_SECTION_HEIGHT / 2 - 2 if i % 3 == 0 else MAP_SECTION_HEIGHT / 2 - 1
		upper_path.append(Vector2(base_x + i, y) * TILE_SIZE)
	section.paths.append(upper_path)
	
	# Lower path
	var lower_path = []
	for i in range(MAP_SECTION_WIDTH + 1):
		var y = MAP_SECTION_HEIGHT / 2 + 2 if i % 3 == 0 else MAP_SECTION_HEIGHT / 2 + 1
		lower_path.append(Vector2(base_x + i, y) * TILE_SIZE)
	section.paths.append(lower_path)
	
	return section

func draw_map_section(section_data):
	# Draw ground tiles
	for x in range(MAP_SECTION_WIDTH):
		for y in range(MAP_SECTION_HEIGHT):
			var tile_pos = Vector2(
				MAP_SECTION_WIDTH * (section_data.id - 1) + x,
				y
			) * TILE_SIZE
			draw_tile(tile_pos, Color.DARK_GREEN)
	
	# Draw paths
	for path in section_data.paths:
		for point in path:
			draw_tile(point, Color.SANDY_BROWN)

func draw_tile(pos: Vector2, color: Color):
	var tile = ColorRect.new()
	tile.position = pos
	tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
	tile.color = color
	tile.z_index = -10  # Render tiles below everything else
	add_child(tile)

func _draw():
	# Draw path lines for debugging
	for path in paths:
		for i in range(len(path) - 1):
			draw_line(path[i] + Vector2(TILE_SIZE/2, TILE_SIZE/2), 
					  path[i+1] + Vector2(TILE_SIZE/2, TILE_SIZE/2), 
					  Color.YELLOW, 2.0)

func update_camera_position():
	if camera:
		# Center camera on all accumulated sections (1 through current_section)
		# As map expands, camera shifts right to keep the middle of the expanded map centered
		# Formula: camera_x = (total_sections * section_width * tile_size) / 2
		var map_width = MAP_SECTION_WIDTH * current_section * TILE_SIZE
		var map_height = MAP_SECTION_HEIGHT * TILE_SIZE
		camera.position = Vector2(map_width / 2.0, map_height / 2.0)
		if DEBUG_MODE:
			print("Camera positioned at ", camera.position, " for ", current_section, " sections")

func start_wave():
	current_wave += 1
	
	# Add new map section every wave
	add_map_section()
	
	# Spawn enemies
	spawn_wave_enemies()
	
	update_ui()

func spawn_wave_enemies():
	var enemy_count = BASE_ENEMY_COUNT + current_wave * ENEMY_SCALING_FACTOR
	var enemy_types = ["goblin", "orc"] if current_wave < DRAGON_UNLOCK_WAVE else ["goblin", "orc", "dragon"]
	
	for i in range(enemy_count):
		await get_tree().create_timer(1.0).timeout
		var enemy_type = enemy_types[randi() % enemy_types.size()]
		spawn_enemy(enemy_type)

func spawn_enemy(type: String):
	if enemy_scenes.has(type):
		var enemy = enemy_scenes[type].instantiate()
		enemy.position = spawn_point
		
		# Choose random path
		enemy.path = paths[randi() % paths.size()]
		enemy.connect("reached_end", _on_enemy_reached_end)
		enemy.connect("died", _on_enemy_died)
		
		enemy_container.add_child(enemy)
		if DEBUG_MODE:
			print("Spawned ", type, " at ", spawn_point, " with path of ", enemy.path.size(), " points")

func _on_enemy_reached_end(enemy):
	lives -= 1
	enemy.queue_free()
	update_ui()
	
	if lives <= 0:
		game_over()

func _on_enemy_died(enemy, gold_reward):
	gold += gold_reward
	enemy.queue_free()
	update_ui()

func update_ui():
	if ui:
		ui.update_stats(gold, lives, current_wave)

func game_over():
	print("Game Over!")
	get_tree().paused = true

func place_tower(tower_type: String, pos: Vector2):
	# Check if we have enough gold and position is valid
	var tower_cost = get_tower_cost(tower_type)
	if gold >= tower_cost and is_valid_tower_position(pos):
		gold -= tower_cost
		var tower = load("res://scenes/towers/" + tower_type + ".tscn").instantiate()
		tower.position = pos
		tower.set_enemy_container(enemy_container)
		tower_container.add_child(tower)
		update_ui()
		return true
	return false

func is_valid_tower_position(pos: Vector2) -> bool:
	# Check not on path
	for path in paths:
		for point in path:
			if pos.distance_to(point) < TILE_SIZE:
				return false
	
	# Check not overlapping other towers
	for tower in tower_container.get_children():
		if tower.position.distance_to(pos) < TILE_SIZE:
			return false
	
	return true

func get_tower_cost(type: String) -> int:
	var costs = {
		"archer_tower": 50,
		"mage_tower": 100,
		"cannon_tower": 150,
		"path_blocker": 300
	}
	return costs.get(type, 50)

func place_path_blocker(pos: Vector2):
	# Expensive way to block and extend paths
	if gold >= 300:
		gold -= 300
		# Create a blocker that forces path recalculation
		var blocker = ColorRect.new()
		blocker.position = pos
		blocker.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
		blocker.color = Color.DARK_GRAY
		add_child(blocker)
		
		# Recalculate paths to go around blocker
		recalculate_paths(pos)
		update_ui()
		return true
	return false

func recalculate_paths(blocked_pos: Vector2):
	# Improved path recalculation with bounds checking
	for path in paths:
		for i in range(len(path)):
			if path[i].distance_to(blocked_pos) < TILE_SIZE:
				# Try to offset the path point, ensuring it stays within bounds
				var new_pos = path[i] + Vector2(0, TILE_SIZE)
				# Check if new position is within map bounds
				if new_pos.y / TILE_SIZE < MAP_SECTION_HEIGHT:
					path[i] = new_pos
				else:
					# If can't go down, try going up
					path[i] = path[i] - Vector2(0, TILE_SIZE)
	queue_redraw()
