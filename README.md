# GodotTowerDefense

A fantasy-themed tower defense game built with Godot Engine 4.2+

## Features

### Core Gameplay
- **Expanding Map System**: Each wave adds a new section to the map, progressively expanding the battlefield
- **Multiple Paths**: Enemies can take different routes (upper, middle, lower paths) to reach the end
- **Wave-based Spawning**: Progressive difficulty with more enemies and stronger types as waves advance

### Fantasy Themed Content

#### Enemies
- **Goblin**: Fast but weak (50 HP, 80 speed, 10 gold reward)
- **Orc**: Slower but tankier (100 HP, 60 speed, 20 gold reward) - Features animated sprite with walk cycle
- **Dragon**: Fast and very tanky (200 HP, 100 speed, 50 gold reward, appears from wave 5+)

#### Towers
- **Archer Tower** (50 gold): Basic ranged tower with animated soldier sprite, shoots arrow projectiles (2 attacks/sec, 15 damage, 200 range)
- **Mage Tower** (100 gold): Moderate damage with longer range (1 attack/sec, 25 damage, 250 range)
- **Cannon Tower** (150 gold): Slow but powerful attacks (0.5 attacks/sec, 50 damage, 180 range)

### Special Mechanics
- **Path Blocker** (300 gold): Expensive special building that blocks enemy paths, forcing them to take longer routes around it
  - Dynamically recalculates enemy paths when placed
  - Strategic tool to extend enemy travel time and maximize tower damage

## How to Play

1. **Start the Game**: Click "Start Wave" to begin the first wave
2. **Place Towers**: 
   - Select a tower type from the UI buttons
   - Click on valid ground (not on paths) to place the tower
3. **Manage Resources**: 
   - Earn gold by defeating enemies
   - Spend gold on more towers or path blockers
4. **Strategic Blocking**: 
   - Use Path Blockers to extend enemy routes
   - Place towers to cover the extended paths
5. **Survive**: Protect your base by preventing enemies from reaching the end

## Game Controls
- **Left Click**: Place selected tower or blocker
- **Middle Mouse Button Drag**: Pan camera to see different parts of the map
- **Mouse Wheel**: Zoom in/out (0.5x to 2.0x)
- **Arrow Keys / WASD**: Pan camera to view the full path
- **+/- Keys**: Zoom in/out
- **UI Buttons**: Select towers, start waves, view stats

## Technical Details
- Built with Godot Engine 4.2+
- Uses GDScript for all game logic
- Features sprite-based graphics for orc enemy and archer tower
- Animated sprites with walking and attack cycles
- Visual arrow projectiles for archer tower
- Expandable architecture for adding more content

## New Sprite Sheets (Ready for Integration)
Two new sprite sheets have been added to the project and are ready for integration:

### sprits_monsters.jpg
- **Size**: 1024x1024 pixels
- **Purpose**: Monster and enemy sprites
- **Status**: Import file configured, ready to use
- **Intended Use**: Replace Polygon2D shapes for Goblin and Dragon enemies
- **Documentation**: See [SPRITE_SHEETS_NEW.md](SPRITE_SHEETS_NEW.md) for integration guide

### tilemap.jpg  
- **Size**: 1024x1024 pixels
- **Purpose**: Terrain tiles (grass, paths, decorations)
- **Status**: Import file configured, ready to use
- **Intended Use**: Replace ColorRect tiles with proper sprite textures
- **Documentation**: See [SPRITE_SHEETS_NEW.md](SPRITE_SHEETS_NEW.md) and [EXAMPLE_tilemap_integration.txt](EXAMPLE_tilemap_integration.txt)

**Next Steps for Integration**:
1. Open the project in Godot Editor
2. Run `scripts/analyze_sprites.gd` (File > Run) to analyze sprite sheet layout
3. Update sprite coordinates in `scripts/sprite_helper.gd`
4. Apply example implementations from `EXAMPLE_*.tscn` and `EXAMPLE_*.txt` files
5. Test and refine sprite usage

See [SPRITE_SHEETS_NEW.md](SPRITE_SHEETS_NEW.md) for detailed instructions.

## Documentation
- **[SPRITE_QUICK_REFERENCE.md](SPRITE_QUICK_REFERENCE.md)**: Quick answer for sprite recommendations (start here!)
- **[SPRITE_GUIDE.md](SPRITE_GUIDE.md)**: Comprehensive guide for replacing geometric shapes with sprite assets
- **[SPRITE_SHEETS_NEW.md](SPRITE_SHEETS_NEW.md)**: Guide for the newly added sprite sheets (sprits_monsters.jpg and tilemap.jpg)
- **[SPRITE_COORDINATES.txt](SPRITE_COORDINATES.txt)**: Configuration for sprite sheet tile coordinates
- **[EXAMPLE_tilemap_integration.txt](EXAMPLE_tilemap_integration.txt)**: Example code for integrating tilemap sprites

## Project Structure
```
├── scenes/
│   ├── enemies/        # Enemy scene files
│   ├── towers/         # Tower scene files
│   ├── projectile.tscn # Arrow projectile scene
│   └── main.tscn      # Main game scene
├── scripts/
│   ├── main.gd        # Core game controller
│   ├── enemy.gd       # Enemy behavior
│   ├── tower.gd       # Tower behavior
│   ├── projectile.gd  # Projectile behavior
│   └── ui.gd          # UI management
├── sprites/
│   ├── Arrow(Projectile)/           # Arrow sprite assets
│   ├── Characters(100x100)/         # Character sprite sheets
│   │   ├── Orc/                     # Orc animations
│   │   └── Soldier/                 # Soldier animations
│   ├── BaseSet.png                  # Tileset (unused currently)
│   ├── sprits_monsters.jpg          # NEW: Monster/enemy sprite sheet
│   └── tilemap.jpg                  # NEW: Tilemap/terrain sprite sheet
└── project.godot      # Godot project configuration
```

## Future Enhancements
- More enemy types with special abilities
- Additional tower types (splash damage, slowing effects)
- Upgrade system for towers
- Victory conditions
- Save/load functionality
- Sound effects and music
- Improved visual assets (see [SPRITE_GUIDE.md](SPRITE_GUIDE.md) for sprite recommendations)
