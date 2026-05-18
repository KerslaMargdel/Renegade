extends CharacterBody3D

# ─── Movement constants ────────────────────────────────────────────────
const MAX_SPEED          := 14.0
const ACCELERATION       := 18.0
const FRICTION           := 22.0
const TURN_FRICTION      := 28.0
const AIR_ACCELERATION   := 9.0
const AIR_FRICTION       := 4.0

# ─── Jump constants ────────────────────────────────────────────────────
const JUMP_VELOCITY      := 10.0
const RISE_GRAVITY       := 15.0
const FALL_GRAVITY       := 32.0
const MAX_FALL_SPEED     := 30.0
const JUMP_CUT_MULT      := 0.45

# ─── Forgiveness windows ───────────────────────────────────────────────
const COYOTE_TIME        := 0.10   # seconds after walking off edge
const JUMP_BUFFER_TIME   := 0.12   # seconds before landing to pre-queue jump

# ─── Internal state ───────────────────────────────────────────────────
var coyote_timer         := 0.0
var jump_buffer_timer    := 0.0
var was_on_floor         := false

# Reference set by camera.gd so movement is relative to camera facing
var camera_pivot: Node3D = null

var spawn_point: Vector3
func _ready() -> void:
	camera_pivot = get_node("CameraPivot")
	spawn_point = global_position

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	move_and_slide()
	_post_move_state()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		respawn()
	
	if global_position.y < -50.0:
		respawn()

func respawn():
	global_position = spawn_point
	velocity = Vector3.ZERO
	


# ─── Timers ────────────────────────────────────────────────────────────

func _update_timers(delta: float) -> void:
	# Coyote: start counting when we leave the floor
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
	elif is_on_floor():
		coyote_timer = COYOTE_TIME   # reset while grounded

	if not is_on_floor():
		coyote_timer -= delta

	# Jump buffer: count down from press
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	jump_buffer_timer -= delta


# ─── Gravity ───────────────────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var grav := FALL_GRAVITY if velocity.y < 0.0 else RISE_GRAVITY
	velocity.y -= grav * delta
	velocity.y = max(velocity.y, -MAX_FALL_SPEED)


# ─── Jump ──────────────────────────────────────────────────────────────

func _handle_jump() -> void:
	var can_jump := coyote_timer > 0.0
	var wants_jump := jump_buffer_timer > 0.0

	if wants_jump and can_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0       # consume both windows
		jump_buffer_timer = 0.0

	# Variable height: cut upward velocity on early release
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y *= JUMP_CUT_MULT


# ─── Horizontal movement ───────────────────────────────────────────────

func _handle_movement(delta: float) -> void:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Rotate input to match camera facing (ignore vertical tilt)
	var cam_basis := camera_pivot.global_transform.basis
	var forward   := -cam_basis.z
	var right     :=  cam_basis.x
	forward.y = 0.0
	right.y   = 0.0
	forward   = forward.normalized()
	right     = right.normalized()

	var wish_dir := (forward * -raw_input.y + right * raw_input.x)
	var has_input := wish_dir.length_squared() > 0.01

	if has_input:
		wish_dir = wish_dir.normalized()

	var target_xz := wish_dir * MAX_SPEED if has_input else Vector3.ZERO

	# Pick acceleration factor
	var accel: float
	if is_on_floor():
		if has_input:
			var current_xz := Vector3(velocity.x, 0.0, velocity.z)
			var turning    := current_xz.length() > 0.5 \
				and wish_dir.dot(current_xz.normalized()) < -0.3
			accel = TURN_FRICTION if turning else ACCELERATION
		else:
			accel = FRICTION
	else:
		accel = AIR_ACCELERATION if has_input else AIR_FRICTION

	# Apply lerp-based curve
	velocity.x = lerp(velocity.x, target_xz.x, accel * delta)
	velocity.z = lerp(velocity.z, target_xz.z, accel * delta)

	# Rotate mesh to face movement direction
	if has_input and Vector3(velocity.x, 0, velocity.z).length() > 0.5:
		var look_dir := Vector3(velocity.x, 0.0, velocity.z).normalized()
		var target_basis := Basis.looking_at(look_dir, Vector3.UP)
		$MeshInstance3D.global_transform.basis = \
			$MeshInstance3D.global_transform.basis.slerp(target_basis, 12.0 * delta)


# ─── Post-move bookkeeping ─────────────────────────────────────────────

func _post_move_state() -> void:
	was_on_floor = is_on_floor()
