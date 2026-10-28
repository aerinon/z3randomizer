# PitWarp ROM Implementation

## Overview

PitWarp lets the generator send dungeon pits and warp tiles to any captured landing. The ROM intercepts both transitions at the point where vanilla loads the destination room from the room header (`LDA.l $7EC000`). It looks up the source room in fixed tables to pick a `LandingZoneData` row, and if the generator wrote that row, it overrides the destination room and Link's placement. Rows the generator leaves at their default (`$8000`) keep the vanilla transition.

The generator side of the contract (row format, row index map, which capture fields feed which bytes) is in `2026-06-01-pitwarp-generator-interface.md`.

## Files

| File | Contents |
|------|----------|
| `doorrando/pitwarp.asm` | The three hooks (in a `pushpc`/`pullpc` block), `PitWarpTransitionOverride` and `PitWarpWarpFinalize` |
| `doorrando/doortables.asm` | `PitWarpLookupTable`, `PitWarpQuadrantTable`, `PitWarpCollisionListPointers`, the collision lists and `LandingZoneData` (bank `$A7`) |
| `doorrando/doorrando.asm` | Includes `pitwarp.asm` at `org $A58000` after the tables, guarded by `warnpc $A68000` |
| `vanillalabels.asm` | `SetAndSaveVisitedQuadrantFlags = $82B803` |
| `LTTP_RND_GeneralBugfixes.asm` | Bank map entry: `$25 DR Code Bank 2` |

The code lives in DR Code Bank 2 (`$A5`) so the bank `$A7` table area stays free for the generator and for table growth. The routine reads every table with long addressing and sets DB to `$7E` itself, so it does not depend on its bank.

## Data Tables

All tables are fixed ROM data except `LandingZoneData`, which the generator writes per seed.

### `PitWarpLookupTable` (`$A7C740`)

256 bytes, indexed by the source room (`RoomIndex` low byte). Each byte selects how the room picks its row:

- `$00`: no PitWarp entry; the transition stays vanilla.
- `$4x`: whole room. The low 6 bits are the `LandingZoneData` row.
- `$8x`: by quadrant. The low 3 bits pick a `PitWarpQuadrantTable` entry (0–5).
- `$Cx`: by collision box. The low 2 bits pick a `PitWarpCollisionListPointers` entry (0–3).

### `PitWarpQuadrantTable` (`$A7C840`)

6 entries × 4 bytes, one byte per quadrant in the order top-left, top-right, bottom-left, bottom-right (A/S/Z/X). Each byte is a `LandingZoneData` row; `$FF` means that quadrant stays vanilla. The slot is `LinkQuadrantH + LinkQuadrantV` (H is 0/1, V is 0/2).

| Index | Room | Quadrants with a row |
|-------|------|----------------------|
| 0 | `$31` Hera 2F | AS, Z, X |
| 1 | `$54` Swamp Attic | A, S |
| 2 | `$97` Mire Attic | A, Z, X |
| 3 | `$9E` Ice Backwards / Ice Crystal | S, X |
| 4 | `$E8` Superbunny | A, SX |
| 5 | `$ED` Fairy Ascension | ASZ, X |

### `PitWarpCollisionListPointers` (`$A7C858`)

4 word pointers (bank `$A7`) to collision lists for rooms `$17`, `$3A`, `$7D` and `$9B`. Each list is a word count followed by 5-word entries: X min, X max, Y min, Y max, row. Bounds are inclusive and use Link's absolute position (`LinkPosX`/`LinkPosY`), matching the captures in `../doors/pit_warp_data_manual.json`. Boxes are checked in order, so a catch-all box (`$0000`–`$FFFF`, used for room `$17`) goes last. No match keeps the transition vanilla.

### `LandingZoneData` (`$A7C940`)

61 rows × 25 bytes. The ROM ships every row as `$8000` (vanilla); the generator writes full rows only for the sources it remaps.

| Offset | Size | Field | Written to |
|--------|------|-------|------------|
| 0 | word | Room ID; high byte `$80` = vanilla | returned to the caller's `STA.b $A0`; also `PreviousRoom` |
| 2 | word | Link Y | `LinkPosY`; high byte also to `$40` |
| 4 | word | Link X | `LinkPosX`; high byte also to `$41` |
| 6 | word | Scroll X (BG2 value) | `BG1H`, `BG2H` |
| 8 | word | Scroll Y (BG2 value) | `BG1V`, `BG2V` |
| 10 | word | Camera trigger Y | `CameraScrollN`; `CameraScrollS` = value + 2 |
| 12 | word | Camera trigger X | `CameraScrollW`; `CameraScrollE` = value + 2 |
| 14 | byte | Target layer (0–2) | `$063C` |
| 15 | byte | Camera bound set (packed) | `CameraBoundH` (bits 1–0), `CameraBoundV` (bits 3–2) |
| 16 | byte | Quadrant (packed) | `LinkQuadrantH` (bit 0), `LinkQuadrantV` (bit 1, as 0/2) |
| 17–24 | 8 bytes | Camera bound high bytes | `$0601`, `$0603` … `$060F` |

Row indices `$00`–`$3C` are shared by pits and warps.

## Hooks

