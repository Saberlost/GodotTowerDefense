extends Node2D

# Main game controller
const TILE_SIZE = 64
const MAP_SECTION_WIDTH = 15
const MAP_SECTION_HEIGHT = 10
const MAP_FILL_MARGIN_TILES = 2
const MAP_TOP_OFFSET_TILES = 2
const BASE_ENEMY_COUNT = 5
const ENEMY_SCALING_FACTOR = 2
const ENEMY_HP_SCALING_PER_WAVE = 0.12
const ENEMY_BURST_INTERVAL = 1.0
const ENEMY_BURST_SIZE_GROWTH_WAVES = 4
const DRAGON_UNLOCK_WAVE = 5
const DEBUG_MODE = false
const DEBUG_INFINITE_RESOURCES = false
const DEBUG_STARTING_GOLD = 999999
const DEBUG_STARTING_LIVES = 999999
const PLAY_AREA_BORDER_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const PLAY_AREA_BORDER_WIDTH = 6.0
const TOWER_MIN_SPACING_CELLS = 1.0
const MONSTER_WALK_BAND_HEIGHT_TILES = 6
const WALK_WALL_COLOR = Color(0.55, 0.30, 0.10, 1.0)
const WALK_WALL_WIDTH = 12.0

# Tile atlas values for GroundMap.tres
const GROUND_SOURCE_ID = 0
const GROUND_ATLAS_COORDS = Vector2i(1, 1)

# Camera controls
const CAMERA_ZOOM_MIN = 0.5
const CAMERA_ZOOM_MAX = 2.0
const CAMERA_ZOOM_STEP = 0.1
const CAMERA_PAN_SPEED = 400.0

# Pathfinding directions (4-way grid)
const CARDINAL_DIRS = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

var current_wave = 0
var gold = 200
var lives = 20
var selected_tower_type = ""
var tower_cells: Dictionary = {}
var tower_nodes_by_cell: Dictionary = {}
var map_grid_width = MAP_SECTION_WIDTH
var map_grid_height = MAP_SECTION_HEIGHT

var camera_drag_start = Vector2.ZERO
var is_camera_dragging = false

@onready var enemy_container = $Enemies
@onready var tower_container = $Towers
@onready var projectile_container = $Projectiles
@onready var path_overlay = $PathOverlay
@onready var ui = $UI
@onready var camera = $Camera2D
@onready var ground_map: TileMapLayer = $GroundMap

var enemy_scenes = {
	"goblin": preload("res://scenes/enemies/goblin.tscn"),
	"golem": preload("res://scenes/enemies/golem.tscn"),
	"orc": preload("res://scenes/enemies/orc.tscn"),
	"dragon": preload("res://scenes/enemies/dragon.tscn")
}

func _ready():
	randomize()
	if DEBUG_INFINITE_RESOURCES:
		gold = DEBUG_STARTING_GOLD
		lives = DEBUG_STARTING_LIVES
	setup_initial_map()
	update_ui()
	redraw_play_area_overlay()

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		update_map_size_from_viewport()
		draw_base_map()
		update_camera_position()
		redraw_play_area_overlay()

func _draw():
	pass

func redraw_play_area_overlay():
	if not path_overlay:
		return
	
	for child in path_overlay.get_children():
		child.queue_free()
	
	var cell_size = get_grid_cell_size()
	var map_top_offset_pixels = MAP_TOP_OFFSET_TILES * cell_size
	var x_max = map_grid_width * cell_size
	var y_min = map_top_offset_pixels
	var y_max = map_top_offset_pixels + map_grid_height * cell_size
	
	# Play area border (always above the tilemap layer).
	add_overlay_line(Vector2(0, y_min), Vector2(x_max, y_min), PLAY_AREA_BORDER_COLOR, PLAY_AREA_BORDER_WIDTH)
	add_overlay_line(Vector2(0, y_max), Vector2(x_max, y_max), PLAY_AREA_BORDER_COLOR, PLAY_AREA_BORDER_WIDTH)
	add_overlay_line(Vector2(0, y_min), Vector2(0, y_max), PLAY_AREA_BORDER_COLOR, PLAY_AREA_BORDER_WIDTH)
	add_overlay_line(Vector2(x_max, y_min), Vector2(x_max, y_max), PLAY_AREA_BORDER_COLOR, PLAY_AREA_BORDER_WIDTH)
	
	# Temporary top/bottom walls that mark monster walk area.
	var walk_row_min = get_walkable_row_min()
	var walk_row_max = get_walkable_row_max()
	var wall_top_y = map_top_offset_pixels + walk_row_min * cell_size
	var wall_bottom_y = map_top_offset_pixels + (walk_row_max + 1) * cell_size
	add_overlay_line(Vector2(0, wall_top_y), Vector2(x_max, wall_top_y), WALK_WALL_COLOR, WALK_WALL_WIDTH)
	add_overlay_line(Vector2(0, wall_bottom_y), Vector2(x_max, wall_bottom_y), WALK_WALL_COLOR, WALK_WALL_WIDTH)

