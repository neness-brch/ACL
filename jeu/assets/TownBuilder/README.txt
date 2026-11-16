================================================================
 TOWN BUILDER - MODULAR HOUSES & SHOPS   (16x16 top-down asset pack)
 Pack 8 of the free series - v1.0
================================================================

WHAT IS IT
A modular building kit that snaps together on the 16x16 grid: walls,
roofs, doors, windows, awnings, signs and shopfronts - plus 29 ready-made
buildings assembled ONLY from the kit, town streets & plaza tiles,
town decor and a town-building UI. Same style & 58-colour palette as
packs 1-7. 3/4 top-down view: roof on top, front wall facing you.

HONEST COUNT: 2130 unique tiles, sprites & frames  (we say "2130+")
How it was counted (code, not by hand):
- every counted image is cut into its cells (16x16 for kit/street tiles,
  the frame size for sprites/animations) and md5-deduplicated across the
  WHOLE pack - a tile that appears in several files counts once
- empty cells are not counted
- 45 near-duplicate cells (differ from another tile by 1-3 pixels,
  e.g. lamp flicker frames or edge-pixel variants) are NOT in the headline
- recolours ARE included and listed: 429 cells (awning / ivy / pin /
  zone colours, plaster pink & blue, boards green & white, slate grey,
  clay orange, lit-at-night windows & open doors, copper drainpipes, ...)
- mirrored left/right pairs included: 13
- NOT counted at all: the 1584 tiles of the night tileset (an
  automatic night tint), the 29 prefab buildings x 3 versions and the
  16 construction-stage images (they are combinations of kit tiles -
  only the tiles they use are counted), blueprint ghosts, scenes, GIFs,
  previews, tilesets that repeat the category sheets.
- 41 kit piece names are aliases of a pixel-identical piece (e.g. a
  front-gable apex that looks exactly like the mid piece); layouts
  resolve them, they are counted once.

Per category (unique cells, before removing near-duplicates):
  Walls                    449
  Roofs                    424
  Roof Snow Overlays        67
  Doors                    124
  Windows                  162
  Roof Details              32
  Facade Details           190
  Shop Signs                84
  Construction Kit          31
  Streets Plaza            216
  Town Decor               140
  Town UI                  256

----------------------------------------------------------------
FOLDERS
----------------------------------------------------------------
01_Walls/<material>/     wall pieces  (_tilesheet_*.png = Tiled-ready)
02_Roofs/<material>/     roof pieces; Snow_Overlays/; Roof_Details/
03_Doors_Windows/        Doors (16x32 / 32x32, 4-frame open anim in
                         _anim/), Windows, Windows_Lit_Night
04_Facade_Details/       balconies, porch posts, steps, canopies,
                         awnings, drainpipes, wall lamps, ivy, roses,
                         house numbers, plaques, fascias, pilasters,
                         stallrisers, door plates, wall mailboxes
05_Shop_Signs/           3 blank hanging signs + 25 icon signs, each
                         with 2 swing frames
06_Prefab_Buildings/     one folder per building: _day / _night /
                         _snow PNG, _layout.json, one CSV per layer,
                         .tmx (Tiled) + _night.tmx. _Construction_Kit/
                         and _Construction_Stages/ (4 stages x 4)
07_Streets_Plaza/        streets, kerbs, plaza patterns, stairs,
                         retaining walls, canal (4f), bridges, alleys
08_Town_Decor/           street furniture & props (_anim/ = strips)
09_Town_UI/              build menu, cards, tabs, blueprint cursors &
                         footprints, ghosts, progress bar, upgrade,
                         info cards, toasts, resource icons, map icons
                         & pins, town-map tiles, zones, status, FX
Tilesets/                townbuilder_kit.png (+ .tsx, index CSV),
                         townbuilder_kit_night.png (same indices!),
                         townbuilder_streets.png (+ .tsx, index CSV)
Example_Scenes/          10 scenes (320x176) + 2x GIFs
Previews/                overview pages
Palette/                 palette_58.png / .gpl / .hex (no new colours)

----------------------------------------------------------------
THE KIT
----------------------------------------------------------------
WALLS - 9 materials, each with its own texture pattern:
  red brick, timber frame, lime plaster (cream), ashlar stone, log, painted board-and-batten (blue), scalloped shingle siding, half brick / half plaster, fieldstone rubble
  + recolours: plaster pink, plaster blue, boards green, boards white
  Per material:
  - columns  L  M  R  S(single, 1 tile wide)
  - rows     top  (under an eave: 2px eave shadow)
             mid  (plain)
             band (floor beam - bottom row of an upper storey)
             base (stone foundation + bottom outline - ground row)
  - M_b variation (top/mid/base), M_c second variation with a real
    feature (vent, St. Andrew's cross, exposed bricks, date stone,
    knot hole, repair patch, missing shingles, ...), base_M_cellar
    (cellar window), mid_M_moss (weathered), base_M_moss (mossy)
  - IL / IR inner corners (next to a projecting wing: cast shadow)
  - LQ / RQ quoin corners (plaster, brick, half-brick + recolours)
  One storey = 2 rows. Shops use a 3-row ground floor
  (fascia/awning row, display row, base row).

