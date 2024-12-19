extends CharacterBody3D
var time = 0.0;

#Face Setting Variables
var faceState = 0;
var faceUser = 0;
@onready var rabbit = $RabbitRig/Skeleton3D/RiggedRabbit
@onready var material : Material = $RabbitRig/Skeleton3D/RiggedRabbit.material_override
@onready var character = %RabbitRig
@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var animTree: AnimationTree = $AnimationTree
#@onready var animState: AnimationNodeStateMachinePlayback = animTree.get("parameters/BlendFactor")
var blendVal = 0.0;
var blendSpeed = 10.0;

@onready var animWalk = preload("res://classes/characters/rabbit/WalkAnimation.res")
@onready var animIdle = preload("res://classes/characters/rabbit/IdleAnimation.res")

# Speed of movement
@export var move_speed: float = 2.25
var direction = Vector3.ZERO
# Rotation speed (degrees per second)
@export var rotation_speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(InputMap.has_action("move_forward"))
	assert(InputMap.has_action("move_backward"))
	assert(InputMap.has_action("move_left"))
	assert(InputMap.has_action("move_right"))
	
	animTree.active = true
func faceSet(time : float) :
	var face 
	if (fmod(time, 4.0) > 0.5) :
		face = 0
	else :
		face = 1
	#print(face)
	setFace(face, 1.0)

func setFace(state : int, user : int) :
	if (material == null) :
		print("null")
		return
		
	material.set("shader_parameter/faceIndex", state)
	material.set("shader_parameter/faceUserIndex", user)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	#Sets Current Face (Blinking)
	faceSet(time)
	
	_handle_movement(delta)
	
func _handle_movement(delta):
	direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# Normalize direction to prevent faster diagonal movement
	direction = direction.normalized()

	#Deprecated Did not account for Collision
	#translate(direction * move_speed * delta)
	
	# Calculate Movement
	var motion = direction * move_speed * delta
	var collision = move_and_collide(motion)

	if collision:
		# Slide along the collision surface
		var collision_normal = collision.get_normal()
		motion = motion.slide(collision_normal)

		# Move again using the adjusted motion
		collision = move_and_collide(motion)
	
# Rotate to face the movement direction
	if direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z)
		var current_rotation = character.rotation.y
		var new_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
		character.rotation.y = new_rotation
	
	# Animation blending
	if direction.length() > 0:
		blendVal = lerp(blendVal, 1.0, blendSpeed * delta)
	else:
		blendVal = lerp(blendVal, 0.0, blendSpeed * delta)
	animTree.set("parameters/BlendFactor/blend_amount", blendVal)
	#print(blendVal, direction)
