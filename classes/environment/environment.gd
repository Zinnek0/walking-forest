extends WorldEnvironment

@onready var rabbit = $WF_Rabbit

@export var paralaxRate = 0.025
var last_x_position: float = 0.0
var rot_x: float = deg_to_rad(-10)
var current_y_rotation: float = 0.0 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_x_position = rabbit.global_transform.origin.x

	var delta_x = current_x_position - last_x_position

	if delta_x != 0:
		var env = environment
		if env and env.sky_rotation:
			current_y_rotation += delta_x * paralaxRate
			var tilt = Basis(Vector3(1, 0, 0), rot_x) # Tilt on X-axis
			var pan = Basis(Vector3(0, 1, 0), current_y_rotation) # Accumulated Y-axis rotation
			
			# Tilt then Pan
			var combined_basis = tilt * pan
			env.sky_rotation = combined_basis.get_euler()
	
	last_x_position = current_x_position