func add_overlay_line(from_point: Vector2, to_point: Vector2, color: Color, width: float):
	var line = Line2D.new()
	line.width = width
	line.default_color = color
	line.z_index = 10
	line.antialiased = true
	line.add_point(from_point)
	line.add_point(to_point)
	path_overlay.add_child(line)

func _process(delta):
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_camera(CAMERA_ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_camera(-CAMERA_ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_camera_dragging = true
				camera_drag_start = event.position
			else:
				is_camera_dragging = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			if selected_tower_type != "":
				if place_tower(selected_tower_type, mouse_pos):
					selected_tower_type = ""
			else:
				try_upgrade_tower_at(mouse_pos)
	
	if event is InputEventMouseMotion and is_camera_dragging:
		var drag_delta = camera_drag_start - event.position
		camera.position += drag_delta / camera.zoom.x
		camera_drag_start = event.position
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS or event.keycode == KEY_KP_ADD:
			zoom_camera(CAMERA_ZOOM_STEP)
		elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
			zoom_camera(-CAMERA_ZOOM_STEP)

func _on_tower_selected(tower_type: String):
	selected_tower_type = tower_type

func zoom_camera(zoom_delta: float):
	if not camera:
		return
	
	var new_zoom = camera.zoom.x + zoom_delta
	new_zoom = clamp(new_zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)
	camera.zoom = Vector2(new_zoom, new_zoom)

func setup_initial_map():
	update_map_size_from_viewport()
	draw_base_map()
	update_camera_position()

func draw_base_map():
	if not ground_map:
		return
	
	ground_map.clear()
	for x in range(map_grid_width):
		for y in range(map_grid_height):
			ground_map.set_cell(Vector2i(x, y + MAP_TOP_OFFSET_TILES), GROUND_SOURCE_ID, GROUND_ATLAS_COORDS)

func update_map_size_from_viewport():
	var cell_size = get_grid_cell_size()
	var viewport_size = get_viewport_rect().size
	var width_tiles = int(ceil(viewport_size.x / cell_size)) + MAP_FILL_MARGIN_TILES
	var map_top_offset_pixels = MAP_TOP_OFFSET_TILES * cell_size
	var playable_height_pixels = max(viewport_size.y - map_top_offset_pixels, float(cell_size))
	var height_tiles = int(ceil(playable_height_pixels / cell_size)) + MAP_FILL_MARGIN_TILES
	
	map_grid_width = max(width_tiles, MAP_SECTION_WIDTH)
	map_grid_height = max(height_tiles, MAP_SECTION_HEIGHT)

func update_camera_position():
	if not camera:
		return
	
	var cell_size = get_grid_cell_size()
	var map_width = map_grid_width * cell_size
	var map_height = map_grid_height * cell_size
	var map_top_offset_pixels = MAP_TOP_OFFSET_TILES * cell_size
	camera.position = Vector2(map_width / 2.0, map_top_offset_pixels + map_height / 2.0)
	if DEBUG_MODE:
		print("Camera positioned at ", camera.position)

func start_wave():
	current_wave += 1
	spawn_wave_enemies()
	update_ui()

func spawn_wave_enemies():
	var enemy_count = BASE_ENEMY_COUNT + current_wave * ENEMY_SCALING_FACTOR
	var enemy_types = ["goblin", "golem", "orc"] if current_wave < DRAGON_UNLOCK_WAVE else ["goblin", "golem", "orc", "dragon"]
	var burst_size = 1 + int((current_wave - 1) / ENEMY_BURST_SIZE_GROWTH_WAVES)
	var spawned = 0
	
	while spawned < enemy_count:
		await get_tree().create_timer(ENEMY_BURST_INTERVAL).timeout
		
		var to_spawn_now = min(burst_size, enemy_count - spawned)
		for i in range(to_spawn_now):
			var enemy_type = enemy_types[randi() % enemy_types.size()]
			spawn_enemy(enemy_type)
			spawned += 1

func spawn_enemy(type: String):
	if not enemy_scenes.has(type):
		return
	
	var spawn_cell = get_random_spawn_cell()
	if spawn_cell.x < 0:
		if ui and ui.has_method("show_message"):
			ui.show_message("Inga gangbara spawnpunkter kvar")
		return
	
	var path_cells = find_path_cells(spawn_cell)
	if path_cells.is_empty():
		return
	
	var enemy = enemy_scenes[type].instantiate()
	apply_enemy_wave_scaling(enemy)
	enemy.path = cells_to_world_path(path_cells)
	enemy.position = enemy.path[0]
	enemy.connect("reached_end", _on_enemy_reached_end)
	enemy.connect("died", _on_enemy_died)
	enemy_container.add_child(enemy)
	
	if DEBUG_MODE:
		print("Spawned ", type, " from ", spawn_cell, " with path length ", path_cells.size())

func apply_enemy_wave_scaling(enemy):
	if not enemy:
		return
	
	var hp_multiplier = 1.0 + max(current_wave - 1, 0) * ENEMY_HP_SCALING_PER_WAVE
	enemy.max_health *= hp_multiplier
	enemy.current_health = enemy.max_health
	if enemy.has_method("update_health_bar"):
		enemy.update_health_bar()

func _on_enemy_reached_end(enemy):
	if not DEBUG_INFINITE_RESOURCES:
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
	var tower_cost = get_tower_cost(tower_type)
	var snapped_pos = snap_to_grid(pos)
	var tower_cell = world_to_cell(snapped_pos)
	
	var can_afford = DEBUG_INFINITE_RESOURCES or gold >= tower_cost
	if can_afford and is_valid_tower_position(tower_cell):
		if not DEBUG_INFINITE_RESOURCES:
			gold -= tower_cost
		var tower = load("res://scenes/towers/" + tower_type + ".tscn").instantiate()
		tower.position = snapped_pos
		tower.set_enemy_container(enemy_container)
		if tower.has_method("set_projectile_container"):
			tower.set_projectile_container(projectile_container)
		add_tower_footprint(tower)
		tower_container.add_child(tower)
		tower_cells[tower_cell] = true
		tower_nodes_by_cell[tower_cell] = tower
		update_ui()
		if ui and ui.has_method("show_message"):
			ui.show_message("Tower placerad", Color(0.5, 1.0, 0.5, 1.0), 1.0)
		return true
	
	if ui and ui.has_method("show_message"):
		ui.show_message(get_tower_placement_error(tower_type, tower_cell))
	return false

func try_upgrade_tower_at(world_pos: Vector2) -> bool:
	var tower = get_tower_at_world_pos(world_pos)
	if not tower:
		return false
	if not tower.has_method("can_upgrade") or not tower.has_method("get_upgrade_cost") or not tower.has_method("upgrade_tower"):
		return false
	
	if not tower.can_upgrade():
		if ui and ui.has_method("show_message"):
			ui.show_message("Tornet ar redan max level")
		return true
	
	var upgrade_cost = tower.get_upgrade_cost()
	if not DEBUG_INFINITE_RESOURCES and gold < upgrade_cost:
		if ui and ui.has_method("show_message"):
			ui.show_message("Inte nog med guld for upgrade (" + str(upgrade_cost) + ")")
		return true
	
	if tower.upgrade_tower():
		if not DEBUG_INFINITE_RESOURCES:
			gold -= upgrade_cost
		update_ui()
		if ui and ui.has_method("show_message"):
			ui.show_message("Torn uppgraderat till nasta level", Color(0.5, 1.0, 0.5, 1.0), 1.0)
	return true

func get_tower_at_world_pos(world_pos: Vector2):
	var cell = world_to_cell(world_pos)
	if tower_nodes_by_cell.has(cell):
		return tower_nodes_by_cell[cell]
	return null

func has_tower_spacing_conflict(candidate_cell: Vector2i) -> bool:
	var min_distance = get_grid_cell_size() * TOWER_MIN_SPACING_CELLS
	var candidate_world = cell_to_world(candidate_cell)
	for existing_cell in tower_cells.keys():
		var existing_world = cell_to_world(existing_cell)
		if candidate_world.distance_to(existing_world) < min_distance:
			return true
	return false

func is_valid_tower_position(cell: Vector2i) -> bool:
	if not is_cell_in_bounds(cell):
		return false
	if tower_cells.has(cell):
		return false
	if has_tower_spacing_conflict(cell):
		return false
	if would_block_all_paths(cell):
		return false
	return true

func get_tower_placement_error(tower_type: String, cell: Vector2i) -> String:
	var tower_cost = get_tower_cost(tower_type)
	if gold < tower_cost:
		return "Inte nog med guld (kraver " + str(tower_cost) + ")"
	if not is_cell_in_bounds(cell):
		return "Utanforkartan"
	if tower_cells.has(cell):
		return "Cellen ar redan upptagen"
	if has_tower_spacing_conflict(cell):
		return "For nara ett annat torn"
	if would_block_all_paths(cell):
		return "Kan inte blockera all passage till hoger"
	return "Ogiltig position"

func get_tower_cost(type: String) -> int:
	var costs = {
		"archer_tower": 50,
		"mage_tower": 100,
		"cannon_tower": 150
	}
	return costs.get(type, 50)

func add_tower_footprint(tower: Node2D):
	var half = get_grid_cell_size() * 0.5 - 2.0
	var frame = Line2D.new()
	frame.width = 2.0
	frame.default_color = Color(0.95, 0.95, 1.0, 0.9)
	frame.add_point(Vector2(-half, -half))
	frame.add_point(Vector2(half, -half))
	frame.add_point(Vector2(half, half))
	frame.add_point(Vector2(-half, half))
	frame.add_point(Vector2(-half, -half))
	tower.add_child(frame)

func would_block_all_paths(candidate_cell: Vector2i) -> bool:
	tower_cells[candidate_cell] = true
	var still_has_path = exists_any_spawn_to_goal_path()
	tower_cells.erase(candidate_cell)
	return not still_has_path

func exists_any_spawn_to_goal_path() -> bool:
	var row_min = get_walkable_row_min()
	var row_max = get_walkable_row_max()
	for y in range(row_min, row_max + 1):
		var start_cell = Vector2i(0, y)
		if not is_cell_walkable(start_cell):
			continue
		if not find_path_cells(start_cell).is_empty():
			return true
	return false

func get_random_spawn_cell() -> Vector2i:
	var candidates: Array[Vector2i] = []
	var row_min = get_walkable_row_min()
	var row_max = get_walkable_row_max()
	for y in range(row_min, row_max + 1):
		var start_cell = Vector2i(0, y)
		if not is_cell_walkable(start_cell):
			continue
		if not find_path_cells(start_cell).is_empty():
			candidates.append(start_cell)
	
	if candidates.is_empty():
		return Vector2i(-1, -1)
	return candidates[randi() % candidates.size()]

func find_path_cells(start_cell: Vector2i) -> Array[Vector2i]:
	if not is_cell_walkable(start_cell):
		return []
	
	var queue: Array[Vector2i] = [start_cell]
	var came_from: Dictionary = {}
	var sentinel = Vector2i(-9999, -9999)
	came_from[start_cell] = sentinel
	
	var goal_cell = Vector2i(-1, -1)
	while not queue.is_empty():
		var current = queue.pop_front()
		if current.x == map_grid_width - 1:
			goal_cell = current
			break
		
		for dir in CARDINAL_DIRS:
			var next_cell = current + dir
			if not is_cell_walkable(next_cell):
				continue
			if came_from.has(next_cell):
				continue
			came_from[next_cell] = current
			queue.append(next_cell)
	
	if goal_cell.x < 0:
		return []
	
	var path_reversed: Array[Vector2i] = []
	var step = goal_cell
	while step != sentinel:
		path_reversed.append(step)
		step = came_from[step]
	
	path_reversed.reverse()
	return path_reversed

func cells_to_world_path(path_cells: Array[Vector2i]) -> Array:
	var world_path: Array = []
	for cell in path_cells:
		world_path.append(cell_to_world(cell))
	return world_path

func snap_to_grid(pos: Vector2) -> Vector2:
	return cell_to_world(world_to_cell(pos))

func world_to_cell(pos: Vector2) -> Vector2i:
	var cell_size = get_grid_cell_size()
	var map_top_offset_pixels = MAP_TOP_OFFSET_TILES * cell_size
	return Vector2i(floori(pos.x / cell_size), floori((pos.y - map_top_offset_pixels) / cell_size))

func cell_to_world(cell: Vector2i) -> Vector2:
	var cell_size = get_grid_cell_size()
	var map_top_offset_pixels = MAP_TOP_OFFSET_TILES * cell_size
	return Vector2(
		cell.x * cell_size + cell_size / 2.0,
		map_top_offset_pixels + cell.y * cell_size + cell_size / 2.0
	)

func get_grid_cell_size() -> float:
	if ground_map and ground_map.tile_set:
		return float(ground_map.tile_set.tile_size.x)
	return float(TILE_SIZE)

func is_cell_in_bounds(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= map_grid_width or cell.y < 0 or cell.y >= map_grid_height:
		return false
	# Only allow placement/pathing on cells that actually have a drawn ground tile.
	if not ground_map:
		return false
	var tile_cell = Vector2i(cell.x, cell.y + MAP_TOP_OFFSET_TILES)
	return ground_map.get_cell_source_id(tile_cell) != -1

func is_cell_walkable(cell: Vector2i) -> bool:
	if not is_cell_in_bounds(cell):
		return false
	if cell.y < get_walkable_row_min() or cell.y > get_walkable_row_max():
		return false
	return not tower_cells.has(cell)

func get_walkable_row_min() -> int:
	if map_grid_height <= MONSTER_WALK_BAND_HEIGHT_TILES:
		return 0
	return int((map_grid_height - MONSTER_WALK_BAND_HEIGHT_TILES) / 2)

func get_walkable_row_max() -> int:
	return min(map_grid_height - 1, get_walkable_row_min() + MONSTER_WALK_BAND_HEIGHT_TILES - 1)
