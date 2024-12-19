extends Node3D

@export var tree_scenes: Array[PackedScene]  
@export var instance_count: int = 4000
@export var area_size: Vector3 = Vector3(50, 0, 50)  
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var min_distance: float = 3.0  #Minimum distance between objects
@export var exclusion_center: Vector3 = Vector3(0, 0, 0)  
@export var exclusion_radius: float = 1.6  

var instances = []  # Holds placed instances

func _ready():
	var rng = RandomNumberGenerator.new()
	for i in range(instance_count):
		var attempts = 0
		var placed = false

		while !placed and attempts < 100:  # Prevents infinite loops
			attempts += 1

			# Generate a random position
			var random_position = Vector3(
				rng.randf_range(-area_size.x / 2, area_size.x / 2),
				0,  
				rng.randf_range(-area_size.z / 2, area_size.z / 2)
			)

			# Generate a random scale
			var random_scale = rng.randf_range(min_scale, max_scale)
			var object_radius = random_scale * 0.1  

			# Check for overlap
			if is_position_valid(random_position, object_radius):
				# Randomly select tree
				var selected_tree_scene = tree_scenes[rng.randi_range(0, tree_scenes.size() - 1)]
				
				# Instance the selected tree
				var instance = selected_tree_scene.instantiate()
				add_child(instance)
				instance.global_transform.origin = random_position
				instance.scale = Vector3.ONE * random_scale
				instance.rotation.y = rng.randf_range(0, TAU)

				# Store the instance's position and size
				instances.append({"position": random_position, "radius": object_radius})
				placed = true
			else:
				continue

		if !placed:
			print("Could not place instance after 100 attempts")

# Check placement
func is_position_valid(position: Vector3, radius: float) -> bool:
	# Check if in the exclusion zone
	if position.distance_to(exclusion_center) < exclusion_radius:
		return false 

	# Check against existing instances
	for inst in instances:
		var dist = position.distance_to(inst["position"])
		if dist < (radius + inst["radius"] + min_distance):
			return false
	return true
