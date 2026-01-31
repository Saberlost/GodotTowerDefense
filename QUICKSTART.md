# Quick Start Guide

## Prerequisites
- Godot Engine 4.2 or higher
- Basic understanding of Godot and GDScript

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Saberlost/GodotTowerDefense.git
   cd GodotTowerDefense
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to the project folder
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run the game**
   - Press F5 or click the "Play" button in Godot
   - The game will start at the main scene

## First Steps

1. **Start a Wave**: Click the "Start Wave" button to spawn enemies
2. **Place Towers**: 
   - Click one of the tower buttons (Archer/Mage/Cannon)
   - Click on green ground tiles to place
3. **Earn Gold**: Defeat enemies to earn gold
4. **Expand Strategy**: Use path blockers to force enemies on longer routes
5. **Survive**: Keep enemies from reaching the end!

## Development

### Adding a New Enemy Type

1. Create a new scene in `scenes/enemies/`
2. Inherit from the enemy.gd script
3. Adjust the exported variables (speed, health, gold_reward)
4. Add the scene to the `enemy_scenes` dictionary in main.gd
5. Update spawn logic to include the new enemy type

Example:
```gdscript
# In main.gd, add to enemy_scenes dictionary:
var enemy_scenes = {
    "goblin": preload("res://scenes/enemies/goblin.tscn"),
    "orc": preload("res://scenes/enemies/orc.tscn"),
    "dragon": preload("res://scenes/enemies/dragon.tscn"),
    "demon": preload("res://scenes/enemies/demon.tscn")  # New!
}
```

### Adding a New Tower Type

1. Create a new scene in `scenes/towers/`
2. Inherit from the tower.gd script
3. Adjust the exported variables (damage, attack_speed, range)
4. Add the cost to `get_tower_cost()` in main.gd
5. Add a button in the UI scene

### Modifying Map Expansion

Edit the `generate_section_layout()` function in main.gd to change:
- Path patterns
- Number of paths
- Section dimensions

### Adjusting Difficulty

Modify these constants in main.gd:
```gdscript
const BASE_ENEMY_COUNT = 5          # Starting enemies per wave
const ENEMY_SCALING_FACTOR = 2      # Additional enemies per wave
const DRAGON_UNLOCK_WAVE = 5        # Wave when dragons appear
```

## Testing

Since this is a Godot game, testing is done within the Godot editor:

1. **Play Mode Testing**:
   - Press F5 to run the game
   - Test all features interactively

2. **Debug Mode**:
   - Use print statements to debug
   - Check the Output panel in Godot
   - Enable "Visible Collision Shapes" for debugging hitboxes

3. **Performance Testing**:
   - Run multiple waves to test performance
   - Check FPS in the debugger
   - Monitor memory usage

## Troubleshooting

### Enemies not moving
- Check that paths are properly generated
- Verify enemy scenes have the correct script attached
- Ensure paths array is populated

### Towers not attacking
- Verify `set_enemy_container()` is called when placing towers
- Check tower range values
- Ensure enemy_container has enemies as children

### UI not updating
- Check that UI signals are connected in main.tscn
- Verify `update_ui()` is called after state changes
- Check UI script is attached to the UI node

### Game crashes on start
- Ensure all scene paths in preload statements are correct
- Verify all required nodes exist in scenes
- Check the Godot console for error messages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [Tower Defense Design Patterns](https://en.wikipedia.org/wiki/Tower_defense)

## License

See LICENSE file for details.
