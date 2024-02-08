extends Node3D
# This is the enemy class, it will take a lot of insperation from factorio's biter algorithms
# They will like to group up before deciding which action to take


# Start off in idle, This is where we choose which action we want to take
# 
enum State {IDLE, STEALING, SHOOTING, FLEEING}
enum StateMode {TRAVELING, ACTION}

@onready var root_node = get_parent_node_3d()
@onready var agent = %Agent

var target_randomizer
var current_target : Node3D
var current_state : State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	target_randomizer = Utility.random_from_dict(GameManager.Players)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for player in get_tree().get_nodes_in_group("Players"):
		if(player.name == str(target_randomizer.id)):
			current_target = player
			Utility.look_at_node(root_node, player.head)
			
	var distance = Utility.distance(root_node.position, current_target.position)
	
	match current_state:
		State.IDLE:
			if(move_to_position(current_target.position, delta)):
				current_state = Utility.random_from_list([State.STEALING, State.SHOOTING, State.FLEEING])
		State.STEALING:
			if(move_to_position(current_target.position + Vector3(0, 0, 10), delta)):
				print("LMAO1")
		State.SHOOTING:
			print("LMAO2")
		State.FLEEING:
			print("LMAO3")
			
func move_to_position(pos : Vector3, delta):
	root_node.position = Utility.move_toward_vector3(root_node.position, pos, delta)
	return Utility.distance(root_node.position, current_target.position) <= 1
