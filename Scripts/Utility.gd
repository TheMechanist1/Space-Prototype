extends Node

func random_vector3(from, to):
	return Vector3(
		randf_range(from.x, to.x),
		randf_range(from.y, to.y),
		randf_range(from.z, to.z)
	)

func random_vector3_exclusion(box_min, box_max, exclusion_min, exclusion_max):
	var position
	while true:
		position = random_vector3(box_min, box_max)
		if not is_within_exclusion_zone(position, exclusion_min, exclusion_max):
			return position

func random_vector3_uniform(from, to):
	return random_vector3(Vector3(from, from, from), Vector3(to, to, to))
	
func is_within_exclusion_zone(pos, exclusion_min, exclusion_max):
	return (
		exclusion_min.x <= pos.x and pos.x <= exclusion_max.x and
		exclusion_min.y <= pos.y and pos.y <= exclusion_max.y and
		exclusion_min.z <= pos.z and pos.z <= exclusion_max.z
	)
	
func random_from_list(list : Array):
	return list[randi_range(0, list.size()-1)]
	
func random_from_dict(dict : Dictionary):
	return dict.get(random_from_list(dict.keys()))
	
func move_toward_vector3(from : Vector3, to : Vector3, delta = 0.01):
	var x = from.x + delta*(to.x - from.x)
	var y = from.y + delta*(to.y - from.y)
	var z = from.z + delta*(to.z - from.z)
	return Vector3(x, y, z)
	
func look_at_node(looking_node : Node3D, target_node : Node3D):
	looking_node.look_at(target_node.global_position, Vector3.MODEL_TOP)

# Get the distance between two vector3s
func distance(from : Vector3, to : Vector3):
	return sqrt((to.x - from.x)**2 + (to.y - from.y)**2 + (to.z - from.z)**2)
