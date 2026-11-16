Coastal Village - Top-Down Tileset 16x16 - FREE LITE  -  version 1.0
======================================================================

Build a sunny fishing village for your top-down RPG: sandy beaches with animated sea, cliffs and coves, whitewashed houses with tiled roofs, a market street, a lighthouse, a harbour full of blue fishing boats and everything that lives around it. Bright DS-era pixel art with ready-made autotile sets.

CONTENTS
  - 35 sprites from the full pack, in 16, 32 and 48 px

FOLDERS
  16x16/, 32x32/, 48x48/ : the same sprites at three sizes (nearest-neighbour), one PNG per sprite.
  Tiles are 16x16 at the base size; bigger objects are multiples of 16 or free-size sprites with transparency.

TIPS
  - Godot: Project Settings > Rendering > Textures > Default Texture Filter = Nearest.
  - Unity: Filter Mode = Point (no filter), Compression = None, Pixels Per Unit = 16 (or 32 / 48).
  - RPG Maker MZ/MV: use the 48x48 folder.
  - Character sheets: 80x128 at 16 px (5 columns x 4 rows of 16x32 cells). Rows: down, left, right, up. Columns: idle, then 4 walking frames.

HOW IT'S MADE
  Every sprite is drawn by our own procedural tools (Python scripts that build each object from shapes, palettes and lighting rules), with a fixed seed so the pack is reproducible. No external datasets or trained models are used.

FULL VERSION: https://draserszes.itch.io/coastal-village-topdown

LICENSE: see LICENSE.txt

CHANGELOG
  v1.0 - first release
