# Camera and Visibility Fix

## Problem Identified

From the screenshot, two main issues were found:

1. **Enemies not visible**: Enemies were spawning at position (0, 320) but the camera was positioned at (640, 360), meaning the spawn area was off-screen to the left
2. **Tower placement issues**: Coordinate mismatch between visible area and actual map position

## Root Causes

### Before Fix:
```
Spawn Point: (0, 320)
Camera Position: (640, 360) with 0.8x zoom
Visible Area: ~160 to ~1120 on X-axis

[Spawn]                    [Camera View Start]
   |                              |
   0----------------160-----------640-----------1120
   ^                              ^
   Enemies here              Looking here
   (OFF SCREEN!)
```

### Issues:
1. Map starts at x=0, but camera looks at x=640
2. Enemies spawn at x=0 (off-screen)
3. Mouse clicks in visible area (640±) don't align with map coordinates (starting at 0)
4. Tiles might render on top of enemies (z-index issue)

## Solution Implemented

### Changes Made:

1. **Adjusted Camera Initial Position**
   - Changed from (640, 360) to (480, 320)
   - Changed zoom from 0.8 to 1.0
   - Better alignment with initial map section

2. **Dynamic Camera Movement**
   - Added `update_camera_position()` function
   - Camera now centers on the current map area as it expands
   - Formula: `camera.position = (map_width/2, map_height/2)`

3. **Fixed Rendering Order**
   - Added `z_index = -10` to map tiles
   - Added `z_index = 1` to Enemies and Towers containers
   - Ensures entities render above the map

### After Fix:
```
Section 1 (15 tiles wide = 960 pixels):
Spawn Point: (0, 320)
Camera Position: (480, 320) - centered on section
Visible Area: 0 to 960 on X-axis (with some margin)

[Spawn]-------[Camera Center]-------[End]
   |               |                    |
   0--------------480------------------960
   ^               ^                    ^
   Enemies        Looking              Path end
   VISIBLE!       here!                VISIBLE!
```

### After Wave 2:
```
Sections 1 & 2 (30 tiles wide = 1920 pixels):
Camera Position: (960, 320) - centered on both sections

[S1 Spawn]----[Old Center]----[S1 End][S2 Start]----[New Center]----[S2 End]
     0-----------480----------960------960----------1440---------1920
                                          ^
                                    Camera moves here!
```

## Testing Notes

With these fixes:
- ✅ Enemies spawn at (0, 320) and are immediately visible
- ✅ Camera dynamically adjusts as map expands
- ✅ Tower placement coordinates align with visible map
- ✅ Entities render correctly above tiles
- ✅ All map sections remain accessible

## Debug Output Added

The fix includes debug print statements:
- "Camera positioned at [pos] for [n] sections"
- "Spawned [type] at [pos] with path of [n] points"

These help verify the system is working correctly.
