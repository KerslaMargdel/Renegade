extends MeshInstance3D

const MAX_DIST := 55.0    # how far down to raycast
const MIN_SCALE := 0.3     # smallest size at max distance
const MAX_SCALE := 1.0     # full size when close to ground
const MIN_ALPHA := 0.15

var space_state: PhysicsDirectSpaceState3D


func _ready() -> void:
	# Create the blob material
	var mat                    := StandardMaterial3D.new()
	mat.albedo_color            = Color(0.3, 0.3, 0.3, 0.6)
	mat.transparency            = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode            = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.no_depth_test           = false
	mat.depth_draw_mode         = BaseMaterial3D.DEPTH_DRAW_DISABLED
	mat.grow                    = true
	mat.grow_amount             = 0.01   # just above surface to avoid z-fighting
	material_override           = mat

	# Rotate flat to face down
	rotation_degrees.x          = -90.0


func _physics_process(_delta: float) -> void:
	space_state = get_world_3d().direct_space_state

	# Always raycast from the player, not from this node's current position
	var player    := get_parent()
	var origin    = player.global_position
	var end       = origin + Vector3.DOWN * MAX_DIST

	var query      := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude   = [player.get_rid()]

	var result    := space_state.intersect_ray(query)

	if result:
		var dist   = origin.distance_to(result.position)
		var t      = 1.0 - clamp(dist / MAX_DIST, 0.0, 1.0)

		global_position = result.position + Vector3(0.0, 0.02, 0.0)

		var s      :float = lerp(MIN_SCALE, MAX_SCALE, t)
		scale       = Vector3(s, s, s)

		(material_override as StandardMaterial3D).albedo_color = \
			Color(0.0, 0.0, 0.0, lerp(MIN_ALPHA, 0.6, t))


		visible = true
	else:
		visible = false
