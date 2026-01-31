# New Sprite Sheets Documentation

This document describes the newly added sprite sheets and how to use them in the game.

## Overview

Two new sprite sheet files have been added to the project:

1. **sprits_monsters.jpg** - Monster/enemy sprite sheet (Note: filename has typo, should be "sprites_monsters" but keeping as-is to avoid breaking references)
2. **tilemap.jpg** - Tilemap/terrain sprite sheet

Both files are 1024x1024 JPEG images located in the `sprites/` directory.

## sprits_monsters.jpg

### Description
This sprite sheet contains various monster/enemy sprites intended to replace the current Polygon2D shapes used for enemies (Goblin and Dragon).

### Specifications
- **File**: `sprites/sprits_monsters.jpg`
- **Dimensions**: 1024x1024 pixels
- **Format**: JPEG
- **Godot UID**: `uid://ca8gm6yl0utws`

### Usage Instructions

#### Step 1: Determine Sprite Layout
1. Open the sprite sheet in Godot's editor
2. Identify the grid structure (e.g., 10x10 grid of 100x100 pixel sprites)
3. Note which sprites correspond to which enemies

#### Step 2: Create AtlasTexture Resources
For each enemy sprite in the sheet:

```gdscript
# Example: Extract a single sprite from the sheet
var sprite_texture = preload("res://sprites/sprits_monsters.jpg")
var atlas = AtlasTexture.new()
atlas.atlas = sprite_texture
atlas.region = Rect2(x_offset, y_offset, width, height)
```

#### Step 3: Replace Polygon2D in Enemy Scenes
Update enemy scene files to use sprites instead of polygons:

**For Goblin** (`scenes/enemies/goblin.tscn`):
- Replace `Polygon2D` node with `Sprite2D` or `AnimatedSprite2D`
- Assign the appropriate sprite from sprits_monsters.jpg
- Maintain collision shape and health bar

**For Dragon** (`scenes/enemies/dragon.tscn`):
- Replace `Polygon2D` node with `Sprite2D` or `AnimatedSprite2D`
- Assign the appropriate sprite from sprits_monsters.jpg
- Maintain collision shape and health bar

#### Example Integration (Goblin)
```gdscript
# In goblin.tscn, replace:
[node name="Sprite2D" type="Polygon2D" parent="."]
color = Color(0, 0.8, 0, 1)
polygon = PackedVector2Array(...)

# With:
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("path_to_atlas_or_sprite")
# Or use AnimatedSprite2D for animated sprites
```

## tilemap.jpg

### Description
This sprite sheet contains terrain tiles for the game map, including grass tiles, path tiles, and decorative elements.

### Specifications
- **File**: `sprites/tilemap.jpg`
- **Dimensions**: 1024x1024 pixels
- **Format**: JPEG
- **Godot UID**: `uid://bvqc8j1yk2x8w`
- **Target Tile Size**: 64x64 pixels (matching TILE_SIZE constant in main.gd)

### Usage Instructions

#### Step 1: Determine Tile Layout
1. Open the sprite sheet in Godot's editor
2. Identify the grid structure (likely 16x16 grid of 64x64 pixel tiles)
3. Note which tiles are for:
   - Ground/grass
   - Paths (straight, corners, intersections)
   - Decorations (flowers, rocks, etc.)

#### Step 2: Option A - Using Individual Sprites
Replace ColorRect tiles with Sprite2D nodes:

```gdscript
# In scripts/main.gd, update draw_tile function:
func draw_tile(pos: Vector2, tile_texture: Texture2D):
    var sprite = Sprite2D.new()
    sprite.texture = tile_texture
    sprite.position = pos + Vector2(TILE_SIZE/2, TILE_SIZE/2)  # Center sprite
    sprite.z_index = -10
    add_child(sprite)

# Preload tile textures using AtlasTexture
var grass_atlas = AtlasTexture.new()
grass_atlas.atlas = preload("res://sprites/tilemap.jpg")
grass_atlas.region = Rect2(0, 0, 64, 64)  # First tile

var path_atlas = AtlasTexture.new()
path_atlas.atlas = preload("res://sprites/tilemap.jpg")
path_atlas.region = Rect2(64, 0, 64, 64)  # Second tile
```

#### Step 3: Option B - Using TileMap Node (Recommended)
For better performance with many tiles:

1. Create a TileSet resource in Godot
2. Add tilemap.jpg as the source texture
3. Define tile regions for each type
4. Add TileMap node to main.tscn
5. Update drawing code to use TileMap.set_cell()

```gdscript
# Example TileMap usage
@onready var tilemap = $TileMap

func draw_map_section(section_data):
    # Draw ground layer
    for x in range(MAP_SECTION_WIDTH):
        for y in range(MAP_SECTION_HEIGHT):
            var tile_pos = Vector2i(
                MAP_SECTION_WIDTH * (section_data.id - 1) + x,
                y
            )
            tilemap.set_cell(0, tile_pos, 0, Vector2i(0, 0))  # Ground tile
    
    # Draw path layer
    for path in section_data.paths:
        for point in path:
            var tile_pos = Vector2i(point / TILE_SIZE)
            tilemap.set_cell(1, tile_pos, 0, Vector2i(1, 0))  # Path tile
```

## Implementation Priority

### High Priority
1. **Document sprite sheet layout** - Open both files in Godot editor and document the exact layout
2. **Update goblin enemy** - Replace Polygon2D with sprite from sprits_monsters.jpg
3. **Update dragon enemy** - Replace Polygon2D with sprite from sprits_monsters.jpg

### Medium Priority
4. **Implement basic tilemap usage** - Replace at least grass and path ColorRects with sprites
5. **Add sprite variety** - Use multiple grass tile variations for visual interest

### Low Priority (Future Enhancement)
6. **Full TileMap implementation** - Complete rewrite using TileMap node for optimal performance
7. **Add decorations** - Use decoration tiles from tilemap.jpg to enhance visual appeal

## Testing Checklist

After implementing sprites:

- [ ] Open project in Godot editor
- [ ] Verify both sprite sheets import correctly (no errors in console)
- [ ] Run the game and start a wave
- [ ] Verify enemies show proper sprites (not Polygon2D shapes)
- [ ] Verify ground and path tiles show proper textures (not ColorRect blocks)
- [ ] Check that sprites scale properly with camera zoom
- [ ] Verify collision detection still works correctly
- [ ] Test that health bars are positioned correctly relative to new sprites

## Notes

- Both files are JPEG format. For transparency in sprites, consider converting to PNG in the future.
- Current implementation uses ColorRect for tiles and Polygon2D for enemies - these are the targets for replacement.
- The game already has successful sprite integration examples: Orc enemy and Archer tower use animated sprites.
- Follow the pattern established by existing sprite integrations in the codebase.

## Related Documentation

- **[SPRITE_GUIDE.md](SPRITE_GUIDE.md)** - Comprehensive sprite integration guide
- **[SPRITE_INTEGRATION.md](SPRITE_INTEGRATION.md)** - Summary of current sprite usage
- **[SPRITE_QUICK_REFERENCE.md](SPRITE_QUICK_REFERENCE.md)** - Quick sprite recommendations
