extends Node3D

var axis = Vector3(1, 0, 0) # Or Vector3.RIGHT
var rotation_amount = 0.1

var speed = 10  # Units per second
var direction = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
		
var rot_x = 0
var rot_y = 0
var LOOKAROUND_SPEED = 0.005

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 1:
		# modify accumulated mouse rotation
		rot_x += event.relative.x * LOOKAROUND_SPEED
		rot_y += event.relative.y * LOOKAROUND_SPEED
		$".".transform.basis = Basis() # reset rotation
		$".".rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		$".".rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
		pass
