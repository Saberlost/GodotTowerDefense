# Sprite Quick Reference

Quick answer to: "What type of sprites should I get to draw the map / path in a good way?"

## TL;DR - Quick Start

### What You Need
1. **Ground/Grass Tiles**: 64x64 PNG, 3-5 variations
2. **Path Tiles**: 64x64 PNG, dirt/stone road style

### Best Free Option
**Kenney.nl Tower Defense Pack**
- URL: https://kenney.nl/
- Search for "tower defense" or "strategy"
- License: CC0 (completely free, no attribution required)
- Includes: Complete tileset with ground, paths, decorations

### Technical Specs
```
Size: 64x64 pixels (matches TILE_SIZE in scripts/main.gd)
Format: PNG with transparency
Style: Top-down, fantasy/medieval theme
Tileability: Must tile seamlessly on all edges
```

## Visual Style Options

| Style | Example | Pros | Best For |
|-------|---------|------|----------|
| **Pixel Art** | Retro 8-bit/16-bit look | Small files, timeless, easy to create | Indie games, retro aesthetic |
| **Hand-Painted** | Illustrated, detailed | Professional look, rich detail | Premium games, story-driven |
| **Flat/Minimal** | Clean geometric shapes | Modern, performance-friendly | Simple aesthetics |

## Recommended: Start with Pixel Art
- Matches indie game aesthetic
- Easier to find free assets
- Better performance
- Easier to modify/extend

## File Structure
```
assets/
├── tiles/
│   ├── ground/
│   │   ├── grass_01.png (64x64)
│   │   ├── grass_02.png (64x64)
│   │   └── grass_03.png (64x64)
│   └── path/
│       └── dirt_path_01.png (64x64)
```

## Free Asset Sources (Ranked)

1. **Kenney.nl** ⭐ BEST
   - Completely free, CC0 license
   - High quality, consistent style
   - Ready to use

2. **OpenGameArt.org** ⭐ GOOD
   - Large selection
   - Free with attribution (mostly)
   - Variable quality

3. **itch.io** ⭐ GOOD
   - Many free options
   - Filter: Game Assets > 2D > Free
   - Support indie artists

## What Makes Good Map/Path Sprites?

### ✅ Good Sprites Have:
- Clear visual distinction (grass vs path obvious)
- Seamless tiling on all edges
- Consistent lighting direction
- Appropriate level of detail (not too busy)
- Fantasy/medieval theme matching
- 64x64 pixel size

### ❌ Avoid:
- Non-tileable sprites (visible seams)
- Wrong perspective (isometric when you need top-down)
- Wrong size (need to be 64x64 or easily scaled)
- Clashing art styles (modern sci-fi for medieval game)
- Too much detail (distracting from gameplay)

## Color Palette Guide

### Grass/Ground
- Primary: Green (#4a7d3e to #6b9d59)
- Accents: Brown dirt, gray stone

### Paths
- Primary: Brown/tan (#a0826d to #c9a07a)
- Must contrast clearly with grass

## Implementation Priority

1. **Phase 1**: Ground tiles (grass)
   - Replace ColorRect with Sprite2D
   - Use 2-3 grass variations

2. **Phase 2**: Path tiles
   - Replace path ColorRects
   - Single dirt path texture to start

3. **Phase 3**: Variety (optional)
   - Add more grass variations
   - Add decorations (rocks, flowers)

## Code Change Preview

```gdscript
# OLD (current):
func draw_tile(pos: Vector2, color: Color):
    var tile = ColorRect.new()
    tile.color = color

# NEW (with sprites):
func draw_tile(pos: Vector2, texture: Texture2D):
    var sprite = Sprite2D.new()
    sprite.texture = texture
```

## Testing Checklist

After adding sprites:
- [ ] Tiles display at correct size (64x64)
- [ ] No gaps between tiles
- [ ] Paths clearly visible vs grass
- [ ] Performance still smooth
- [ ] Looks good when zoomed in/out

## Next Steps

1. Download Kenney's tower defense pack
2. Extract and place in `assets/tiles/` folder
3. See [SPRITE_GUIDE.md](SPRITE_GUIDE.md) for detailed implementation
4. Start with grass tiles, then paths
5. Test in-game

## Need More Help?

See [SPRITE_GUIDE.md](SPRITE_GUIDE.md) for:
- Detailed specifications
- Complete implementation guide
- Advanced techniques
- Alternative asset sources
- Migration strategy

---

**Quick Answer**: Get 64x64 pixel PNG sprites of grass tiles and dirt path tiles. Start with Kenney.nl's free tower defense pack for best results.
