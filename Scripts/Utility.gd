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
	