| Address | Replaces | Calls |
|---------|----------|-------|
| `$8794B1` | `LDA.l $7EC000` in `DetermineConsequencesOfFalling` (pits) | `PitWarpTransitionOverride` |
| `$87D12F` | `LDA.l $7EC000` in `TileDetect_MainHandler` (warp tiles) | `PitWarpTransitionOverride` |
| `$829611` | `JSL SetAndSaveVisitedQuadrantFlags` in `Module07_15_0F_FinalizeAndCacheEntry` | `PitWarpWarpFinalize` |

Each replaced instruction is 4 bytes, the size of a `JSL`. At both transition hooks A is 8-bit and `RoomIndex` still holds the source room; X width varies, and the routine restores the caller's flags with `PLP`.

## `PitWarpTransitionOverride`

Contract: returns the destination room in 8-bit A for the caller's `STA.b $A0`. Without an override, A is the vanilla `$7EC000` value and no RAM is changed. With an override, A is the row's room and the placement RAM is written.

Flow:

1. Load `$7EC000` and push it as the default return value, then `PHP : PHB` and set DB to `$7E`.
2. Classify `PitWarpLookupTable[RoomIndex]` and resolve a row: directly (`$4x`), from the quadrant table (`$8x`), or by walking the collision list (`$Cx`). Any miss exits with the vanilla value.
3. Multiply the row by 25 (`(i·3)·8 + i`). `Scrap00` holds the index for the multiply and is saved and restored around it, because the pit handler keeps Link's screen Y in `$00` across the hook.
4. If the row's room has bit 15 set, exit with the vanilla value.
5. Write the placement fields (table above). The camera-bound loop counts X upward from the row offset: long,X addressing carries into the next bank, so X must never drop below the row.
6. Reload the room from the row into `PreviousRoom` and Y, then `PLB : PLP : PLA` (discarding the vanilla value) and `TYA : RTL`.

### Vanilla behaviour the override compensates for

Vanilla pits and warps keep Link's in-room position, so the code that runs after the hook assumes the destination lines up with the source:

- **Room-grid shift.** `Underworld_AdjustAfterSpiralStairs`, at the start of both the fall and warp room loads, shifts Link, BG2 scroll and the camera bounds by the grid distance from `PreviousRoom` to `RoomIndex`. Setting `PreviousRoom` to the destination makes that shift zero, so the row's final values stay as written.
- **Camera trigger pairs.** Vanilla always keeps `CameraScrollS`/`CameraScrollE` at `CameraScrollN`/`CameraScrollW` + 2, and nothing on the fall or warp path recalculates them. The triggers are in-room coordinates (`($22 & $1FF) + 8` is compared against them).
- **Quadrant flips.** Warps are detected mid-frame: `Link_HandleVelocity` caches the pre-move position, the collision code finds the warp tile and runs the hook, then `ApplyLinksMovementToCamera` compares Link's position high bytes with the cached `$40`/`$41` and flips `$A9`/`$AA` (and shifts the camera bounds) on any difference. Copying the new high bytes into `$40`/`$41` prevents that.
- **Layer.** `HandleLayerOfDestination` runs right after the hook on both paths and sets `$0476`/`$EE` from `$063C`, so the row stores the `$063C` index (0 → (0,0), 1 → (1,0), 2 → (1,1)) instead of the two values.
- **Camera bound set.** `Underworld_AdjustForRoomLayout` recalculates `$A6`/`$A7` from the quadrant and the room layout, so the written values are overwritten consistently.
- **BG1 scroll.** Vanilla copies BG2 into BG1 on both room loads, and in lamp-lit dark rooms `OrientLampLightCone` recomputes BG1 from BG2 every frame. Only BG2 is stored, and the camera bound low bytes are constant, so they are not stored either.
- **Left alone on purpose.** Dungeon ID (`$040C`) carries across the transition, as DR does everywhere. Floor (`$A4`) ends up as the source floor − 1; the floor display isn't meaningful in DR.

## `PitWarpWarpFinalize`

Runs the replaced `JSL SetAndSaveVisitedQuadrantFlags`, then jumps to DR's `Underworld_SetBossOrSancMusicUponEntry_long`. Vanilla warps never land in a boss room, so only the fall path (`Module07_07_11_CacheRoomAndSetMusic`) had the boss music check. The check only acts on boss rooms and the two Sanctuary rooms, so it runs for every warp.

## Debugging

- Breakpoints: `$07:94B1` (pit hook), `$07:D12F` (warp hook), `$A5:8000` (`PitWarpTransitionOverride`). `build_unstable.sh` writes `../alttp.sym` for labels.
- After a remapped landing, before moving: `$22`/`$20`, `$E2`/`$E8` and `$061C`/`$0618` should match the row; `$A9`/`$AA` should match Link's in-room position; `$061A`/`$061E` should be N/W + 2.
- On a horizontally locked quadrant (`$A6 = 0`) the X scroll must sit exactly on a quadrant boundary, or the camera drifts. That check caught a bad capture once.

## Open Items

- Warps into rooms `$10`, `$07` and `$17` skip `Underworld_SetBossMusicUnorthodox`, so those rooms' special song cases don't run.