ROOFS - 7 materials: red clay tile, blue slate, straw thatch, wood shingle, green copper (patina), corrugated tin, water reed
  + recolours: slate grey, clay orange.  Per material:
  side gable (ridge runs left-right):
    side_ridge_L/M/R, side_mid_L/M/R, side_eave_L/M/R,
    side_gutter_L/M/R (eave with metal gutter), side_single_* (1-row
    roof = porch / canopy / lean-to), hipped corners side_ridge_HL/HR
    and side_single_HL/HR, side_mid_M_moss
  front gable (ridge runs into the picture, width 2N tiles, N>=2):
    gable_L/R_mid|ridge|eave   slopes (ridge = inner column,
                               eave = outer column)
    gfront_L/R_mid|ridge|eave  45-degree front edge with barge board
                               (roof above the line, gable wall shows
                               through below it)
    gback_L/R_mid|ridge|eave   back silhouette (roof below the line)
  L-shaped houses (front wing joined to a side-gable roof):
    valley_L/R_mid|ridge|eave, valley_L/R_eave_end (wing flush with
    the main roof end), *_eave_gutter / *_eave_end_gutter
  flat roof with parapet: roof_flat_TL T TR L M R BL B BR
  snow: one overlay set fits EVERY roof material (made from the
  shape, not the colours) + icicles, chimney caps, awning, balcony
  and canopy snow.

ROOF DETAILS: chimneys (brick / stone / pipe: top + base + snow top),
  smoke 4f, dormers for each roof material (+ lit), roof window
  (+ lit), weathervane 4f, finial, stork nest 2f, tower clock 32x16 4f
DOORS (12 styles x closed + 3 opening frames, + lit open versions):
  plank_arch, panel_blue, double_glass, shop_glass, cottage_green, red_round, grand_double, garage_roll, white_glass, dutch_yellow, barn_double, stained_arch
WINDOWS: square, arched, round, shop_display, tall, small, bay, twin, leaded, half_round, shop_tall, rose, lancet + shutters
  open/closed, curtains (3 colours), flower boxes, boarded, cat, 10
  themed shop displays (bread, flowers, books, cakes, toys, pots,
  instruments, ice cream, cameras, paintings) - every one with a
  lit-at-night version.

HOW TO BUILD A HOUSE (layer order: walls -> openings -> facade -> roof
-> details -> front -> snow -> snow2)
 1. Walls: a rectangle of wall pieces. Leftmost column L, rightmost R,
    middle M. Rows from the top: top (if a roof eave is right above),
    mid ..., and base as the ground row. Upper storeys end with band.
 2. Openings (own layer): doors span the 2 ground rows (door sits on
    the foundation), windows sit in any wall row.
 3. Roof (own layer, rows ABOVE the walls):
    - side gable: ridge row, mid rows, eave row (or gutter), same
      width as the walls. hip=True -> use HL/HR in the ridge row.
    - front gable on a W=2N wide front: back ^ (N rows), optional
      slope rows, front ^ (N rows). Leave the cells INSIDE the front
      ^ empty in the roof layer and fill them with wall 'mid' tiles
      in the wall layer (gable triangle).
    - L-shape: main side roof with >= N+1 rows. In the last N rows of
      the main roof put the valley ^ over the wing columns (apex row =
      valley_*_ridge, last row = valley_*_eave or *_eave_end), then
      wing slope rows, then the wing's front ^, then the wing walls.
 4. Details: chimney top in the row above the ridge, chimney base on
    the ridge row; dormers span 2 roof rows.
 5. Night: use the SAME layout with townbuilder_kit_night.png
    (identical tile indices - windows/doors/lamps light up).
 6. Winter: show the snow + snow2 layers.
Seam check: a script assembles every material in every combination
and FAILS if a band/line/diagonal does not continue across a seam
(3748 neighbour pairs tested, 0 failures, no gaps in any building;
2 arch pieces are exempt because the arch curve crosses the seam on
purpose). It also caught 5/5 deliberately broken test pieces.

