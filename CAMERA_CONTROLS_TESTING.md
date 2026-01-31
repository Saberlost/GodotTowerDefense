# Camera Controls Testing Guide

## Overview
This document describes how to test the new camera zoom and pan controls added to the Godot Tower Defense game.

## Features Implemented

### 1. Camera Zoom
- **Mouse Wheel**: Scroll up to zoom in, scroll down to zoom out
- **Keyboard**: Press `+` or `=` to zoom in, press `-` to zoom out
- **Zoom Range**: 0.5x (zoomed out) to 2.0x (zoomed in)
- **Zoom Step**: 0.1x per scroll/keypress

### 2. Camera Panning
- **Arrow Keys / WASD**: Move camera in 4 directions
  - Right Arrow / D: Move camera right
  - Left Arrow / A: Move camera left
  - Down Arrow / S: Move camera down
  - Up Arrow / W: Move camera up
- **Middle Mouse Button Drag**: Click and drag to pan the camera
- **Pan Speed**: 400 pixels per second (adjusted by zoom level)

## Testing Steps

### Test 1: Mouse Wheel Zoom
1. Launch the game in Godot (press F5)
2. Scroll the mouse wheel up
3. **Expected**: Camera should zoom in (map appears larger)
4. Scroll the mouse wheel down
5. **Expected**: Camera should zoom out (map appears smaller)
6. Continue scrolling in each direction
7. **Expected**: Zoom should stop at 0.5x (min) and 2.0x (max)

### Test 2: Keyboard Zoom
1. Press the `+` or `=` key repeatedly
2. **Expected**: Camera should zoom in smoothly
3. Press the `-` key repeatedly
4. **Expected**: Camera should zoom out smoothly
5. **Expected**: Same zoom limits as mouse wheel (0.5x to 2.0x)

### Test 3: Keyboard Panning
1. Press and hold the Right Arrow key (or D)
2. **Expected**: Camera should move right smoothly
3. Release and press Left Arrow key (or A)
4. **Expected**: Camera should move left smoothly
5. Test Up Arrow (W) and Down Arrow (S) keys
6. **Expected**: Camera should move up and down smoothly
7. Try diagonal movement by pressing two keys at once (e.g., Right + Up)
8. **Expected**: Camera should move diagonally at the same speed as cardinal directions

### Test 4: Middle Mouse Button Drag
1. Click and hold the middle mouse button
2. Move the mouse in any direction
3. **Expected**: Camera should follow the mouse movement (inverted - dragging right moves camera left, as if you're dragging the world)
4. Release the middle mouse button
5. **Expected**: Camera should stop moving

### Test 5: Zoom with Panning
1. Zoom in using mouse wheel or keyboard
2. Use arrow keys to pan around
3. **Expected**: Panning speed should be adjusted for zoom level (slower when zoomed in)
4. Zoom out and pan again
5. **Expected**: Panning speed should increase when zoomed out

### Test 6: Integration with Gameplay
1. Start a wave and spawn enemies
2. Zoom out to see more of the map
3. **Expected**: Should be able to see enemies spawn and move along paths
4. Pan to follow enemies as they move
5. Zoom in on a specific area
6. Try to place towers while zoomed in/out
7. **Expected**: Tower placement should work correctly at any zoom level
8. **Expected**: Mouse position should correctly translate to world position

### Test 7: Camera Persistence
1. Zoom and pan to a specific location
2. Start a new wave (which triggers automatic camera repositioning in `update_camera_position()`)
3. **Expected**: Your manual zoom level should be preserved
4. **Note**: The camera position will be automatically centered when a new map section is added, but zoom should remain

## Known Behaviors

### Automatic Camera Positioning
- The game automatically centers the camera when new map sections are added each wave
- This is by design to keep the expanding map visible
- Your zoom level is preserved during this automatic positioning

### Zoom and Mouse Position
- When zooming, the camera zooms toward its center, not the mouse cursor position
- This is a simple implementation that can be enhanced later if needed

## Edge Cases to Test

1. **Rapid Input**: Try rapidly scrolling/pressing keys
   - Should handle smoothly without errors
   
2. **Multiple Inputs**: Try zooming while panning
   - Should work simultaneously
   
3. **Boundary Testing**: Pan far away from the map
   - Should allow free panning (no hard boundaries currently)
   
4. **During Combat**: Test controls while enemies are moving and towers are attacking
   - Should not interfere with game logic

## Success Criteria

✅ All zoom controls work smoothly (mouse wheel + keyboard)
✅ All pan controls work smoothly (arrow keys + WASD + middle mouse drag)
✅ Zoom limits are enforced (0.5x to 2.0x)
✅ Camera controls don't interfere with tower placement
✅ Camera controls don't interfere with UI buttons
✅ No console errors or warnings appear during camera usage

## Troubleshooting

### Issue: Camera doesn't move
- Check that you're pressing the correct keys
- Ensure the game window has focus
- Check Godot console for errors

### Issue: Zoom doesn't work
- Verify mouse wheel is working (test in other applications)
- Check Godot console for errors
- Try keyboard zoom as alternative

### Issue: Middle mouse drag doesn't work
- Some mice or trackpads may not support middle click
- Use arrow keys/WASD as alternative
- Check if middle mouse button is mapped to other function

### Issue: Camera moves too fast/slow
- Adjust `CAMERA_PAN_SPEED` constant in main.gd
- Current value: 400.0 pixels per second
- Try values between 200-800 for different feels

### Issue: Zoom too sensitive
- Adjust `CAMERA_ZOOM_STEP` constant in main.gd
- Current value: 0.1
- Try values between 0.05-0.2 for different zoom speeds

## Future Enhancements

Potential improvements for the camera system:
- Zoom toward mouse cursor position instead of camera center
- Smooth/interpolated camera movements
- Camera shake effects for combat
- Min/max bounds to keep camera focused on playable area
- Camera presets (overview, follow enemy, etc.)
- Save/restore camera position and zoom
- Edge panning (move camera when mouse near screen edge)
