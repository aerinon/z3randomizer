# PitWarp Generator Interface

The generator writes a single table — `LandingZoneData` — into ROM at `$A7C940`. All other pit/warp tables (lookup, quadrant, collision) are fixed ROM data that the generator does not touch.

## LandingZoneData Table

**ROM address:** `$A7C940`  
**Entry size:** 25 bytes  
**Entry count:** 61  
**Address formula:** `$A7C940 + (row_index * 25)`

To override a pit/warp, write the full 25-byte row with a room ID whose high byte is not `$80`. To leave a pit vanilla, write `$8000` as the room ID word (remaining bytes ignored).

### Row Format

Scroll fields are BG2, the real camera. Vanilla derives BG1 from BG2 on every fall and warp (`UnderworldSyncBG1and2Scroll`), and in lamp-lit dark rooms `OrientLampLightCone` recomputes BG1 every frame, so a capture's BG1 value is not a camera position.

| Offset | Size  | Field           | RAM destination(s)              |
|--------|-------|-----------------|----------------------------------|
| +0     | word  | Room ID         | `$7E00A0` — high byte `$80` = vanilla, skip all |
| +2     | word  | Link Y          | `$7E0020`                        |
| +4     | word  | Link X          | `$7E0022`                        |
| +6     | word  | Scroll X (BG2)  | `$7E00E2` (and `$7E00E0`) — from `scroll_x_e2` |
| +8     | word  | Scroll Y (BG2)  | `$7E00E8` (and `$7E00E6`) — from `scroll_y_e8` |
| +10    | word  | Camera Y        | `$7E0618`                        |
| +12    | word  | Camera X        | `$7E061C`                        |
| +14    | byte  | Target layer    | `$7E063C` — `layer_0476 + bg_setting_ee` (0, 1 or 2) |
| +15    | byte  | CamCtrl packed  | bits[1:0] → `$7E00A6` (CameraBoundH), bits[3:2] → `$7E00A7` (CameraBoundV) |
| +16    | byte  | ScrollQuad packed | bit[0] → `$7E00A9` (LinkQuadrantH), bit[1] → `$7E00AA` (LinkQuadrantV: 0 or 2) |
| +17    | byte  | Camera bound    | `$7E0601`                        |
| +18    | byte  | Camera bound    | `$7E0603`                        |
| +19    | byte  | Camera bound    | `$7E0605`                        |
| +20    | byte  | Camera bound    | `$7E0607`                        |
| +21    | byte  | Camera bound    | `$7E0609`                        |
| +22    | byte  | Camera bound    | `$7E060B`                        |
| +23    | byte  | Camera bound    | `$7E060D`                        |
| +24    | byte  | Camera bound    | `$7E060F`                        |

## Row Index Map

Each row index corresponds to a specific pit or warp source in the ROM. The generator assigns a destination landing to each by writing that row.

### Direct ($4x) — one row per room

| Row  | Source Room | Dungeon |
|------|-------------|---------|
| `00` | `$07`       | EP      |
| `01` | `$09`       | EP      |
| `02` | `$0A`       | EP      |
| `03` | `$0B`       | EP      |
| `04` | `$1E`       | DP      |
| `05` | `$27`       | AT      |
| `06` | `$39`       | PoD     |
| `07` | `$3D`       | PoD     |
| `08` | `$4B`       | SP      |
| `09` | `$4D`       | SP      |
| `0A` | `$4F`       | SP      |
| `0B` | `$5E`       | SW      |
| `0C` | `$7B`       | TT      |
| `0D` | `$7E`       | TT      |
| `0E` | `$89`       | IP      |
| `0F` | `$8C`       | GT      |
| `10` | `$9D`       | MM      |
| `11` | `$A7`       | TR      |
| `12` | `$A9`       | TR      |
| `13` | `$B1`       | TR      |
| `14` | `$CE`       | GT      |
| `15` | `$D1`       | GT      |
| `16` | `$EA`       | GT      |
| `17` | `$EB`       | GT      |
| `18` | `$EE`       | GT      |
| `19` | `$EF`       | GT      |

### Quadrant ($8x) — up to 4 rows per room, one per quadrant

Each room with a quadrant entry has up to 4 row indices assigned — one per screen quadrant (A=top-left, S=top-right, Z=bottom-left, X=bottom-right). A quadrant slot of `$FF` in the quadrant table means no destination for that quadrant (vanilla fallback); no row is allocated for it.

| Rows        | Source Room | Name              | A    | S    | Z    | X    |
|-------------|-------------|-------------------|------|------|------|------|
| `1A`–`1C`   | `$31`       | Hera 2F           | `1A` | `1A` | `1B` | `1C` |
| `1D`–`1E`   | `$54`       | Swamp Attic       | `1D` | `1E` | —    | —    |
| `1F`–`21`   | `$97`       | Mire Attic        | `1F` | —    | `20` | `21` |
| `22`–`23`   | `$9E`       | Ice               | —    | `22` | —    | `23` |
| `24`–`25`   | `$E8`       | Superbunny        | `24` | `25` | —    | `25` |
| `26`–`27`   | `$ED`       | Fairy Ascension   | `26` | `26` | `26` | `27` |

### Collision ($Cx) — one row per bounding box region

These rows map 1:1 to bounding box entries in the collision lists. The ROM checks Link's position against each box at runtime to select the row.

| Row  | Source Room | Location                        |
|------|-------------|---------------------------------|
| `28` | `$17`       | Hera PotPit                     |
| `29` | `$17`       | Hera Big Chest Pit              |
| `2A` | `$17`       | Hera (rest of room)             |
| `2B` | `$3A`       | PoD Pit Room Freefall           |
| `2C` | `$3A`       | PoD Pit Room Bomb Hole          |
| `2D` | `$3A`       | PoD Big Key Landing Hole        |
| `2E` | `$7D`       | GT Rail Choice Left             |
| `2F` | `$7D`       | GT Rail Choice Right            |
| `30` | `$7D`       | GT Warp Hub MidRight            |
| `31` | `$7D`       | GT Warp Hub Top Right           |
| `32` | `$7D`       | GT Warp Hub Bottom Right        |
| `33` | `$7D`       | GT Warp Hub Mid Left            |
| `34` | `$7D`       | GT Warp Hub Bottom Left         |
| `35` | `$7D`       | GT Rando Rail                   |
| `36` | `$7D`       | GT Arrow Pot                    |
| `37` | `$9B`       | GT Spike Warp                   |
| `38` | `$9B`       | GT Warp Maze Mid Right          |
| `39` | `$9B`       | GT Warp Maze Mid Left           |
| `3A` | `$9B`       | GT Warp Maze Right Section      |
| `3B` | `$9B`       | GT Warp Maze Left Section       |
| `3C` | `$9B`       | GT Warp Maze Pit Section        |
