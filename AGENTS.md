# GodotTowerDefense - Projektminne

Detta dokument ger beständig kontext till AI-assistenter i detta repo.

## Projekt och teknik
- Godot 4.2+ (TileMapLayer, inte gammal TileMap-node).
- GDScript med tab-indentering.
- Fokus pa snabb iteration i gameplay och tydlig visuell feedback.

## Kodstil och arbetssatt
- Anvand tabs for indentering i kod.
- Hall funktioner sma och enkla att felsoka.
- Prioritera praktiska spelbarhetsforbattringar framfor stora refaktorer.
- Efter andringar: verifiera att tornplacering, fiendespawn och pathfinding fortfarande fungerar.

## Nuvarande gameplay-riktning
- En fast spelplan per test (ingen kart-expansion per wave i den nya testbranchen).
- Fiender spawnar fran vanster kant och pathfindar till hoger kant.
- Torn tar en grid-cell och far en synlig kvadratisk footprint.
- Placering far inte blockera all passage fran vanster till hoger.

## Debug-standard i testbranchen
- Oandligt guld och liv kan vara aktiverat for snabb testning.
- Tornskada kan vara satt till 0 i debug-lage.
- Behall debugflaggor tydliga och enkla att sla av.

## Kommunikation
- Svara pa svenska till anvandaren som standard i detta projekt.
