extends Activatable

var root_node
var barrel_direction : Vector3
var has_projectile = false
var projectile_node
var projectile_script

var driver_multiplier = 1

func _ready():
	root_node = get_parent_node_3d()
	barrel_direction = root_node.global_transform.basis.z.normalized()
	barrel_direction = -barrel_direction
	
func fire_projectile():
	if has_projectile:
		GameManager.add_profit(projectile_script.ore_amount * driver_multiplier)
		print(projectile_node)
		projectile_node.apply_impulse(barrel_direction * Vector3(1000, 1000, 1000))
		projectile_script.add_deletion_timer(1)
		has_projectile = false
		projectile_node = null
		
#Add the asteroid to the barrel so we can get money
func add_to_barrel(type):
	var player = super.get_node_from_type(type)
	var projectile = player.asteroid_stack.peek()
	if projectile && !has_projectile:
		projectile = player.asteroid_stack.pop()
		has_projectile = true
		projectile.pos = %ProjectileChamber.global_position
		projectile.angular = Vector3.ZERO
		projectile.linear = Vector3.ZERO
		projectile_node = AsteroidSpawner.create_asteroid(projectile)
		projectile_script = projectile_node.find_child("ScriptNode")
		projectile_script.disable_collision()

func activate(type) -> void:
	match(type["info"]):
		"Left Mouse Button":
			%AnimationPlayer1.play("FireAction")
			fire_projectile()
			
		"Right Mouse Button":
			add_to_barrel(type)
		_:
			pass
