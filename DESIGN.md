# Tower Defense Game Design Document

## Map Expansion System

### Initial State (Wave 0)
```
[Spawn] ----path1---- [Section 1] ----path1---- [End]
        ----path2----            ----path2----
        ----path3----            ----path3----
```

### After Wave 1
```
[Spawn] ----[Section 1]---- ----[Section 2]---- [End]
        (3 parallel paths)   (3 parallel paths)
```

### After Wave 2
```
[Spawn] ----[Section 1]---- ----[Section 2]---- ----[Section 3]---- [End]
```

Each wave adds a new section to the right, expanding the playable area.

## Multiple Path System

The game features 3 parallel paths in each section:
- **Upper Path**: Slightly winding path above center
- **Middle Path**: Straight center path
- **Lower Path**: Slightly winding path below center

Enemies randomly choose one of these paths at spawn, creating varied gameplay.

## Tower Placement

Towers can be placed on any ground tile that is NOT part of a path. Valid placement areas are the green ground tiles between and around the paths.

## Path Blocker Mechanic

Cost: 300 gold (expensive!)

### How It Works:
1. Player selects "Path Blocker" button
2. Clicks on a path tile
3. Blocker is placed, blocking that specific tile
4. Game recalculates all paths to avoid the blocked tile
5. Enemies now take longer routes around the blocker

### Strategy:
- Forces enemies to walk further, giving towers more time to attack
- Best placed at choke points or path intersections
- Expensive, so use strategically

## Enemy Behavior

1. Spawn at the starting point
2. Choose a random path (upper/middle/lower)
3. Follow waypoints along that path
4. If health reaches 0, die and award gold
5. If they reach the end, player loses a life

## Win/Loss Conditions

- **Loss**: Lives reach 0 (enemies reach the end)
- **Win**: Survive all waves (currently endless mode)

## Resource Management

- **Starting Gold**: 200
- **Starting Lives**: 20
- Earn gold by defeating enemies
- Spend gold on towers and blockers
- Balance offense (towers) with strategy (blockers)
