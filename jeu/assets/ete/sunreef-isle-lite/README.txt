SUNREEF ISLE LITE - Free 16x16 Summer Beach Starter Pack

Contents
  sunreef_isle_lite_tileset_16x16.png   Tileset sheet, 160x48 px (10x3 tiles, no spacing)
  sunreef_isle_lite_tileset_16x16.json  Position of every tile on the sheet
  objects/                               Whole sprites, one PNG per object larger than one tile (2 files)
  tiles/                                 Every single 16x16 tile as a separate PNG (20 files)
  tiles/split/                           The same large objects as 16x16 tiles, named <name>_<row>_<col>.png, for tile maps (10 files)
  characters/                           swimmer_spritesheet.png (64x96 px, walk in 4 directions) + characters.json
  items/                                coconut, ice cream and lemonade: one 48x16 px sheet, 3 PNG files + items.json
  preview-lite.png                      Example scene (shown at 4x)
  walk-lite.gif                         The swimmer's walk cycle (shown at 6x)

How to use
  Tile size is 16x16. Import the sheet with no margin and no spacing.
  water_* is a 3x3 lagoon set on sand, water_c2 is a second centre tile.
  The props are transparent tiles.
  Objects larger than one tile are in objects/ as one PNG each: palm tree 32x48 (2x3), umbrella red 32x32 (2x2).
    The tileset JSON still lists the individual tiles of each object on the sheet.
    The individual 16x16 tiles of those objects are in tiles/split/, named <name>_<row>_<col>.png, for tile maps.
  The swimmer has 16x24 px frames: rows 0-3 walk down, up, left, right. Frames: 0 stand, 1 step, 2 stand, 3 step. About 8 fps.
  Scale by whole numbers only with nearest-neighbour filtering.

Want more? The full Sunreef Isle pack has 149 tiles with an animated lagoon and deep ocean, 3 autotile sets, two beach huts,
a juice bar, a lifeguard tower, an ice cream cart, swaying palms, tiki torches, a boardwalk, 11 props, a lifeguard,
a vendor, swim and tread-water animations, a crab, a turtle, a parrot and 16 items.

See LICENSE.txt for the terms of use.
