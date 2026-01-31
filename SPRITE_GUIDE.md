# Sprite Guide for Map and Path Graphics

## Current Implementation

The game currently uses simple geometric shapes for visual representation:
- **Map tiles**: ColorRect objects with solid colors (Dark Green for ground)
- **Path tiles**: ColorRect objects with solid colors (Sandy Brown for paths)
- **Enemies**: Polygon2D shapes (triangles, rectangles, diamonds)
- **Towers**: Polygon2D shapes with polygonal structures

This guide provides recommendations for replacing these geometric shapes with proper sprite assets.

## Recommended Sprite Types for Map/Path

### 1. Ground/Grass Tiles

**Purpose**: Replace the dark green ColorRect tiles that make up the playable area.

**Recommended Specifications**:
- **Size**: 64x64 pixels (matching TILE_SIZE constant in code)
- **Format**: PNG with transparency
- **Style**: Fantasy/medieval theme to match tower defense setting
- **Quantity**: 3-5 variations for visual variety

**What to Look For**:
- **Grass tiles**: Lush green grass with slight texture variation
- **Dirt patches**: Mixed grass/dirt for natural look
- **Stone patches**: Occasional stone or rocky elements
- **Tileability**: Sprites should tile seamlessly on all four edges
- **Lighting**: Consistent top-down lighting (light from upper-left)

**Example Asset Types**:
- Fantasy grass tileset
- Medieval ground tileset
- Top-down outdoor terrain pack
- Isometric or flat 2D styles both work

### 2. Path Tiles

**Purpose**: Replace the sandy brown ColorRect tiles that enemies walk on.

**Recommended Specifications**:
- **Size**: 64x64 pixels (matching TILE_SIZE constant)
- **Format**: PNG with transparency
- **Style**: Fantasy path/road theme
- **Quantity**: 8-12 tiles including:
  - Straight horizontal path
  - Straight vertical path
  - Corner pieces (4 directions)
  - T-junctions (4 directions)
  - 4-way intersection

**What to Look For**:
- **Dirt road style**: Worn earth path with defined edges
- **Stone path style**: Cobblestone or flagstone for medieval feel
- **Sandy path style**: Desert-like tan/brown path
- **Clear borders**: Visual distinction from grass tiles
- **Connectability**: Pieces should connect seamlessly
- **Wear patterns**: Center more worn than edges for realism

**Example Asset Types**:
- Medieval road tileset
- Dirt path tileset
- Stone path/cobblestone tileset
- RPG/tower defense path assets

### 3. Path Decorations (Optional Enhancement)

**Purpose**: Add visual interest to paths without affecting gameplay.

**Recommended Elements**:
- **Small rocks**: 16x16 to 32x32 pixels scattered along path edges
- **Grass tufts**: Small plants growing at path borders
- **Puddles**: Water reflections on dirt paths
- **Wheel ruts**: Tire/cart tracks in the dirt

### 4. Ground Decorations (Optional Enhancement)

**Purpose**: Break up monotony of grass tiles.

**Recommended Elements**:
- **Flowers**: Small colorful dots, 8x8 to 16x16 pixels
- **Bushes**: Small shrubs, 32x32 pixels
- **Small trees**: 64x64 to 128x64 pixels for larger decorations
- **Rocks**: Various sizes from 16x16 to 48x48 pixels

## Technical Specifications

### Resolution and Quality
- **Base Resolution**: 64x64 pixels per tile
- **DPI**: 72 DPI is standard for game sprites
- **Color Depth**: 32-bit RGBA (24-bit RGB + 8-bit alpha)
- **Anti-aliasing**: Use for smooth edges, but maintain crisp pixels for retro style

### File Format
- **Primary**: PNG (supports transparency)
- **Alternative**: WebP (smaller file size, good compression)
- **Avoid**: JPG (no transparency, compression artifacts)

