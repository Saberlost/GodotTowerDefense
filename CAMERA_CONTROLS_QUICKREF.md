# Camera Controls - Quick Reference

## 🎮 How to Use the New Camera Controls

### Zoom In/Out
```
🖱️ Mouse Wheel Up/Down  →  Zoom in/out
⌨️ + or - Keys          →  Zoom in/out

Range: 0.5x (far) to 2.0x (close)
```

### Move Camera Around
```
⌨️ Arrow Keys / WASD  →  Pan camera
🖱️ Middle Mouse Drag  →  Move camera freely
```

## 🎯 Use Cases

### 1. See the Full Map
- **Zoom out** (scroll down or press `-`) 
- **Pan around** (arrow keys or middle mouse drag)
- View multiple map sections at once
- Plan your strategy

### 2. Precise Tower Placement
- **Zoom in** (scroll up or press `+`)
- Get close to see exact tile positions
- Place towers with precision

### 3. Follow the Action
- **Pan along the path** (arrow keys)
- Watch enemies move
- See tower attacks in detail

### 4. Navigate Expanding Map
- Each wave adds a new section
- Zoom out to see new areas
- Pan to explore the extended battlefield

## 📊 Visual Guide

### Zoomed Out (0.5x) - Strategic View
```
┌────────────────────────────────────────┐
│                                        │
│  [Section 1]  [Section 2]  [Section 3] │
│  ────────────→────────────→────────→  │
│   Spawn                          End   │
│                                        │
└────────────────────────────────────────┘
Perfect for: Strategy planning, seeing full path
```

### Normal Zoom (1.0x) - Balanced View
```
┌─────────────────────┐
│                     │
│  [Current Section]  │
│  ────────→──────→  │
│   Spawn       End   │
│                     │
└─────────────────────┘
Perfect for: General gameplay, tower placement
```

### Zoomed In (2.0x) - Detail View
```
┌──────────┐
│   ●●●    │
│  ──→──   │
│   ■■■    │
│          │
└──────────┘
Perfect for: Precise placement, watching combat
```

## ⚡ Tips

1. **Use mouse wheel** for quick zoom adjustments while playing
2. **Hold middle mouse** and drag to quickly reposition view
3. **Use arrow keys** for smooth, controlled panning
4. **Zoom out** at the start of each wave to see the new map section
5. **Zoom in** when placing expensive towers for accuracy

## 🔧 Customization

You can adjust these constants in `scripts/main.gd`:

```gdscript
const CAMERA_ZOOM_MIN = 0.5      # Make smaller for more zoom out
const CAMERA_ZOOM_MAX = 2.0      # Make larger for more zoom in
const CAMERA_ZOOM_STEP = 0.1     # Zoom sensitivity
const CAMERA_PAN_SPEED = 400.0   # Higher = faster panning
```

## ✅ What Works

- ✅ Zoom during gameplay without pausing
- ✅ Pan while enemies are moving
- ✅ Place towers at any zoom level
- ✅ Zoom level persists between waves
- ✅ Multiple control methods (mouse + keyboard)
- ✅ Smooth, responsive controls

## 🎮 Original Controls (Still Work!)

- **Left Click**: Place selected tower or blocker
- **UI Buttons**: Select towers, start waves, view stats

All original functionality is preserved - the camera controls are an addition!
