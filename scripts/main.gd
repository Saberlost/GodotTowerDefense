extends Node2D

# Main game controller
const TILE_SIZE = 64
const MAP_SECTION_WIDTH = 15
const MAP_SECTION_HEIGHT = 10
const BASE_ENEMY_COUNT = 5
const ENEMY_SCALING_FACTOR = 2
const DRAGON_UNLOCK_WAVE = 5
const DEBUG_MODE = false  # Set to true to enable debug output
const PATH_BUILD_BLOCK_FACTOR = 0.8

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
@onready var projectile_container = $Projectiles
@onready var path_overlay = $PathOverlay
@onready var ui = $UI
@onready var camera = $Camera2D
@onready var ground_map := $GroundMap


# Enemy scene
var enemy_scenes = {
	"goblin": preload("res://scenes/enemies/goblin.tscn"),
	"orc": preload("res://scenes/enemies/orc.tscn"),
	"dragon": preload("res://scenes/enemies/dragon.tscn")
}

# Tower placement
var selected_tower_type = ""
var placing_blocker = false

# Camera controls
const CAMERA_ZOOM_MIN = 0.5
const CAMERA_ZOOM_MAX = 2.0
const CAMERA_ZOOM_STEP = 0.1
const CAMERA_PAN_SPEED = 400.0
var camera_drag_start = Vector2.ZERO
var is_camera_dragging = false

func _ready():
	setup_initial_map()
	update_ui()

func _process(delta):
	# Handle camera panning with WASD or Arrow keys
	var camera_movement = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		camera_movement.x += 1
	if Input.is_action_pressed("ui_left"):
		camera_movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		camera_movement.y += 1
	if Input.is_action_pressed("ui_up"):
		camera_movement.y -= 1
	
	if camera_movement.length() > 0:
		camera_movement = camera_movement.normalized()
		camera.position += camera_movement * CAMERA_PAN_SPEED * delta / camera.zoom.x

func _input(event):
	# Handle camera zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(CAMERA_ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(-CAMERA_ZOOM_STEP)
		# Handle middle mouse button drag
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_camera_dragging = true
				camera_drag_start = event.position
			else:
				is_camera_dragging = false
		# Handle tower/blocker placement
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if selected_tower_type != "":
				var mouse_pos = get_global_mouse_position()
				if place_tower(selected_tower_type, mouse_pos):
					selected_tower_type = ""
			elif placing_blocker:
				var mouse_pos = get_global_mouse_position()
				if place_path_blocker(mouse_pos):
					placing_blocker = false
	
	# Handle camera dragging
	if event is InputEventMouseMotion and is_camera_dragging:
		var drag_delta = camera_drag_start - event.position
		camera.position += drag_delta / camera.zoom.x
		camera_drag_start = event.position
	
	# Handle zoom with keyboard (+ and -)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS or event.keycode == KEY_KP_ADD:
			zoom_camera(CAMERA_ZOOM_STEP)
		elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
			zoom_camera(-CAMERA_ZOOM_STEP)

func _on_tower_selected(tower_type: String):
	selected_tower_type = tower_type
	placing_blocker = false

func _on_blocker_selected():
	placing_blocker = true
	selected_tower_type = ""

func zoom_camera(zoom_delta: float):
	if camera:
		var new_zoom = camera.zoom.x + zoom_delta
		new_zoom = clamp(new_zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)
		camera.zoom = Vector2(new_zoom, new_zoom)

func setup_initial_map():
	# Create first map section
	add_map_section()
	
func add_map_section():
	current_section += 1
	var section_data = generate_section_layout(current_section)
	map_sections.append(section_data)
	
	# Build continuous paths across all sections instead of replacing them.
	if paths.is_empty():
		paths = section_data.paths
	else:
		for i in range(min(paths.size(), section_data.paths.size())):
			# Skip first point to avoid duplicate seam between sections.
			for j in range(1, section_data.paths[i].size()):
				paths[i].append(section_data.paths[i][j])
	
	# Keep spawn fixed at the very start of the map.
	if not paths.is_empty() and not paths[0].is_empty():
		spawn_point = paths[0][0]
	
	# Draw the section
	draw_map_section(section_data)
	redraw_path_overlay()
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
		# Move upper lane further away from center so there is room to build between lanes.
		var y = MAP_SECTION_HEIGHT / 2 - 3 if i % 3 == 0 else MAP_SECTION_HEIGHT / 2 - 2
		upper_path.append(Vector2(base_x + i, y) * TILE_SIZE)
	section.paths.append(upper_path)
	
	# Lower path
	var lower_path = []
	for i in range(MAP_SECTION_WIDTH + 1):
		# Move lower lane further away from center so there is room to build between lanes.
		var y = MAP_SECTION_HEIGHT / 2 + 3 if i % 3 == 0 else MAP_SECTION_HEIGHT / 2 + 2
		lower_path.append(Vector2(base_x + i, y) * TILE_SIZE)
	section.paths.append(lower_path)
	
	return section