### Naming Convention
```
tiles/
├── ground/
│   ├── grass_01.png
│   ├── grass_02.png
│   ├── grass_03.png
│   └── grass_dirt_01.png
├── path/
│   ├── path_straight_h.png
│   ├── path_straight_v.png
│   ├── path_corner_tl.png
│   ├── path_corner_tr.png
│   ├── path_corner_bl.png
│   ├── path_corner_br.png
│   ├── path_t_up.png
│   ├── path_t_down.png
│   ├── path_t_left.png
│   ├── path_t_right.png
│   └── path_cross.png
└── decorations/
    ├── flower_01.png
    ├── rock_01.png
    └── bush_01.png
```

## Art Style Recommendations

### Option 1: Pixel Art (Recommended for Indie Games)
**Pros**:
- Timeless aesthetic
- Smaller file sizes
- Easier to create/modify
- Matches many tower defense games
- Performance-friendly

**Cons**:
- May look dated to some players
- Requires consistent pixel art style across all assets

**Resolution**: 64x64 pixels actual size (can scale up 2x or 4x)

### Option 2: Hand-Painted/Illustrated
**Pros**:
- Professional appearance
- Rich detail and atmosphere
- Popular in modern tower defense games
- Flexible style options

**Cons**:
- Larger file sizes
- Harder to create custom assets
- Requires consistent art style

**Resolution**: 128x128 or 256x256 pixels (downsample to 64x64 if needed)

### Option 3: Low-Poly/Flat Design
**Pros**:
- Modern, clean aesthetic
- Easy to maintain consistency
- Good performance
- Simple to create

**Cons**:
- May lack visual depth
- Can feel too minimalist

**Resolution**: Vector-based or 64x64 rasterized

## Recommended Asset Sources

### Free Assets
1. **OpenGameArt.org**
   - Large collection of free game assets
   - Search for "tower defense tileset" or "medieval tiles"
   - CC0 and CC-BY licenses available

2. **itch.io Free Assets**
   - Browse Game Assets → 2D category
   - Filter by "Free" and "Tower Defense" or "Tileset"
   - Many high-quality free packs available

3. **Kenney.nl**
   - Excellent free game assets
   - Top-down tanks, strategy, and tower defense packs
   - CC0 license (public domain)

4. **Quaternius**
   - Some 2D sprite packs available
   - Clean, stylized designs
   - CC0 license

### Paid Assets (Budget Options)
1. **itch.io Paid Assets**
   - Typically $3-$20 per tileset
   - High quality, professional assets
   - Direct artist support

2. **GameDev Market**
   - Professional quality tilesets
   - $5-$50 per pack
   - Commercial licenses included

3. **Unity Asset Store**
   - 2D assets work in any engine
   - Regular sales (50-90% off)
   - Wide variety of styles

### Custom Commission
- **Fiverr**: $20-$100 for tileset
- **Reddit r/gameDevClassifieds**: Post request for quotes
- **ArtStation**: Browse portfolios and contact artists

## Specific Tileset Recommendations

### Highly Recommended Free Tilesets

1. **Kenney's Tower Defense Pack**
   - Source: kenney.nl
   - Includes: Ground tiles, paths, decorations
   - Style: Clean, colorful, top-down
   - License: CC0 (public domain)

2. **OpenGameArt Medieval/Fantasy Tiles**
   - Multiple options available
   - Search: "RPG tiles" or "tower defense"
   - Various medieval/fantasy themes

3. **itch.io "Pixel Art Tower Defense Pack"**
   - Often available for free or "pay what you want"
   - Includes complete tilesets

## Implementation in Godot

### Basic Sprite Tile Implementation

Replace the current ColorRect tile system:

```gdscript
# Current system (in scripts/main.gd):
func draw_tile(pos: Vector2, color: Color):
    var tile = ColorRect.new()
    tile.position = pos
    tile.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
    tile.color = color
    tile.z_index = -10
    add_child(tile)

# Replace with sprite-based system:
func draw_tile(pos: Vector2, texture: Texture2D):
    var sprite = Sprite2D.new()
    sprite.texture = texture
    sprite.position = pos + Vector2(TILE_SIZE/2, TILE_SIZE/2)  # Center sprite
    sprite.z_index = -10
    add_child(sprite)
```

### Using TileMap (Recommended for Performance)

For better performance with many tiles, use Godot's TileMap node:

