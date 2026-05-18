extends Node3D

# Each entry is [position: Vector3, size: Vector3]
# Laid out as a linear gauntlet testing one mechanic per section
const PLATFORMS := [
	# ── Ground: acceleration / friction run ──────────────────────────
	[Vector3(  0,  -1,   0), Vector3(20, 1, 6)],   # start pad

	# ── Flat gap series: comfortable → punishing ─────────────────────
	[Vector3( 24,  -1,   0), Vector3( 5, 1, 5)],
	[Vector3( 32,  -1,   0), Vector3( 4, 1, 5)],
	[Vector3( 39,  -1,   0), Vector3( 3, 1, 5)],
	[Vector3( 45.5,-1,   0), Vector3( 2, 1, 5)],   # tight

	# ── Height variation: short hops → full jumps ────────────────────
	[Vector3( 52,   0,   0), Vector3( 4, 1, 5)],
	[Vector3( 59,   2,   0), Vector3( 4, 1, 5)],
	[Vector3( 66,   4,   0), Vector3( 4, 1, 5)],
	[Vector3( 73,   2,   0), Vector3( 4, 1, 5)],
	[Vector3( 80,  -1,   0), Vector3( 4, 1, 5)],

	# ── Coyote time ledges: walk off and jump ─────────────────────────
	[Vector3( 90,  -1,   0), Vector3( 8, 1, 5)],
	[Vector3(102,  -1,   0), Vector3( 3, 1, 5)],   # step off here
	[Vector3(109,  -1,   0), Vector3( 3, 1, 5)],

	# ── Descending: tests fall speed and landing feel ─────────────────
	[Vector3(118,   2,   0), Vector3( 5, 1, 5)],
	[Vector3(126,  -1,   0), Vector3( 5, 1, 5)],
	[Vector3(134,  -4,   0), Vector3( 5, 1, 5)],
	[Vector3(142,  -8,   0), Vector3( 5, 1, 5)],

	# ── End pad ───────────────────────────────────────────────────────
	[Vector3(155,  -8,   0), Vector3(16, 1, 8)],
]


func _ready() -> void:
	for entry in PLATFORMS:
		_make_platform(entry[0], entry[1])


func _make_platform(pos: Vector3, size: Vector3) -> void:
	var box       := CSGBox3D.new()
	box.size      = size
	box.position  = pos
	box.use_collision = true
	# Alternate two muted colours so platforms read clearly
	var mat       := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.55, 0.60) if int(pos.x) % 20 < 10 \
		else Color(0.42, 0.50, 0.58)
	box.material_override  = mat
	add_child(box)
