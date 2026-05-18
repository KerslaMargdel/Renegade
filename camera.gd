extends SpringArm3D

##Settings
const MOUSE_SENSITIVITY := 0.003 #Radians per pixel
const PAD_SENSITIVITY := 2.5 #Radians per second
const PITCH_MIN := -60.0 #degrees
const PITCH_MAX := 30.0 #degrees
const COLLISION_MARGIN := 0.1

var pivot: Node3D = null #the CameraPivot (parent of this node)
var yaw := 0.0 #horizontal angle stored on pivot
var pitch := deg_to_rad(-20.0) #vertical angle stored on spring arm

func _ready() -> void: 
	pivot = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spring_length = 5.0
	margin = COLLISION_MARGIN

func _unhandled_input(event: InputEvent) -> void:
	#Mouse look
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		_apply_rotation()
	
	#toggle mouse capture with escape
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	#gamepad look
	var pad_x := Input.get_axis("look_left", "look_right")
	var pad_y := Input.get_axis("look_up", "look_down")
	
	if abs(pad_x) > 0.1 or abs(pad_y) > 0.1:
		yaw -= pad_x * PAD_SENSITIVITY * delta
		pitch -= pad_y * PAD_SENSITIVITY * delta
		_apply_rotation()

func _apply_rotation() -> void:
	pitch = clamp(pitch, deg_to_rad(PITCH_MIN), deg_to_rad(PITCH_MAX))
	pivot.rotation.y = yaw
	rotation.x = pitch
