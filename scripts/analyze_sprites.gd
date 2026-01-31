@tool
extends EditorScript

# This script helps identify the structure of sprite sheets
# To use: Open this script in Godot and click "File > Run" (or press Ctrl+Shift+X)

func _run():
	print("=== Sprite Sheet Analysis Tool ===")
	print()
	
	# Analyze sprits_monsters.jpg
	var monsters_texture = load("res://sprites/sprits_monsters.jpg")
	if monsters_texture:
		print("sprits_monsters.jpg loaded successfully")
		print("  Dimensions: ", monsters_texture.get_width(), "x", monsters_texture.get_height())
		print("  Possible layouts:")
		analyze_possible_layouts(monsters_texture, "sprits_monsters.jpg")
	else:
		print("ERROR: Could not load sprits_monsters.jpg")
	
	print()
	
	# Analyze tilemap.jpg
	var tilemap_texture = load("res://sprites/tilemap.jpg")
	if tilemap_texture:
		print("tilemap.jpg loaded successfully")
		print("  Dimensions: ", tilemap_texture.get_width(), "x", tilemap_texture.get_height())
		print("  Possible layouts:")
		analyze_possible_layouts(tilemap_texture, "tilemap.jpg")
	else:
		print("ERROR: Could not load tilemap.jpg")
	
	print()
	print("=== Analysis Complete ===")
	print()
	print("NEXT STEPS:")
	print("1. Open each sprite sheet in the Godot texture editor")
	print("2. Visually identify the actual tile size and layout")
	print("3. Update SPRITE_SHEETS_NEW.md with the correct dimensions")
	print("4. Create AtlasTexture resources for each sprite/tile")
	print("5. Update enemy and tile drawing code to use the new sprites")

func analyze_possible_layouts(texture: Texture2D, filename: String):
	var width = texture.get_width()
	var height = texture.get_height()
	
	# Common tile sizes in tower defense games
	var common_sizes = [32, 64, 100, 128, 256]
	
	for tile_size in common_sizes:
		if width % tile_size == 0 and height % tile_size == 0:
			var cols = width / tile_size
			var rows = height / tile_size
			var total_tiles = cols * rows
			print("    - %dx%d grid (%d tiles) at %dx%d pixels each" % [cols, rows, total_tiles, tile_size, tile_size])
	
	# Also check for non-square arrangements
	if width != height:
		print("    - Non-square image, may contain different arrangements")