```gdscript
# Add to main scene as child node
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
            tilemap.set_cell(1, tile_pos, 1, Vector2i(0, 0))  # Path tile
```

### Preloading Textures

```gdscript
# At top of scripts/main.gd
const TILE_SIZE = 64

# Preload tile textures
var grass_texture = preload("res://assets/tiles/ground/grass_01.png")
var path_texture = preload("res://assets/tiles/path/path_straight_h.png")

# Use multiple grass variations for visual variety
var grass_textures = [
    preload("res://assets/tiles/ground/grass_01.png"),
    preload("res://assets/tiles/ground/grass_02.png"),
    preload("res://assets/tiles/ground/grass_03.png"),
]

func get_random_grass_texture():
    return grass_textures[randi() % grass_textures.size()]
```

## Migration Strategy

### Phase 1: Replace Ground Tiles
1. Acquire or create grass tile sprites (64x64 PNG)
2. Create `assets/tiles/` directory in project
3. Import sprites into Godot
4. Modify `draw_tile()` function to use sprites
5. Test that tiles render correctly

### Phase 2: Replace Path Tiles
1. Acquire path tile sprites
2. Import into `assets/tiles/path/`
3. Update path drawing logic
4. Ensure path tiles connect properly

### Phase 3: Add Tile Variety
1. Add multiple grass variations
2. Randomly select grass tiles for natural look
3. Add decorative elements (optional)

### Phase 4: Optimize with TileMap (Optional)
1. Create TileMap node in main scene
2. Set up TileSet resource with all tiles
3. Refactor drawing code to use TileMap
4. Test performance improvement

## Visual Consistency Guidelines

### Color Palette
Maintain consistent colors across all sprites:
- **Grass**: Green shades (#4a7d3e to #6b9d59)
- **Path**: Brown/tan shades (#a0826d to #c9a07a)
- **Contrast**: Ensure paths are clearly distinguishable from grass

### Lighting
- **Direction**: Top-down with light from upper-left (common in tower defense)
- **Shadows**: Subtle shadows pointing lower-right
- **Consistency**: All tiles should have matching light direction

### Detail Level
- **Ground tiles**: Medium detail (grass texture, some dirt patches)
- **Path tiles**: Higher detail (worn areas, edge definition)
- **Balance**: Don't make tiles too busy - keep paths clear for gameplay

## Example Asset Integration

### Directory Structure
```
GodotTowerDefense/
├── assets/
│   ├── tiles/
│   │   ├── ground/
│   │   │   ├── grass_01.png
│   │   │   ├── grass_02.png
│   │   │   └── grass_03.png
│   │   ├── path/
│   │   │   ├── path_straight_h.png
│   │   │   └── path_straight_v.png
│   │   └── decorations/
│   │       ├── flower_01.png
│   │       └── rock_01.png
│   ├── enemies/
│   │   └── (future sprite replacements)
│   └── towers/
│       └── (future sprite replacements)
├── scenes/
├── scripts/
└── project.godot
```

## Testing Your New Sprites

After implementing sprites:

1. **Visual Test**: Run the game and verify tiles look good
2. **Tiling Test**: Check that tiles connect seamlessly without gaps
3. **Performance Test**: Ensure frame rate remains smooth
4. **Scale Test**: Zoom camera in/out to verify sprites look good at different scales
5. **Color Test**: Verify paths are clearly visible against grass

## Summary

**Quick Start Recommendation**:
1. Start with Kenney's free tower defense pack from kenney.nl
2. Use 64x64 pixel tiles
3. Implement grass tiles first, then path tiles
4. Focus on 2-3 grass variations and 1 path tile initially
5. Expand with decorations and tile variety later

**Key Points**:
- Match the 64x64 TILE_SIZE already defined in code
- Use PNG format with transparency
- Ensure tileability (seamless edges)
- Maintain fantasy/medieval theme consistency
- Start simple, add complexity gradually

**Next Steps After Sprites**:
Once map/path sprites are working well, consider:
- Enemy sprite replacements
- Tower sprite replacements
- UI improvements with themed buttons
- Background/skybox additions
- Particle effects for attacks