PREFAB BUILDINGS (29, assembled only from kit pieces):
  cottage_brick      houses   5x5  tiles   29 kit pieces  - small brick cottage, hipped clay roof
  cottage_log        houses   4x5  tiles   30 kit pieces  - log cottage with a thatched roof
  townhouse_gable    houses   4x8  tiles   43 kit pieces  - 2-storey front-gable townhouse
  house_L            houses   7x9  tiles   62 kit pieces  - L-shaped timber-frame house
  house_dormers      houses   6x7  tiles   40 kit pieces  - plaster house with dormers
  manor_stone        houses   8x11 tiles   78 kit pieces  - 2-storey stone manor, L-shaped, balcony
  cottage_boards     houses   4x5  tiles   29 kit pieces  - blue clapboard cottage, copper roof
  rowhouses          houses   8x8  tiles   64 kit pieces  - pair of front-gable row houses (pink + blue plaster)
  town_hall          civic   10x11 tiles   51 kit pieces  - town hall with clock tower
  inn                civic    8x9  tiles   61 kit pieces  - 2-storey thatched inn with balcony
  town_gate          civic    9x8  tiles   36 kit pieces  - stone town gate: 2 towers + arch
  school             civic    8x6  tiles   36 kit pieces  - brick school house with bell-vane
  library            civic    7x8  tiles   42 kit pieces  - stone library with copper roof
  post_office        civic    6x6  tiles   41 kit pieces  - blue clapboard post office
  clinic             civic    6x8  tiles   43 kit pieces  - 2-storey plaster clinic
  ranger_station     civic    5x6  tiles   42 kit pieces  - log ranger station with porch
  cafe               shops    5x6  tiles   39 kit pieces  - pink plaster cafe, striped awning
  bakery             shops    5x6  tiles   36 kit pieces  - brick bakery with oven chimney
  barber_shop        shops    4x6  tiles   35 kit pieces  - white clapboard barber shop
  flower_shop        shops    5x8  tiles   39 kit pieces  - shingle-sided flower shop with flower boxes
  art_studio         shops    5x8  tiles   38 kit pieces  - blue plaster art studio, reed roof
  music_shop         shops    5x8  tiles   40 kit pieces  - timber-frame music shop
  photo_studio       shops    5x6  tiles   35 kit pieces  - green clapboard photo studio, roof window
  pottery            shops    5x6  tiles   39 kit pieces  - stone pottery workshop with kiln pipe
  mechanic_garage    shops    6x6  tiles   31 kit pieces  - brick garage with roll-up door, flat roof
  icecream_parlour   shops    5x6  tiles   32 kit pieces  - pink ice-cream parlour, dome awnings
  curio_shop         shops    4x8  tiles   38 kit pieces  - half-brick curio & magic shop
  bookstore          shops    5x8  tiles   41 kit pieces  - half-brick bookstore
  toy_shop           shops    5x6  tiles   36 kit pieces  - blue clapboard toy shop
Construction stages (foundation -> timber frame + scaffold -> walls +
rafters -> roof half done -> finished) for: cottage_brick, bakery, school, post_office.

----------------------------------------------------------------
ENGINE TIPS
----------------------------------------------------------------
- Import with Point / Nearest filtering, no compression, no mipmaps.
- TILED: open any 06_Prefab_Buildings/<name>/<name>.tmx - it uses
  Tilesets/townbuilder_kit.tsx (16x16). Layers = walls, openings,
  facade, roof, details, front, snow, snow2 (snow hidden). To build
  your own house: new map, add the tsx, make the same layers and
  paint walls first, then openings, then roof. Swap the tileset image
  to townbuilder_kit_night.png for night (same indices).
- Layout JSON: layers[layer][row][col] = piece name (or null);
  layers_index = index into townbuilder_kit_index.csv (-1 = empty).
  CSV files: one per layer, -1 = empty.
- UNITY: slice the tilesets as 16x16 grids (Sprite Mode Multiple,
  pixels per unit 16), one Tilemap per layer, Order in Layer =
  layer order above; characters on a sorting layer between walls and
  roof if they walk behind buildings.
- GODOT 4: TileSet with 16x16 atlas from the tileset PNG, one
  TileMapLayer per kit layer (z_index in layer order).
- GAMEMAKER: tile sets from the tileset PNGs (16x16), one tile layer
  per kit layer; animated tiles: smoke, lamps, clock, canal water.
- Animated pieces are strips named *_Nf.png (pingpong_3f = play
  0-1-2-1). Doors: closed, open1, open2, open.

----------------------------------------------------------------
PAIRS WITH (same grid, style and palette)
----------------------------------------------------------------
Pack 1 Cozy Village & Farm, 2 Fantasy Dungeon & Adventure, 3 Wild Lands,
4 Cozy Interiors & Town Life, 5 Seasons & Festivals, 6 Farm & Ranch
Life, 7 Villagers & Portraits (the villagers in the example scenes and
GIFs are from pack 7 and are not part of this pack's count).

Made with AI assistance - programmatically generated pixel art,
reviewed and curated.
