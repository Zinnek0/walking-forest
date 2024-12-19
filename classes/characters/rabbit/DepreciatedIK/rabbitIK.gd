extends Node3D
var time = 0.0;

#Face Setting Variables
var faceState = 0;
var faceUser = 0;
@onready var material : Material = $RabbitRig/Skeleton3D/RiggedRabbit.material_override
@onready var skelIK: Array = $RabbitRig/Skeleton3D.find_children("", "SkeletonIK3D", false)

#Proceedural Animation Variables
@export var move_speed: float = 2.0
@export var turn_speed: float = 1.0
@export var ground_offset: float = 0.5

@onready var l_leg = $RabbitRig/Skeleton3D/Leg_Target_l
@onready var r_leg = $RabbitRig/Skeleton3D/Leg_Target_r

@onready var animPlayer: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Start All IKs
	for ik_node in skelIK:
		ik_node.start()
	#Proceedural Setup
	pass # Replace with function body.

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
	setFace(fmod(time, 2.0), 1.0)
	
	_handle_movement(delta)
	
func _handle_movement(delta):
	var dir = Input.get_axis('ui_down', 'ui_up')
	translate(Vector3(0, 0, -dir) * move_speed * delta)
	
	var a_dir = Input.get_axis('ui_right', 'ui_left')
	rotate_object_local(Vector3.UP, a_dir * turn_speed * delta)