# Placera högre upp i filen (helst som en on_ready var)


func draw_map_section(section_data):
	# Här anger du rätt source_id och atlas_coords för gräs
	var ground_source_id = 0
	var ground_atlas_coords = Vector2i(1, 1)	# EXEMPEL: ändra till rätt för din gräsruta!
	
	for x in range(MAP_SECTION_WIDTH):
		for y in range(MAP_SECTION_HEIGHT):
			var px = MAP_SECTION_WIDTH * (section_data.id - 1) + x
			ground_map.set_cell(Vector2i(px, y), ground_source_id, ground_atlas_coords)
			
	# Path rendering, t.ex. sand/stenväg
	var path_source_id = 0
	var path_atlas_coords = Vector2i(3,3)		# EXEMPEL: ändra till rätt för din path-tile!
	
	for path in section_data.paths:
		for point in path:
			var cell = Vector2i(point.x / TILE_SIZE, point.y / TILE_SIZE)
			ground_map.set_cell(cell, path_source_id, path_atlas_coords)


func redraw_path_overlay():
	if not path_overlay:
		return
	
	for child in path_overlay.get_children():
		child.queue_free()
	
	# Distinkta färger för att snabbt se varje rutt
	var path_colors = [
		Color(0.1, 0.8, 1.0, 0.9),
		Color(1.0, 0.4, 0.2, 0.9),
		Color(0.9, 0.9, 0.1, 0.9)
	]
	
	for path_index in range(paths.size()):
		var path = paths[path_index]
		if path.size() < 2:
			continue
		
		var line = Line2D.new()
		line.width = 8.0
		line.default_color = path_colors[path_index % path_colors.size()]
		line.antialiased = true
		line.z_index = 3
		
		for point in path:
			line.add_point(point + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0))
		
		path_overlay.add_child(line)

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
		
		# Choose random path
		enemy.path = paths[randi() % paths.size()]
		if enemy.path.size() > 0:
			enemy.position = enemy.path[0]
		else:
			enemy.position = spawn_point
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
	var snapped_pos = snap_to_grid(pos)
	if gold >= tower_cost and is_valid_tower_position(snapped_pos):
		gold -= tower_cost
		var tower = load("res://scenes/towers/" + tower_type + ".tscn").instantiate()
		tower.position = snapped_pos
		tower.set_enemy_container(enemy_container)
		if tower.has_method("set_projectile_container"):
			tower.set_projectile_container(projectile_container)
		tower_container.add_child(tower)
		update_ui()
		if ui and ui.has_method("show_message"):
			ui.show_message("Tower placerad", Color(0.5, 1.0, 0.5, 1.0), 1.0)
		return true
	
	if ui and ui.has_method("show_message"):
		ui.show_message(get_tower_placement_error(tower_type, snapped_pos))
	return false

func is_valid_tower_position(pos: Vector2) -> bool:
	# Check not on a path cell (cell-based check gives tighter placement control).
	if is_position_on_path_cell(pos):
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
	var snapped_pos = snap_to_grid(pos)
	if gold >= 300:
		gold -= 300
		# Create a blocker that forces path recalculation
		var blocker = ColorRect.new()
		blocker.position = snapped_pos
		blocker.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
		blocker.color = Color.DARK_GRAY
		add_child(blocker)
		
		# Recalculate paths to go around blocker
		recalculate_paths(snapped_pos)
		update_ui()
		if ui and ui.has_method("show_message"):
			ui.show_message("Blocker placerad", Color(0.5, 1.0, 0.5, 1.0), 1.0)
		return true
	
	if ui and ui.has_method("show_message"):
		ui.show_message("Inte nog med guld (kräver 300)")
	return false

func get_tower_placement_error(tower_type: String, pos: Vector2) -> String:
	var tower_cost = get_tower_cost(tower_type)
	if gold < tower_cost:
		return "Inte nog med guld (kräver " + str(tower_cost) + ")"
	
	if is_position_on_path_cell(pos):
		return "Kan inte placera pa stigen"
	
	for tower in tower_container.get_children():
		if tower.position.distance_to(pos) < TILE_SIZE:
			return "For nara ett annat torn"
	
	return "Ogiltig position"

func snap_to_grid(pos: Vector2) -> Vector2:
	var cell_x = int(pos.x / TILE_SIZE)
	var cell_y = int(pos.y / TILE_SIZE)
	return Vector2(
		cell_x * TILE_SIZE + TILE_SIZE / 2.0,
		cell_y * TILE_SIZE + TILE_SIZE / 2.0
	)

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / TILE_SIZE), int(pos.y / TILE_SIZE))

func is_position_on_path_cell(pos: Vector2) -> bool:
	var tower_cell = world_to_cell(pos)
	for path in paths:
		for point in path:
			if world_to_cell(point) == tower_cell:
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
	redraw_path_overlay()
	queue_redraw()
