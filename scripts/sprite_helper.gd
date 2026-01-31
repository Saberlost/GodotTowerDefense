extends Node

# Sprite Helper - Utilities for loading and using the new sprite sheets
# This script provides helper functions to easily access sprites from:
# - sprits_monsters.jpg
# - tilemap.jpg

# Preload sprite sheets
const MONSTERS_SHEET = preload("res://sprites/sprits_monsters.jpg")
const TILEMAP_SHEET = preload("res://sprites/tilemap.jpg")

# Configuration - Update these after inspecting sprite sheets in Godot
# These are educated guesses based on common sprite sheet patterns
const MONSTER_SPRITE_SIZE = Vector2(100, 100)  # Adjust if different
const TILE_SIZE_PX = Vector2(64, 64)  # Matches TILE_SIZE constant in main.gd

# Monster sprite positions (row, column in grid)
# UPDATE THESE after visual inspection of sprits_monsters.jpg
const GOBLIN_POS = Vector2i(0, 0)   # Example: first sprite
const DRAGON_POS = Vector2i(1, 0)   # Example: second row, first column
# Add more as needed after inspecting the sheet

# Tile positions (row, column in grid)  
# UPDATE THESE after visual inspection of tilemap.jpg
const GRASS_TILES = [
	Vector2i(0, 0),  # Grass variant 1
	Vector2i(0, 1),  # Grass variant 2
	Vector2i(0, 2),  # Grass variant 3
]
const PATH_TILE = Vector2i(1, 0)  # Example: path tile
# Add more tile types as needed

## Monster Sprite Functions

# Get an AtlasTexture for a monster sprite at grid position (row, col)
func get_monster_sprite(grid_pos: Vector2i) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = MONSTERS_SHEET
	atlas.region = _get_region(grid_pos, MONSTER_SPRITE_SIZE)
	return atlas

# Get goblin sprite (example)
func get_goblin_sprite() -> AtlasTexture:
	return get_monster_sprite(GOBLIN_POS)

# Get dragon sprite (example)
func get_dragon_sprite() -> AtlasTexture:
	return get_monster_sprite(DRAGON_POS)

## Tile Sprite Functions

# Get an AtlasTexture for a tile at grid position (row, col)
func get_tile_sprite(grid_pos: Vector2i) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = TILEMAP_SHEET
	atlas.region = _get_region(grid_pos, TILE_SIZE_PX)
	return atlas

# Get a random grass tile for variety
func get_random_grass_tile() -> AtlasTexture:
	var random_pos = GRASS_TILES[randi() % GRASS_TILES.size()]
	return get_tile_sprite(random_pos)

# Get grass tile (specific variant)
func get_grass_tile(variant: int = 0) -> AtlasTexture:
	if variant >= 0 and variant < GRASS_TILES.size():
		return get_tile_sprite(GRASS_TILES[variant])
	return get_tile_sprite(GRASS_TILES[0])

# Get path tile
func get_path_tile() -> AtlasTexture:
	return get_tile_sprite(PATH_TILE)

## Helper Functions

# Calculate the region for a sprite at grid position
func _get_region(grid_pos: Vector2i, sprite_size: Vector2) -> Rect2:
	var x = grid_pos.x * sprite_size.x
	var y = grid_pos.y * sprite_size.y
	return Rect2(x, y, sprite_size.x, sprite_size.y)

## Usage Examples:

# Example 1: Load goblin sprite in enemy scene
# var sprite_helper = preload("res://scripts/sprite_helper.gd").new()
# $Sprite2D.texture = sprite_helper.get_goblin_sprite()

# Example 2: Load random grass tile in main.gd
# var sprite_helper = preload("res://scripts/sprite_helper.gd").new()
# func draw_tile(pos: Vector2, type: String):
#     var sprite = Sprite2D.new()
#     if type == "grass":
#         sprite.texture = sprite_helper.get_random_grass_tile()
#     elif type == "path":
#         sprite.texture = sprite_helper.get_path_tile()
#     sprite.position = pos + Vector2(TILE_SIZE/2, TILE_SIZE/2)
#     sprite.z_index = -10
#     add_child(sprite)

# Example 3: Pre-create sprites for performance
# var grass_sprites = []
# var sprite_helper = preload("res://scripts/sprite_helper.gd").new()
# for i in range(3):
#     grass_sprites.append(sprite_helper.get_grass_tile(i))
