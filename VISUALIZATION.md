# Game Visualization Guide

## Game Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│ Gold: 200  Lives: 20  Wave: 1                                │
│ [Start Wave]                                                 │
│ [Archer 50g] [Mage 100g] [Cannon 150g] [Path Blocker 300g]  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩                            │
│  🟩🟩🟫🟫🟫══🟫🟫🟫🟩🟩  🟩🟩🟫══🟫🟩🟩   (Upper Path)        │
│  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩                            │
│  🔴═🟫🟫🟫══🟫🟫🟫🟩🟩  🟩🟩🟫══🟫🟩🟩   (Middle Path)       │
│  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩                            │
│  🟩🟩🟫🟫🟫══🟫🟫🟫🟩🟩  🟩🟩🟫══🟫🟩🟩   (Lower Path)        │
│  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩                            │
│  Section 1    Section 2                                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘

Legend:
🟩 = Green ground (can place towers here)
🟫 = Sandy path (enemies walk here)
═  = Path line (showing enemy route)
🔴 = Enemy spawn point
🗼 = Tower (archer/mage/cannon)
⬛ = Path blocker
👹 = Goblin (green)
👺 = Orc (brown)
🐲 = Dragon (red)
```

## Gameplay Flow

### Wave 1 Start
- 1 section visible
- 3 paths (upper, middle, lower)
- 7 enemies spawn (5 base + 1*2)
- Mix of goblins and orcs

### After Wave 1
- Section 2 is added to the right
- Map expands horizontally
- 9 enemies spawn (5 base + 2*2)

### Wave 5+
- 5 sections visible now
- Dragons start appearing
- 15 enemies spawn (5 base + 5*2)
- More challenging!

## Tower Placement Strategy

```
Example good tower placement:

🟩🟩🟩🟩🟩  🟩🟩🟩🟩🟩
🟩🟩🟫🟫🟫══🟫🟩🟩🟩
🟩🗼🟩🟩🟩  🟩🟩🟩🗼  <- Towers between paths
🔴═🟫🟫🟫══🟫🟩🟩🟩
🟩🗼🟩🟩🟩  🟩🟩🟩🗼  <- Covering multiple paths
🟩🟩🟫🟫🟫══🟫🟩🟩🟩
🟩🟩🟩🟩🟩  🟩🟩🟩🟩
```

## Path Blocker Usage

```
Before blocker:
🟩🟩🟫🟫🟫══🟫🟫🟫🟩  (Straight path)

After blocker placed:
🟩🟩🟫🟫⬛  🟫🟫🟫🟩  (Path forced down)
🟩🟩🟩🟩╚══🟫🟫🟫🟩  (Longer route!)
```

## Enemy Types Visual

- **Goblin** 👹: Small green triangle, fast mover
- **Orc** 👺: Medium brown rectangle, moderate speed
- **Dragon** 🐲: Large red diamond, fast and tough

## Tower Types Visual

- **Archer Tower**: Brown vertical structure, circular range
- **Mage Tower**: Purple pointed structure, large range
- **Cannon Tower**: Gray box structure, small range but high damage

## Health Bars

All enemies have health bars above them:
```
Enemy: 👹
HP:   [████████░░] 80/100
```

Damaged by towers as they pass through their range.
